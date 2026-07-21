import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/game_state.dart'; // Adjust import to your GameState file location

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D44),
        elevation: 0,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D44),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        game.isSoundEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: game.isSoundEnabled
                            ? const Color(0xFF6C5CE7)
                            : Colors.white38,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sound Effects',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            game.isSoundEnabled ? 'On' : 'Off',
                            style: TextStyle(
                              color: game.isSoundEnabled
                                  ? Colors.greenAccent
                                  : Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: game.isSoundEnabled,
                    activeColor: const Color(0xFF6C5CE7),
                    onChanged: (bool value) {
                      context.read<GameState>().toggleSound(value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}