import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BlockerzApp());
}

class BlockerzApp extends StatelessWidget {
  const BlockerzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blockerz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
