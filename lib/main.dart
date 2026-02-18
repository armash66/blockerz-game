import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'core/app_theme.dart';

import 'core/audio_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AudioManager().startMusic();
  runApp(const BlockerzApp());
}

class BlockerzApp extends StatelessWidget {
  const BlockerzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blockerz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const HomeScreen(),
    );
  }
}
