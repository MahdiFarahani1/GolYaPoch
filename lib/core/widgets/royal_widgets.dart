import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/royal_theme.dart';

class RoyalScaffold extends StatelessWidget {
  const RoyalScaffold({super.key, required this.child, this.appBar, this.floatingActionButton});
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  @override Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true, backgroundColor: RoyalTheme.night,
    appBar: appBar, floatingActionButton: floatingActionButton,
    body: Stack(children: [
      const Positioned.fill(child: CustomPaint(painter: RoyalBackgroundPainter())),
      SafeArea(child: child),
    ]),
  );
}

class RoyalBackgroundPainter extends CustomPainter {
  const RoyalBackgroundPainter();
  @override void paint(Canvas canvas, Size size) {
    final bg = Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF1B2233), Color(0xFF0C111A), Color(0xFF080B12)],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);
    final glow = Paint()..shader = RadialGradient(
      colors: [RoyalTheme.gold.withValues(alpha: .12), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(size.width * .5, size.height * .08), radius: size.width * .75));
    canvas.drawRect(Offset.zero & size, glow);
    final line = Paint()..color = RoyalTheme.gold.withValues(alpha: .07)..strokeWidth = 1..style = PaintingStyle.stroke;
    for (var i = 0; i < 9; i++) {
      final center = Offset(size.width / 2, size.height * .32);
      canvas.drawCircle(center, 115 + i * 48, line);
    }
    for (var i = 0; i < 16; i++) {
      final x = (i * 71.0 + 19) % size.width;
      final y = (i * 137.0 + 26) % size.height;
      canvas.drawCircle(Offset(x,y), i.isEven ? 1.5 : 1, Paint()..color = RoyalTheme.gold.withValues(alpha: .18));
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoyalPanel extends StatelessWidget {
  const RoyalPanel({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.highlight = false});
  final Widget child;
  final EdgeInsets padding;
  final bool highlight;
  @override Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft,
        colors: [Color(0xFF253044), Color(0xFF131A26)]),
      border: Border.all(color: highlight ? RoyalTheme.gold.withValues(alpha: .7) : RoyalTheme.gold.withValues(alpha: .18)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .22), blurRadius: 20, offset: const Offset(0, 9))]),
    child: child);
}

class RoyalSectionTitle extends StatelessWidget {
  const RoyalSectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(children: [
      const Icon(Icons.diamond_outlined, color: RoyalTheme.gold, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
      if (trailing != null) trailing!,
    ]));
}

class CrownArt extends StatelessWidget {
  const CrownArt({super.key, this.size = 88, this.color = RoyalTheme.gold});
  final double size;
  final Color color;
  @override Widget build(BuildContext context) => SizedBox(
    width: size, height: size,
    child: CustomPaint(painter: CrownPainter(color)));
}

class CrownPainter extends CustomPainter {
  const CrownPainter(this.color);
  final Color color;
  @override void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()..moveTo(w*.13,h*.34)..lineTo(w*.30,h*.59)
      ..lineTo(w*.44,h*.23)..lineTo(w*.57,h*.59)..lineTo(w*.85,h*.32)
      ..lineTo(w*.76,h*.78)..lineTo(w*.21,h*.78)..close();
    canvas.drawPath(path, Paint()..shader = LinearGradient(
      colors: [color, const Color(0xFF95612D), const Color(0xFFFFE4A4)])
      .createShader(Offset.zero & size));
    canvas.drawPath(path, Paint()..color = const Color(0xFF5D391C)..style = PaintingStyle.stroke..strokeWidth=1.4);
    for (final p in [Offset(w*.13,h*.32), Offset(w*.44,h*.22), Offset(w*.85,h*.30)]) {
      canvas.drawCircle(p, w*.045, Paint()..color = const Color(0xFFFFE3A0));
    }
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.21,h*.72,w*.55,h*.13), Radius.circular(w*.04)),
      Paint()..color=const Color(0xFFD8A44D));
    canvas.drawCircle(Offset(w*.49,h*.68), w*.055, Paint()..color=RoyalTheme.burgundy);
  }
  @override bool shouldRepaint(covariant CrownPainter oldDelegate) => oldDelegate.color != color;
}

class RoyalDivider extends StatelessWidget {
  const RoyalDivider({super.key});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(children: [
      const Expanded(child: Divider(color: Color(0xFF725F43))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: RoyalTheme.gold)))),
      const Expanded(child: Divider(color: Color(0xFF725F43))),
    ]));
}
