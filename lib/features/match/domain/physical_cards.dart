/// Reference cards of physical game modes.
/// Visual artwork is original. Rule statements that vary by kit should be
/// confirmed with the players' printed rulebook before applying points.
class PhysicalCard {
  const PhysicalCard(this.id, this.title, this.asset, this.instructions);
  final String id;
  final String title;
  final String asset;
  final String instructions;
}

abstract final class PhysicalCards {
  static const all = <String,PhysicalCard>{
    'antenna': PhysicalCard('antenna','آنتن','assets/cards/filimo_anten.svg',
      'تیم حدس‌زننده از یک نفر از حریف یک سؤال بله/خیر می‌پرسد؛ پاسخ باید راست باشد.'),
    'duel': PhysicalCard('duel','دوئل','assets/cards/filimo_duel.svg',
      'صاحب گل آن را نشان می‌دهد و وارد رقابت تک‌به‌تک می‌شود.'),
    'largeSphere': PhysicalCard('largeSphere','گوی بزرگ','assets/cards/filimo_largeSphere.svg',
      'تیم نگهدارنده برای دست بعد با گوی بزرگ‌تر بازی می‌کند.'),
    'soundSphere': PhysicalCard('soundSphere','گوی صدادار','assets/cards/filimo_soundSphere.svg',
      'تیم نگهدارنده باید از گوی صدادار استفاده کند.'),
    'doubleSight': PhysicalCard('doubleSight','یک تیر و دو نشان','assets/cards/filimo_doubleSight.svg',
      'پس از پوچ کردن درست یک مشت، سرگروه حریف یک مشت دیگر را پوچ می‌کند.'),
    'extraEmpty': PhysicalCard('extraEmpty','سه خالی مجدد','assets/cards/filimo_threeEmpty.svg',
      'سه فرصت خالی‌بازی دوباره به تیم حدس‌زننده می‌دهد.'),
    'eliminateFist': PhysicalCard('eliminateFist','حذف یک دست','assets/cards/filimo_empty.svg',
      'سرگروه تیم نگهدارنده یک مشت خالی از تیم خودش را باز می‌کند.'),
    'sparrow1': PhysicalCard('sparrow1','سنگ مفت، گنجشک مفت','assets/cards/filimo_sparrow.svg',
      'در این کارت طبق نسخه فیزیکی یک فرصت اضافه پس از اشتباه وجود دارد.'),
    'sparrow2': PhysicalCard('sparrow2','سنگ مفت، گنجشک مفت','assets/cards/filimo_sparrow.svg',
      'در این کارت طبق نسخه فیزیکی یک فرصت اضافه پس از اشتباه وجود دارد.'),
    'shahKesh': PhysicalCard('shahKesh','شاه‌کش','assets/cards/shah_shahkesh.svg',
      'اثر دقیق و هزینه میلی را با دفترچه شاه‌گل بررسی کنید.'),
    'nazeshast': PhysicalCard('nazeshast','نازشست','assets/cards/shah_nazeshost.svg',
      'اثر دقیق و هزینه میلی را با دفترچه شاه‌گل بررسی کنید.'),
    'roodast': PhysicalCard('roodast','رو دست','assets/cards/shah_roodast.svg',
      'اثر دقیق و هزینه میلی را با دفترچه شاه‌گل بررسی کنید.'),
    'bakhtak': PhysicalCard('bakhtak','بختک','assets/cards/shah_bakhtak.svg',
      'اثر دقیق و هزینه میلی را با دفترچه شاه‌گل بررسی کنید.'),
    'taftish': PhysicalCard('taftish','تفتیش','assets/cards/shah_taftish.svg',
      'اثر دقیق و هزینه میلی را با دفترچه شاه‌گل بررسی کنید.'),
  };

  static List<String> filimoDeck(int seed) {
    // Five independent card slots: one duel/antenna, one orb,
    // and three of the five central-card slots.
    final primary = seed.isEven ? 'antenna' : 'duel';
    final secondary = seed % 3 == 0 ? 'largeSphere' : 'soundSphere';
    final middle = <String>['doubleSight','extraEmpty','eliminateFist','sparrow1','sparrow2'];
    for (var i = middle.length - 1; i > 0; i--) {
      final j = (seed + 7 * i) % (i + 1);
      final t = middle[i];
      middle[i] = middle[j];
      middle[j] = t;
    }
    return [primary, secondary, ...middle.take(3)];
  }

  static List<String> shahGolDeck() => [
    'shahKesh','nazeshast','roodast','bakhtak','taftish',
  ];
}
