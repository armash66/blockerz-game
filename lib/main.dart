import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'core/app_theme.dart';

void main() {
  runApp(const BlockerzApp());
}

class BlockerzApp extends StatelessWidget {
  const BlockerzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blockerz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
