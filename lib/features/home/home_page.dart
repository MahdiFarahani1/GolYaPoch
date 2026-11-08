import 'package:flutter/material.dart';
import '../../core/theme/royal_theme.dart';
import '../../core/widgets/royal_widgets.dart';
import '../match/data/match_store.dart';
import '../match/domain/match_rules.dart';
import '../match/domain/match_state.dart';
import '../match/presentation/match_page.dart';
import '../match/presentation/setup_page.dart';
import '../guide/guide_page.dart';
import '../history/history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override Widget build(BuildContext context) => RoyalScaffold(
    child: ListView(padding: const EdgeInsets.fromLTRB(20, 15, 20, 36), children: [
      Row(children: [
        const CrownArt(size: 49),
        const SizedBox(width: 10),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('گُل یا پوچ', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: RoyalTheme.paleGold)),
          Text('ROYAL NOIR  •  شب شاهانه', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: RoyalTheme.muted)),
        ])),
        IconButton(tooltip: 'تاریخچه مسابقات', onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const HistoryPage())), icon: const Icon(Icons.military_tech_outlined, color: RoyalTheme.gold)),
      ]),
      const SizedBox(height: 28),
      RoyalPanel(highlight: true, child: Column(children: [
        const CrownArt(size: 118),
        const Text('میدان نبرد آماده است', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('سه میدان، سه قانون، یک برنده', textAlign: TextAlign.center,
          style: TextStyle(color: RoyalTheme.muted)),
        const SizedBox(height: 18),
        FutureBuilder<MatchState?>(
          future: MatchStore().load(),
          builder: (context, snapshot) {
            final saved = snapshot.data;
            if (saved == null || saved.isFinished) return const SizedBox.shrink();
            return OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
                MatchPage(initial: saved))),
              icon: const Icon(Icons.play_circle_outline), label: const Text('ادامه مسابقه ذخیره‌شده'));
          }),
      ])),
      const SizedBox(height: 24),
      const RoyalSectionTitle('میدان مسابقه را انتخاب کن'),
      _ModeTile(mode: GameMode.filimo, color: RoyalTheme.azure, icon: Icons.live_tv_rounded,
        label: 'استودیوی فیلیمو', detail: 'نور صحنه • مکعب اختیاری • داوری'),
      const SizedBox(height: 13),
      _ModeTile(mode: GameMode.shahGol, color: RoyalTheme.teal, icon: Icons.casino_outlined,
        label: 'تالار شاه‌گل', detail: 'مکعب اصلی • میلی • کارت‌های ویژه'),
      const SizedBox(height: 13),
      _ModeTile(mode: GameMode.nabardGol, color: RoyalTheme.burgundy, icon: Icons.shield_moon_outlined,
        label: 'نبرد گل', detail: 'هفت کارت اختصاصی • دوئل بهای تاج'),
      const SizedBox(height: 25),
      RoyalPanel(child: Row(children: [
        const Icon(Icons.menu_book_rounded, color: RoyalTheme.gold, size: 38),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('آموزش پیش از مسابقه', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          SizedBox(height: 4),
          Text('قوانین، کارت‌ها و شیوه امتیازگیری هر حالت', style: TextStyle(color: RoyalTheme.muted, fontSize: 12)),
        ])),
        IconButton(onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const GuidePage())), icon: const Icon(Icons.arrow_back_ios_new, color: RoyalTheme.gold)),
      ])),
      const SizedBox(height: 24),
      const Text('بدون اینترنت • بدون حساب کاربری • ثبت مسابقه روی همین دستگاه',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: RoyalTheme.muted)),
    ]),
  );
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({required this.mode, required this.color, required this.icon, required this.label, required this.detail});
  final GameMode mode;
  final Color color;
  final IconData icon;
  final String label, detail;
  @override Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SetupPage(mode: mode))),
      child: Ink(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(colors: [color.withValues(alpha: .65), RoyalTheme.ink],
            begin: Alignment.topRight, end: Alignment.bottomLeft),
          border: Border.all(color: color.withValues(alpha: .75))),
        child: Row(children: [
          Container(height: 68, width: 68, decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19), color: Colors.black.withValues(alpha: .22),
            border: Border.all(color: RoyalTheme.gold.withValues(alpha: .25))),
            child: Icon(icon, size: 34, color: RoyalTheme.paleGold)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(detail, style: const TextStyle(color: Color(0xFFD1D2D5), fontSize: 11)),
          ])),
          const Icon(Icons.arrow_back_ios_new_rounded, color: RoyalTheme.gold, size: 18),
        ]),
      )),
  );
}
