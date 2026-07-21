import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_page.dart';
import 'leaderboard_page.dart';
import 'models/game_state.dart';
import 'settings_page.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // HEADER / LOGO SECTION
              Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.casino,
                      size: 72,
                      color: Color(0xFF6C5CE7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'YAHTZEE',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Classic Mobile Dice Game',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),

              // MAIN MENU BUTTONS
              Column(
                children: [
                  // START GAME BUTTON
                  _MenuButton(
                    label: 'START GAME',
                    icon: Icons.play_arrow_rounded,
                    isPrimary: true,
                    onPressed: () {
                      // Navigate to the main Yahtzee game page
                      context.read<GameState>().resetGame();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          
                          builder: (context) => GamePage(key: UniqueKey()), // Your existing game board page
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // LEADERBOARD BUTTON
                  _MenuButton(
                    label: 'LEADERBOARD',
                    icon: Icons.leaderboard_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LeaderboardPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // SETTINGS BUTTON
                  _MenuButton(
                    label: 'SETTINGS',
                    icon: Icons.settings_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // FOOTER / VERSION
              Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LEADERBOARD DIALOG ---

  // --- SETTINGS DIALOG ---
  void _showSettingsDialog(BuildContext context) {
    bool soundEnabled = true;
    bool vibrationEnabled = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2D2D44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.settings, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Settings', style: TextStyle(color: Colors.white)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    activeColor: const Color(0xFF6C5CE7),
                    title: const Text('Sound Effects', style: TextStyle(color: Colors.white)),
                    value: soundEnabled,
                    onChanged: (val) {
                      setDialogState(() => soundEnabled = val);
                    },
                  ),
                  SwitchListTile(
                    activeColor: const Color(0xFF6C5CE7),
                    title: const Text('Haptic Vibration', style: TextStyle(color: Colors.white)),
                    value: vibrationEnabled,
                    onChanged: (val) {
                      setDialogState(() => vibrationEnabled = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('DONE', style: TextStyle(color: Color(0xFFA29BFE))),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ==========================================
// REUSABLE MENU BUTTON WIDGET
// ==========================================
class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF6C5CE7) : const Color(0xFF2D2D44),
          foregroundColor: Colors.white,
          elevation: isPrimary ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: Colors.white12, width: 1),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: isPrimary ? Colors.white : const Color(0xFFA29BFE)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}