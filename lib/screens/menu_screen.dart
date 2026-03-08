import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../models/game_manager.dart';

class SelectDifficultyScreen extends StatelessWidget {
  const SelectDifficultyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select difficulty')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                GameManager.instance.setDifficulty(Difficulty.noob);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const GameScreen(resetScores: true),
                  ),
                );
              },
              child: const Text('Noob'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                GameManager.instance.setDifficulty(Difficulty.notNoob);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const GameScreen(resetScores: true),
                  ),
                );
              },
              child: const Text('Not Noob'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                GameManager.instance.setDifficulty(Difficulty.pro);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const GameScreen(resetScores: true),
                  ),
                );
              },
              child: const Text('Pro'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pong')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pong', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SelectDifficultyScreen(),
                  ),
                );
              },
              child: const Text('New Game'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const GameScreen(resetScores: false),
                  ),
                );
              },
              child: const Text('Continue'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Quit'),
            ),
          ],
        ),
      ),
    );
  }
}
