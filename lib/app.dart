import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class ObstetricApp extends StatelessWidget {
  const ObstetricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Obst Anesthesia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
