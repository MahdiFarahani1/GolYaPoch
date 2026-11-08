import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/match_store.dart';
import '../domain/match_rules.dart';
import '../domain/match_state.dart';

/// The phone is a referee, not a sensor. A human confirms each physical result.
class MatchCubit extends Cubit<MatchState> {
  MatchCubit(super.initial, {MatchStore? store}) : _store = store ?? MatchStore();
  final MatchStore _store;
  final List<MatchState> _undo = [];

  bool get canUndo => _undo.isNotEmpty;

  void _apply(MatchState next, {bool remember = true}) {
    if (state.isFinished) return;
    if (remember) _undo.add(state);
    emit(next);
    if (next.isFinished) {
      _store.archive(next);
    } else {
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
      phoenixReward: card == CardPower.phoenix ? CustomRules.phoenixPoints(deficit) : 0,
      note: 'کارت ${card.title} فعال شد؛ فرصت خنثی‌سازی'));
  }

  void respondToCard({required bool nullify}) {
    if (state.phase != RoundPhase.defendCard) return;
    if (nullify && state.nullifiers[state.holder] > 0) {
      final updated = List<int>.of(state.nullifiers);
      updated[state.holder]--;
      _apply(state.copyWith(nullifiers: updated, clearPower: true, clearPrediction: true,
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
    if (state.phase != RoundPhase.guess || state.power == null) return;
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
    scores[state.crownOwner!] = (scores[state.crownOwner!] - 3).clamp(0, 100);
    _apply(state.copyWith(scores: scores, phase: RoundPhase.guess,
      clearCrown: true, hand: state.hand + 1, emptyGuesses: 0,
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
    if (ownerProtected) {
      _apply(state.copyWith(phase: RoundPhase.finished, winner: owner,
        note: 'دوئل به سود صاحب تاج؛ قهرمانی!'));
      return;
    }
    final scores = List<int>.of(state.scores);
    scores[owner] = (scores[owner] - 5).clamp(0, 100);
    _apply(state.copyWith(scores: scores, phase: RoundPhase.guess,
      clearCrown: true, hand: state.hand + 1, emptyGuesses: 0,
      freePoisonEmpty: false, secondsLeft: state.settings.turnSeconds,
      note: 'دوئل شکست خورد؛ ۵ امتیاز کسر شد'));
  }

  /// Generic scorekeeping fallback for modes whose complete proprietary card rules
  /// are not yet verified. The UI marks this clearly as manual referee mode.
  void manualEvent({required bool found, required int points}) {
    if (state.isCustom || state.phase == RoundPhase.finished) return;
    final scores = List<int>.of(state.scores);
    final receiver = found ? state.guesser : state.holder;
    scores[receiver] = CustomRules.addPoints(scores[receiver], points, state.settings);
    final winner = _directWinner(scores);
    _apply(state.copyWith(scores: scores, holder: receiver,
      winner: winner, phase: winner == null ? RoundPhase.guess : RoundPhase.finished,
      hand: state.hand + 1, secondsLeft: state.settings.turnSeconds,
      note: found ? 'گل گرفته شد' : 'گل حفظ شد'));
  }
}
