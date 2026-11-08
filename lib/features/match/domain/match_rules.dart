/// Standalone referee rules, independent of presentation and persistence.
/// The Shah Gol board game's exact copyrighted instructions are not reproduced.
enum GameMode { filimo, shahGol, nabardGol }
enum CardPower { doubleSword, hourglass, hunter, phoenix, poisonHand }
enum RoundPhase { guess, defendCard, predict, finalGuess, crownChoice, captainDuel, finished }

extension GameModeText on GameMode {
  String get title => switch (this) {
    GameMode.filimo => 'فیلیمو',
    GameMode.shahGol => 'شاه‌گل اصلی',
    GameMode.nabardGol => 'نبرد گل',
  };
  String get subtitle => switch (this) {
    GameMode.filimo => 'شکوه مسابقه تلویزیونی',
    GameMode.shahGol => 'مکعب، میلی و یک نبرد حساب‌شده',
    GameMode.nabardGol => 'پنج قدرت مخفی؛ بهای تاج',
  };
}

extension PowerText on CardPower {
  String get title => switch (this) {
    CardPower.doubleSword => 'شمشیر دولبه',
    CardPower.hourglass => 'ساعت شنی',
    CardPower.hunter => 'شکارچی',
    CardPower.phoenix => 'ققنوس',
    CardPower.poisonHand => 'دست سمی',
  };
  String get description => switch (this) {
    CardPower.doubleSword => 'کاپیتان نگهدارنده پیش‌بینی می‌کند گل گرفته می‌شود یا نه؛ حدس درست به نگهدارنده +۱، غلط به حدس‌زننده +۱.',
    CardPower.hourglass => 'نصف زمان، بدون خالی‌بازی، فقط یک انتخاب؛ درست +۴ برای حدس‌زننده، غلط +۲ برای نگهدارنده.',
    CardPower.hunter => 'یک بازیکن را انتخاب کن؛ گل در هر یک از دو دست او باشد، انتقال بدون امتیاز؛ وگرنه +۲ نگهدارنده.',
    CardPower.phoenix => 'حداقل ۳ امتیاز عقب باش؛ یافتن گل با هر روش +۳ / +۴ / +۵، شکست +۲ نگهدارنده.',
    CardPower.poisonHand => 'یک مشت را انتخاب کن؛ گل باشد انتقال بی‌امتیاز، خالی باشد همان مشت رایگان پوچ و بازی ادامه پیدا می‌کند.',
  };
  String get asset => 'assets/cards/${name}.svg';
}

class MatchSettings {
  const MatchSettings({
    required this.mode,
    this.target = 21,
    this.shahGolEnabled = true,
    this.filimoCubeEnabled = true,
    this.turnSeconds = 90,
    this.playersPerTeam = 3,
  }) : assert(target >= 8 && target <= 31),
       assert(turnSeconds >= 15),
       assert(playersPerTeam >= 1 && playersPerTeam <= 8);

  final GameMode mode;
  final int target;
  final bool shahGolEnabled;
  final bool filimoCubeEnabled;
  final int turnSeconds;
  final int playersPerTeam;
  int get shahThreshold => target - 1;
  int get scoreCap => shahGolEnabled ? shahThreshold : target;
  bool get canConfigureCube => mode == GameMode.filimo;

  Map<String, dynamic> toJson() => {
    'mode': mode.name, 'target': target, 'shahGolEnabled': shahGolEnabled,
    'filimoCubeEnabled': filimoCubeEnabled, 'turnSeconds': turnSeconds,
    'playersPerTeam': playersPerTeam,
  };

  factory MatchSettings.fromJson(Map<String, dynamic> json) => MatchSettings(
    mode: GameMode.values.byName(json['mode'] as String),
    target: json['target'] as int,
    shahGolEnabled: json['shahGolEnabled'] as bool,
    filimoCubeEnabled: json['filimoCubeEnabled'] as bool,
    turnSeconds: json['turnSeconds'] as int,
    playersPerTeam: (json['playersPerTeam'] as int?) ?? 3,
  );
}

abstract final class CustomRules {
  static const int maxEmptyGuesses = 3;
  static const int normalCapturePoints = 0;
  static const int firstStrikePoints = 2;
  static const int successfulDefensePoints = 1;
  static const int retreatPenalty = 3;
  static const int duelLossPenalty = 5;
  static const int nullifiersPerTeam = 2;
  static const int maxCardsPerTeamPerHand = 1;

  static int phoenixPoints(int deficit) {
    if (deficit < 3) throw ArgumentError('Phoenix requires 3+ point deficit.');
    if (deficit <= 5) return 3;
    if (deficit <= 9) return 4;
    return 5;
  }

  static int addPoints(int current, int earned, MatchSettings settings) =>
      (current + earned).clamp(0, settings.scoreCap).toInt();
}
