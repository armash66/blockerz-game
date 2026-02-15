import 'package:flutter/material.dart';

class ModeSelectScreen extends StatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen> {
  int _gameMode = 0; // 0: PvP, 1: PvAI
  bool _powerupsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Game')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Mode',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ToggleButtons(
              isSelected: [_gameMode == 0, _gameMode == 1],
              onPressed: (int index) {
                setState(() {
                  _gameMode = index;
                });
              },
              children: const [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Player vs Player')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Player vs AI')),
              ],
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: const Text('Enable Powerups'),
              subtitle: const Text('Adds special abilities to the game'),
              value: _powerupsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _powerupsEnabled = value;
                });
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Game Screen coming next!')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('START GAME'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
