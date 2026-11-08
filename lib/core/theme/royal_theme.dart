import 'package:flutter/material.dart';

abstract final class RoyalTheme {
  static const night = Color(0xFF090E16);
  static const ink = Color(0xFF131B29);
  static const card = Color(0xFF1B2231);
  static const gold = Color(0xFFF0C47D);
  static const paleGold = Color(0xFFFFE6AD);
  static const burgundy = Color(0xFF812B48);
  static const teal = Color(0xFF126A64);
  static const azure = Color(0xFF265C8F);
  static const muted = Color(0xFF9EAAB9);

  static ThemeData get data {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: night,
      colorScheme: const ColorScheme.dark(
        primary: gold, secondary: teal, surface: ink, onSurface: Color(0xFFF7F1E8)),
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFFF7F1E8), displayColor: paleGold,
        fontFamily: 'sans-serif'),
      appBarTheme: const AppBarTheme(
        elevation: 0, backgroundColor: Colors.transparent, foregroundColor: paleGold,
        centerTitle: true, titleTextStyle: TextStyle(
          fontFamily: 'sans-serif', color: paleGold, fontWeight: FontWeight.w800, fontSize: 19)),
      dividerColor: Colors.white12,
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        labelStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 1.3))),
      sliderTheme: const SliderThemeData(activeTrackColor: gold, thumbColor: paleGold),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((state) => state.contains(WidgetState.selected) ? paleGold : muted),
        trackColor: WidgetStateProperty.resolveWith((state) => state.contains(WidgetState.selected) ? teal : card)),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: gold, foregroundColor: night,
        textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: paleGold, side: const BorderSide(color: Color(0xFF6B5A46)),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
    );
  }
}
