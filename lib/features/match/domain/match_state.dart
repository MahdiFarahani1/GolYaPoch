import 'match_rules.dart';
import 'physical_cards.dart';

class MatchState {
  const MatchState({
    required this.settings,
    required this.teams,
    required this.scores,
    required this.holder,
    required this.phase,
    required this.cards,
    required this.nullifiers,
    required this.secondsLeft,
    this.emptyGuesses = 0,
    this.freePoisonEmpty = false,
    this.power,
    this.prediction,
    this.phoenixReward = 0,
    this.crownOwner,
    this.winner,
    this.hand = 1,
    this.offensiveUsed = false,
    this.defensiveUsed = false,
    this.shahLosses = const [0, 0],
    this.physicalCards = const [[], []],
    this.milliBalances = const [0,0],
    this.isPaused = false,
    this.note = 'مسابقه آغاز شد',
  });

  final MatchSettings settings;
  final List<String> teams;
  final List<int> scores;
  final int holder;
  final RoundPhase phase;
  final List<List<CardPower>> cards;
  final List<int> nullifiers;
  final int secondsLeft;
  final int emptyGuesses;
  final bool freePoisonEmpty;
  final CardPower? power;
  final bool? prediction;
  final int phoenixReward;
  final int? crownOwner;
  final int? winner;
  final int hand;
  final bool offensiveUsed;
  final bool defensiveUsed;
  final List<int> shahLosses;
  final List<List<String>> physicalCards;
  final List<int> milliBalances;
  final bool isPaused;
  final String note;

  int get guesser => 1 - holder;
  bool get isCustom => settings.mode == GameMode.nabardGol;
  bool get isShahHand => settings.shahGolEnabled && scores[holder] >= settings.shahThreshold;
  bool get isFinished => phase == RoundPhase.finished;
  bool get canPlayCard => isCustom && phase == RoundPhase.guess && power == null && !offensiveUsed && emptyGuesses == 0 && !freePoisonEmpty;
  bool get isFinalChoice => phase == RoundPhase.finalGuess;

  MatchState copyWith({
    List<int>? scores, int? holder, RoundPhase? phase,
    List<List<CardPower>>? cards, List<int>? nullifiers, int? secondsLeft,
    int? emptyGuesses, bool? freePoisonEmpty, CardPower? power,
    bool clearPower = false, bool? prediction, bool clearPrediction = false,
    int? phoenixReward, int? crownOwner, bool clearCrown = false,
    int? winner, int? hand, bool? offensiveUsed, bool? defensiveUsed,
    List<int>? shahLosses, List<List<String>>? physicalCards,
    List<int>? milliBalances, bool? isPaused, String? note,
  }) => MatchState(
    settings: settings, teams: teams,
    scores: scores ?? this.scores,
    holder: holder ?? this.holder, phase: phase ?? this.phase,
    cards: cards ?? this.cards, nullifiers: nullifiers ?? this.nullifiers,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    emptyGuesses: emptyGuesses ?? this.emptyGuesses,
    freePoisonEmpty: freePoisonEmpty ?? this.freePoisonEmpty,
    power: clearPower ? null : power ?? this.power,
    prediction: clearPrediction ? null : prediction ?? this.prediction,
    phoenixReward: phoenixReward ?? this.phoenixReward,
    crownOwner: clearCrown ? null : crownOwner ?? this.crownOwner,
    winner: winner ?? this.winner, hand: hand ?? this.hand,
    offensiveUsed: offensiveUsed ?? this.offensiveUsed,
    defensiveUsed: defensiveUsed ?? this.defensiveUsed,
    shahLosses: shahLosses ?? this.shahLosses,
    physicalCards: physicalCards ?? this.physicalCards,
    milliBalances: milliBalances ?? this.milliBalances,
    isPaused: isPaused ?? this.isPaused,
    note: note ?? this.note,
  );

  Map<String, dynamic> toJson() => {
    'settings': settings.toJson(), 'teams': teams, 'scores': scores,
    'holder': holder, 'phase': phase.name,
    'cards': cards.map((e) => e.map((c) => c.name).toList()).toList(),
    'nullifiers': nullifiers, 'secondsLeft': secondsLeft,
    'emptyGuesses': emptyGuesses, 'freePoisonEmpty': freePoisonEmpty,
    'power': power?.name, 'prediction': prediction,
    'phoenixReward': phoenixReward, 'crownOwner': crownOwner,
    'winner': winner, 'hand': hand, 'note': note,
    'offensiveUsed': offensiveUsed, 'defensiveUsed': defensiveUsed,
    'shahLosses': shahLosses,
    'physicalCards': physicalCards, 'milliBalances': milliBalances,
    'isPaused': isPaused,
  };

  factory MatchState.fromJson(Map<String, dynamic> data) => MatchState(
    settings: MatchSettings.fromJson(Map<String, dynamic>.from(data['settings'] as Map)),
    teams: (data['teams'] as List).cast<String>(),
    scores: (data['scores'] as List).cast<int>(),
    holder: data['holder'] as int,
    phase: RoundPhase.values.byName(data['phase'] as String),
    cards: (data['cards'] as List).map((list) => (list as List).map(
      (name) => CardPower.values.byName(name as String)).toList()).toList(),
    nullifiers: (data['nullifiers'] as List).cast<int>(),
    secondsLeft: data['secondsLeft'] as int,
    emptyGuesses: data['emptyGuesses'] as int,
    freePoisonEmpty: data['freePoisonEmpty'] as bool,
    power: data['power'] == null ? null : CardPower.values.byName(data['power'] as String),
    prediction: data['prediction'] as bool?,
    phoenixReward: data['phoenixReward'] as int,
    crownOwner: data['crownOwner'] as int?,
    winner: data['winner'] as int?,
    hand: data['hand'] as int,
    offensiveUsed: (data['offensiveUsed'] as bool?) ?? false,
    defensiveUsed: (data['defensiveUsed'] as bool?) ?? false,
    shahLosses: ((data['shahLosses'] as List?) ?? [0,0]).cast<int>(),
    physicalCards: ((data['physicalCards'] as List?) ?? [[],[]])
      .map((e) => (e as List).cast<String>()).toList(),
    milliBalances: ((data['milliBalances'] as List?) ?? [0,0]).cast<int>(),
    isPaused: (data['isPaused'] as bool?) ?? false,
    note: data['note'] as String,
  );

  factory MatchState.start(MatchSettings settings, String teamA, String teamB, {int holder = 0}) {
    final initial = CardPower.values.toList();
    final seed=DateTime.now().microsecondsSinceEpoch;
    final physical= switch(settings.mode) {
      GameMode.filimo => [PhysicalCards.filimoDeck(seed), PhysicalCards.filimoDeck(seed+7)],
      GameMode.shahGol => [PhysicalCards.shahGolDeck(), PhysicalCards.shahGolDeck()],
      GameMode.nabardGol => <List<String>>[[],[]],
    };
    return MatchState(settings: settings, teams: [teamA, teamB], scores: [0, 0],
      holder: holder, phase: RoundPhase.guess,
      cards: [List.of(initial), List.of(initial)], nullifiers: [2, 2],
      secondsLeft: settings.turnSeconds,physicalCards:physical);
  }
}
