import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/royal_theme.dart';
import 'features/home/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GolYaPochApp());
}

class GolYaPochApp extends StatelessWidget {
  const GolYaPochApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'گل یا پوچ',
        debugShowCheckedModeBanner: false,
        locale: const Locale('fa'),
        supportedLocales: const [Locale('fa')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: RoyalTheme.data,
        home: const HomePage(),
      );
}
