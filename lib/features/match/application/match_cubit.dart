import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/match_store.dart';
import '../domain/match_rules.dart';
import '../domain/physical_cards.dart';
import '../domain/match_state.dart';

/// The phone is a referee, not a sensor. A human confirms each physical result.
class MatchCubit extends Cubit<MatchState> {
  MatchCubit(super.initial, {MatchStore? store}) : _store = store ?? MatchStore() {
    if (!state.isFinished) _store.save(state);
  }
  final MatchStore _store;
  final List<MatchState> _undo = [];

  bool get canUndo => _undo.isNotEmpty;

  void _apply(MatchState next, {bool remember = true}) {
    if (state.isFinished) return;
    if (remember) _undo.add(state);
    emit(next);
    if (next.isFinished) {
      _store.archive(next);
    } else if (remember || next.secondsLeft % 10 == 0) {
      _store.save(next);
    }
  }

  void undo() {
    if (_undo.isEmpty) return;
    final previous = _undo.removeLast();
    emit(previous);
    _store.save(previous);
  }

  void tick() {
    if (state.isFinished || state.phase == RoundPhase.crownChoice || state.phase == RoundPhase.captainDuel || state.phase == RoundPhase.defendCard || state.phase == RoundPhase.predict || state.phase == RoundPhase.finalGuess) return;
    if (state.secondsLeft > 1) {
      _apply(state.copyWith(secondsLeft: state.secondsLeft - 1), remember: false);
    } else {
      _apply(state.copyWith(secondsLeft: 0, phase: RoundPhase.finalGuess,
        note: 'وقت تموم شد؛ فقط یک انتخاب نهایی'), remember: true);
    }
  }

  void emptyGuess() {
    if (state.phase != RoundPhase.guess || state.emptyGuesses >= 3 || state.power == CardPower.hourglass) return;
    final count = state.emptyGuesses + 1;
    _apply(state.copyWith(emptyGuesses: count,
      phase: count == 3 ? RoundPhase.finalGuess : RoundPhase.guess,
      note: 'پوچ شماره $count ثبت شد'));
  }

  void playCard(CardPower card) {
    if (!state.canPlayCard || !state.cards[state.guesser].contains(card)) return;
    final deficit = state.scores[state.holder] - state.scores[state.guesser];
    if (card == CardPower.phoenix && deficit < 3) return;
    final list = state.cards.map((e) => List<CardPower>.of(e)).toList();
    list[state.guesser].remove(card);
    _apply(state.copyWith(cards: list, power: card, phase: RoundPhase.defendCard,
      offensiveUsed: true,
      phoenixReward: card == CardPower.phoenix ? CustomRules.phoenixPoints(deficit) : 0,
      note: 'کارت ${card.title} فعال شد؛ فرصت خنثی‌سازی'));
  }

  void respondToCard({required bool nullify}) {
    if (state.phase != RoundPhase.defendCard) return;
    if (nullify && !state.defensiveUsed && state.nullifiers[state.holder] > 0) {
      final updated = List<int>.of(state.nullifiers);
      updated[state.holder]--;
      _apply(state.copyWith(nullifiers: updated, defensiveUsed: true,
        clearPower: true, clearPrediction: true,
        phoenixReward: 0, phase: RoundPhase.guess,
        note: 'کارت خنثی شد؛ بازی عادی ادامه دارد'));
    } else {
      _apply(state.copyWith(phase: state.power == CardPower.doubleSword
        ? RoundPhase.predict : RoundPhase.guess,
        secondsLeft: state.power == CardPower.hourglass
          ? (state.secondsLeft / 2).ceil() : state.secondsLeft,
        note: 'کارت اجرا شد'));
    }
  }

  void captainPrediction(bool willFind) {
    if (state.phase != RoundPhase.predict) return;
    _apply(state.copyWith(prediction: willFind, phase: RoundPhase.guess,
      note: willFind ? 'کاپیتان: گل پیدا می‌شود' : 'کاپیتان: گل پیدا نمی‌شود'));
  }

  /// A correct Hunter or Poison-Hand special call transfers the flower without points.
  void specialChoice({required bool correct}) {
    if ((state.phase != RoundPhase.guess && state.phase != RoundPhase.finalGuess) || state.power == null) return;
    if (state.power == CardPower.hunter) {
      if (correct) {
        _capture(0, note: 'شکارچی گل را گرفت؛ بدون امتیاز');
      } else {
        _hold(2, note: 'شکارچی شکست خورد؛ ۲ امتیاز برای نگهدارنده');
      }
    } else if (state.power == CardPower.poisonHand) {
      if (correct) {
        _capture(0, note: 'دست سمی گل را گرفت؛ بدون امتیاز');
      } else {
        _apply(state.copyWith(freePoisonEmpty: true, clearPower: true,
          note: 'یک مشت رایگان پوچ شد؛ سه خالی‌بازی باقی است'));
      }
    } else if (state.power == CardPower.hourglass) {
      if (correct) {
        _capture(4, note: 'ساعت شنی موفق؛ ۴ امتیاز');
      } else {
        _hold(2, note: 'ساعت شنی ناموفق؛ ۲ امتیاز برای نگهدارنده');
      }
    }
  }

  void normalCapture({bool firstStrike = false}) {
    if (state.phase != RoundPhase.guess && state.phase != RoundPhase.finalGuess) return;
    if (state.power == CardPower.hourglass || state.power == CardPower.hunter || state.power == CardPower.poisonHand) return;
    final isFirst = firstStrike && state.emptyGuesses == 0 && !state.freePoisonEmpty;
    final reward = state.power == CardPower.phoenix
        ? state.phoenixReward : isFirst ? 2 : 0;
    _capture(reward, note: state.power == CardPower.phoenix
      ? 'ققنوس موفق؛ $reward امتیاز' : isFirst ? 'تک‌ضرب موفق؛ ۲ امتیاز' : 'گل منتقل شد؛ بدون امتیاز');
  }

  void failedToFind() {
    if (state.phase != RoundPhase.guess && state.phase != RoundPhase.finalGuess) return;
    if (state.power == CardPower.hourglass || state.power == CardPower.hunter) return;
    final reward = state.power == CardPower.phoenix ? 2 : 1;
    _hold(reward, note: 'گل حفظ شد؛ $reward امتیاز');
  }

  List<int> _bonusScores({required bool found}) {
    final points = List<int>.of(state.scores);
    if (state.power == CardPower.doubleSword && state.prediction != null) {
      final receiver = state.prediction == found ? state.holder : state.guesser;
      points[receiver] = CustomRules.addPoints(points[receiver], 1, state.settings);
    }
    return points;
  }

  void _capture(int earned, {required String note}) {
    final previousHolder = state.holder;
    final wasShah = state.isShahHand;
    final scores = _bonusScores(found: true);
    scores[state.guesser] = CustomRules.addPoints(scores[state.guesser], earned, state.settings);
    if (wasShah) {
      _apply(state.copyWith(scores: scores, holder: state.guesser,
        phase: RoundPhase.crownChoice, crownOwner: previousHolder,
        clearPower: true, clearPrediction: true, note: 'شاه‌گل شکست خورد؛ بهای تاج را انتخاب کنید'));
      return;
    }
    final winner = _directWinner(scores);
    _apply(state.copyWith(scores: scores, holder: state.guesser,
      phase: winner == null ? RoundPhase.guess : RoundPhase.finished, winner: winner,
      hand: state.hand + 1, emptyGuesses: 0, freePoisonEmpty: false,
      offensiveUsed: false, defensiveUsed: false,
      secondsLeft: state.settings.turnSeconds, clearPower: true, clearPrediction: true,
      phoenixReward: 0, note: note));
  }

  void _hold(int earned, {required String note}) {
    final wasShah = state.isShahHand;
    final scores = _bonusScores(found: false);
    if (!wasShah) scores[state.holder] = CustomRules.addPoints(scores[state.holder], earned, state.settings);
    final winner = wasShah ? state.holder : _directWinner(scores);
    _apply(state.copyWith(scores: scores,
      phase: winner == null ? RoundPhase.guess : RoundPhase.finished, winner: winner,
      hand: state.hand + 1, emptyGuesses: 0, freePoisonEmpty: false,
      offensiveUsed: false, defensiveUsed: false,
      secondsLeft: state.settings.turnSeconds, clearPower: true, clearPrediction: true,
      phoenixReward: 0, note: wasShah ? 'شاه‌گل حفظ شد؛ قهرمان مشخص شد' : note));
  }

  int? _directWinner(List<int> scores) {
    if (state.settings.shahGolEnabled) return null;
    if (scores[0] >= state.settings.target) return 0;
    if (scores[1] >= state.settings.target) return 1;
    return null;
  }

  void crownRetreat() {
    if (state.phase != RoundPhase.crownChoice || state.crownOwner == null) return;
    final scores = List<int>.of(state.scores);
    scores[state.crownOwner!] = (scores[state.crownOwner!] - 3).clamp(0, 100).toInt();
    _apply(state.copyWith(scores: scores, phase: RoundPhase.guess,
      clearCrown: true, hand: state.hand + 1, emptyGuesses: 0,
      offensiveUsed: false, defensiveUsed: false,
      freePoisonEmpty: false, secondsLeft: state.settings.turnSeconds,
      note: 'عقب‌نشینی؛ ۳ امتیاز کسر شد'));
  }

  void chooseCaptainDuel() {
    if (state.phase != RoundPhase.crownChoice) return;
    _apply(state.copyWith(phase: RoundPhase.captainDuel,
      note: 'دوئل بدون کارت؛ یک مخفی‌سازی و یک حدس'));
  }

  void resolveCaptainDuel({required bool ownerProtected}) {
    if (state.phase != RoundPhase.captainDuel || state.crownOwner == null) return;
    final owner = state.crownOwner!;
    if (!state.isCustom) {
      final winner = ownerProtected ? owner : 1 - owner;
      _apply(state.copyWith(phase: RoundPhase.finished, winner: winner,
        note: 'دوئل داوری شد؛ برنده اعلام شد'));
      return;
    }
    if (ownerProtected) {
      _apply(state.copyWith(phase: RoundPhase.finished, winner: owner,
        note: 'دوئل به سود صاحب تاج؛ قهرمانی!'));
      return;
    }
    final scores = List<int>.of(state.scores);
    scores[owner] = (scores[owner] - 5).clamp(0, 100).toInt();
    _apply(state.copyWith(scores: scores, phase: RoundPhase.guess,
      clearCrown: true, hand: state.hand + 1, emptyGuesses: 0,
      offensiveUsed: false, defensiveUsed: false,
      freePoisonEmpty: false, secondsLeft: state.settings.turnSeconds,
      note: 'دوئل شکست خورد؛ ۵ امتیاز کسر شد'));
  }

  /// Physically play the original card; the app consumes it and records the
  /// chosen milli cost without inventing unverified official effects.
  void manualUseCard(String cardId, {int milliCost = 0}) {
    if (state.isCustom || state.phase != RoundPhase.guess ||
        state.offensiveUsed || milliCost < 0 ||
        !state.physicalCards[state.guesser].contains(cardId) ||
        !PhysicalCards.all.containsKey(cardId)) return;
    if (state.settings.mode == GameMode.filimo &&
        state.settings.playersPerTeam * 2 - state.emptyGuesses < 3) return;
    if (state.settings.mode == GameMode.shahGol &&
        milliCost > state.milliBalances[state.guesser]) return;
    final remaining=state.physicalCards.map((cards)=>List<String>.of(cards)).toList();
    remaining[state.guesser].remove(cardId);
    final milli=List<int>.of(state.milliBalances);
    if(state.settings.mode==GameMode.shahGol) milli[state.guesser] -= milliCost;
    _apply(state.copyWith(physicalCards:remaining,milliBalances:milli,
      offensiveUsed:true,
      note:'کارت ${PhysicalCards.all[cardId]!.title} مصرف شد؛ اثر را در بازی واقعی اجرا کنید'));
  }

  void manualAdjustMilli(int team, int delta) {
    if (state.settings.mode != GameMode.shahGol || state.isFinished ||
        team < 0 || team > 1) return;
    final milli=List<int>.of(state.milliBalances);
    milli[team] = (milli[team]+delta).clamp(0,999).toInt();
    _apply(state.copyWith(milliBalances:milli,note:'موجودی میلی توسط داور ثبت شد'));
  }

  /// The two existing physical games are assisted referee modes.
  /// Unverified card effects are entered as points by a human official.
  void manualEvent({required bool found, required int points}) {
    if (state.isCustom || (state.phase != RoundPhase.guess &&
        state.phase != RoundPhase.finalGuess)) return;
    final oldHolder = state.holder;
    final isCrown = state.isShahHand;
    final scores = List<int>.of(state.scores);
    final receiver = found ? state.guesser : oldHolder;
    if (isCrown && !found) {
      _apply(state.copyWith(phase: RoundPhase.finished, winner: oldHolder,
        note: 'شاه‌گل حفظ شد؛ قهرمانی تیم صاحب گل'));
      return;
    }
    scores[receiver] = CustomRules.addPoints(scores[receiver], points, state.settings);
    if (isCrown && found && state.settings.mode == GameMode.filimo) {
      final losses = List<int>.of(state.shahLosses);
      losses[oldHolder]++;
      if (losses[oldHolder] == 1) {
        scores[oldHolder] = (scores[oldHolder] - 3).clamp(0, state.settings.scoreCap).toInt();
        _apply(state.copyWith(scores: scores, holder: receiver,
          shahLosses: losses, hand: state.hand + 1,
          emptyGuesses: 0, offensiveUsed:false, defensiveUsed:false,
          secondsLeft: state.settings.turnSeconds,
          phase: RoundPhase.guess,
          note: 'اولین شکست شاه‌گل فیلیمو؛ ۳ امتیاز کم شد'));
      } else {
        _apply(state.copyWith(scores: scores, holder: receiver,
          shahLosses: losses, crownOwner: oldHolder,
          phase: RoundPhase.captainDuel,
          note: 'شکست دوم شاه‌گل فیلیمو؛ نتیجه دوئل را داور ثبت می‌کند'));
      }
      return;
    }
    if (isCrown && found && state.settings.mode == GameMode.shahGol) {
      _apply(state.copyWith(scores: scores, holder: receiver,
        crownOwner: oldHolder, phase: RoundPhase.crownChoice,
        note: 'شاه‌گل گرفته شد؛ داور نتیجه طبق دفترچه را ثبت کند'));
      return;
    }
    final winner = _directWinner(scores);
    _apply(state.copyWith(scores: scores, holder: receiver,
      winner: winner, phase: winner == null ? RoundPhase.guess : RoundPhase.finished,
      hand: state.hand + 1, secondsLeft: state.settings.turnSeconds,
      offensiveUsed:false, defensiveUsed:false,
      emptyGuesses: 0,
      note: found ? 'گل گرفته شد' : 'گل حفظ شد'));
  }

  /// In the board game, until its instruction booklet is verified,
  /// a human referee chooses the official outcome rather than an invented rule.
  void manualCrownContinue({int penalty = 0}) {
    if (state.isCustom || state.phase != RoundPhase.crownChoice ||
        state.crownOwner == null || penalty < 0) return;
    final scores = List<int>.of(state.scores);
    final owner = state.crownOwner!;
    scores[owner] = (scores[owner] - penalty).clamp(0, state.settings.scoreCap).toInt();
    _apply(state.copyWith(scores: scores, clearCrown: true,
      phase: RoundPhase.guess, hand: state.hand + 1,
      secondsLeft: state.settings.turnSeconds, emptyGuesses: 0,
      offensiveUsed:false, defensiveUsed:false,
      note: 'نتیجه شاه‌گل توسط داور ثبت شد'));
  }

  void manualDeclareWinner(int winner) {
    if (state.isCustom || winner < 0 || winner > 1 || state.isFinished) return;
    _apply(state.copyWith(phase: RoundPhase.finished, winner: winner,
      note: 'نتیجه مسابقه توسط داور اعلام شد'));
  }

  void manualAdjustScore(int team, int delta) {
    if (state.isCustom || state.isFinished || team < 0 || team > 1) return;
    final scores = List<int>.of(state.scores);
    scores[team] = CustomRules.addPoints(scores[team], delta, state.settings);
    _apply(state.copyWith(scores: scores, note: 'تصحیح امتیاز توسط داور'));
  }
}
