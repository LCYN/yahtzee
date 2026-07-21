import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import 'main_home_screen.dart';
import 'models/game_state.dart';
import 'services/leaderboard_service.dart';
import 'leaderboard_page.dart';
import 'settings_page.dart';



class GamePage extends StatelessWidget {
  const GamePage({super.key});

  // Helper function to check and open high score dialog
  void _onCategorySelected(BuildContext context, GameState game) {
    //if (game.isGameOver && game.grandTotal > 200) {
    if (game.isGameOver && game.grandTotal > 50) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddHighScoreDialog(context, game.grandTotal);
      });
    }
  }

  @override
  
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'YAHTZEE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Restart Game',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              _showConfirmDialog(
                context,
                title: 'Restart Game?',
                content: 'Are you sure you want to reset your current progress?',
                onConfirm: () => game.resetGame(),
              );
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded, color: Colors.white70),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Leaderboard',
            icon: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LeaderboardPage(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Back to Home',
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            onPressed: () {
              _showConfirmDialog(
                context,
                title: 'Exit to Home?',
                content: 'Your current game progress will be lost.',
                onConfirm: () => Navigator.of(context).pop(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _UpperSectionInfo(),
            Expanded(
              child: _MiddleSectionScoreboard(
                onCategorySelected: () => _onCategorySelected(context, game),
              ),
            ),
            const _LowerSectionControls(),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddHighScoreDialog(BuildContext context, int score) {
    final TextEditingController nameController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2D2D44),
            title: const Text(
              '🎉 HIGH SCORE!',
              style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You scored $score points! Enter your name for the leaderboard:',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Your Name',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1E1E2C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Skip', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        setState(() => isSubmitting = true);
                        await LeaderboardService.addScore(
                          nameController.text,
                          score,
                        );
                        if (context.mounted) {
                          Navigator.of(ctx).pop(); // Close dialog
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LeaderboardPage(),
                            ),
                          );
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLeaderboardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D44),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '🏆 Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<LeaderboardEntry>>(
                stream: LeaderboardService.getTopScores(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No high scores yet. Be the first!',
                          style: TextStyle(color: Colors.white60)),
                    );
                  }

                  final entries = snapshot.data!;

                  return ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final rank = index + 1;

                      Color rankColor = Colors.white;
                      if (rank == 1) rankColor = const Color(0xFFFFD700);
                      else if (rank == 2) rankColor = const Color(0xFFC0C0C0);
                      else if (rank == 3) rankColor = const Color(0xFFCD7F32);

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: rankColor.withOpacity(0.2),
                          child: Text(
                            '#$rank',
                            style: TextStyle(
                                color: rankColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          entry.name,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          '${entry.score} pts',
                          style: const TextStyle(
                            color: Color(0xFF00B894),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// UPPER SECTION: GAME INFORMATION
// ==========================================
class _UpperSectionInfo extends StatelessWidget {
  const _UpperSectionInfo();

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoTile('Round', '${game.currentRound} / 13'),
          _buildInfoTile('Rolls Left', '${game.rollsRemaining}'),
          _buildInfoTile('Bonus Progress', '${game.upperSectionScore} / 63'),
          _buildInfoTile('Total Score', '${game.grandTotal}', highlight: true),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {bool highlight = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: highlight ? const Color(0xFF00CEC9) : Colors.white,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// MIDDLE SECTION: SCOREBOARD TABLE
// ==========================================
class _MiddleSectionScoreboard extends StatelessWidget {
  final VoidCallback onCategorySelected;

  const _MiddleSectionScoreboard({
    super.key,
    required this.onCategorySelected,
  });

  static const List<ScoreCategory> _upperCategories = [
    ScoreCategory.ones,
    ScoreCategory.twos,
    ScoreCategory.threes,
    ScoreCategory.fours,
    ScoreCategory.fives,
    ScoreCategory.sixes,
  ];

  static const List<ScoreCategory> _lowerCategories = [
    ScoreCategory.threeOfAKind,
    ScoreCategory.fourOfAKind,
    ScoreCategory.fullHouse,
    ScoreCategory.smallStraight,
    ScoreCategory.largeStraight,
    ScoreCategory.yahtzee,
  ];

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    int lowerTotal = 0;
    for (var cat in [..._lowerCategories, ScoreCategory.chance]) {
      lowerTotal += game.scores[cat] ?? 0;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _ScoreCard(
                title: 'Upper Section',
                categories: _upperCategories,
                game: game,
                totalScore: game.upperSectionScore + (game.hasUpperBonus ? 35 : 0),
                isUpper: true,
                onCategorySelected: onCategorySelected,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ScoreCard(
                title: 'Lower Section',
                categories: _lowerCategories,
                game: game,
                totalScore: lowerTotal,
                isUpper: false,
                onCategorySelected: onCategorySelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// UNIFIED FIXED-HEIGHT SCORE CARD
// ==========================================
class _ScoreCard extends StatelessWidget {
  final String title;
  final List<ScoreCategory> categories;
  final GameState game;
  final int totalScore;
  final bool isUpper;
  final VoidCallback onCategorySelected;

  const _ScoreCard({
    required this.title,
    required this.categories,
    required this.game,
    required this.totalScore,
    required this.isUpper,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFFA29BFE),
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF252538),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      ...List.generate(categories.length, (index) {
                        final cat = categories[index];
                        return _FixedRowWrapper(
                          child: _ScoreRowItem(
                            category: cat,
                            game: game,
                            isEven: index % 2 == 0,
                            onCategorySelected: onCategorySelected,
                          ),
                        );
                      }),
                      _FixedRowWrapper(
                        child: isUpper
                            ? _buildBonusRow(game)
                            : _ScoreRowItem(
                                category: ScoreCategory.chance,
                                game: game,
                                isEven: false,
                                onCategorySelected: onCategorySelected,
                              ),
                      ),
                    ],
                  ),
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$totalScore',
                          style: const TextStyle(
                            color: Color(0xFF00B894),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusRow(GameState game) {
    return Container(
      color: Colors.white.withOpacity(0.02),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Bonus',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            '${game.upperSectionScore}/63',
            style: const TextStyle(
              color: Color(0xFFA29BFE),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _FixedRowWrapper extends StatelessWidget {
  final Widget child;

  const _FixedRowWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: child,
    );
  }
}

// ==========================================
// SCORE ROW ITEM
// ==========================================
class _ScoreRowItem extends StatelessWidget {
  final ScoreCategory category;
  final GameState game;
  final bool isEven;
  final VoidCallback onCategorySelected;

  const _ScoreRowItem({
    super.key,
    required this.category,
    required this.game,
    required this.isEven,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final score = game.scores[category];
    final isUsed = score != null;
    final previewScore = (game.rollsRemaining < 3 && !isUsed)
        ? game.calculateScore(category, game.dice)
        : null;

    final isClickable = !isUsed && game.rollsRemaining < 3;

    return InkWell(
      onTap: isClickable
          ? () {
              game.selectCategory(category);
              onCategorySelected();
            }
          : null,
      child: Container(
        color: isEven ? Colors.white.withOpacity(0.02) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CategoryIconBadge(category: category),
            Container(
              width: 32,
              height: 22,
              decoration: BoxDecoration(
                color: isUsed
                    ? const Color(0xFF1E1E2C)
                    : (previewScore != null
                        ? const Color(0xFF00B894).withOpacity(0.2)
                        : const Color(0xFF1E1E2C)),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: (previewScore != null && !isUsed)
                      ? const Color(0xFF00B894)
                      : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  isUsed
                      ? '$score'
                      : (previewScore != null ? '$previewScore' : ''),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isUsed
                        ? Colors.grey[400]
                        : (previewScore != null
                            ? const Color(0xFF00B894)
                            : Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// CATEGORY BADGES
// ==========================================
class _CategoryIconBadge extends StatelessWidget {
  final ScoreCategory category;

  const _CategoryIconBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case ScoreCategory.ones:
        return const _MiniDiceBadge(value: 1);
      case ScoreCategory.twos:
        return const _MiniDiceBadge(value: 2);
      case ScoreCategory.threes:
        return const _MiniDiceBadge(value: 3);
      case ScoreCategory.fours:
        return const _MiniDiceBadge(value: 4);
      case ScoreCategory.fives:
        return const _MiniDiceBadge(value: 5);
      case ScoreCategory.sixes:
        return const _MiniDiceBadge(value: 6);
      case ScoreCategory.threeOfAKind:
        return const _BadgeContainer(child: _TextBadgeContent('3x'));
      case ScoreCategory.fourOfAKind:
        return const _BadgeContainer(child: _TextBadgeContent('4x'));
      case ScoreCategory.fullHouse:
        return const _BadgeContainer(child: _FullHouseBadge());
      case ScoreCategory.smallStraight:
        return const _BadgeContainer(child: _StraightBadge(count: 4));
      case ScoreCategory.largeStraight:
        return const _BadgeContainer(child: _StraightBadge(count: 5));
      case ScoreCategory.yahtzee:
        return const _BadgeContainer(child: _YahtzeeBadge());
      case ScoreCategory.chance:
        return const _BadgeContainer(child: _TextBadgeContent('?'));
    }
  }
}

class _BadgeContainer extends StatelessWidget {
  final Widget child;

  const _BadgeContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D5C),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Center(child: child),
    );
  }
}

class _TextBadgeContent extends StatelessWidget {
  final String text;

  const _TextBadgeContent(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 11,
      ),
    );
  }
}

class _FullHouseBadge extends StatelessWidget {
  const _FullHouseBadge();

  Widget _miniSquare() {
    return Container(
      width: 4.5,
      height: 4.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _miniSquare(),
            const SizedBox(width: 1.5),
            _miniSquare(),
            const SizedBox(width: 1.5),
            _miniSquare(),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _miniSquare(),
            const SizedBox(width: 2),
            _miniSquare(),
          ],
        ),
      ],
    );
  }
}

class _StraightBadge extends StatelessWidget {
  final int count;

  const _StraightBadge({required this.count});

  Widget _miniSquare() {
    return Container(
      width: 3.5,
      height: 3.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 9,
                height: 1,
              ),
            ),
            const Icon(
              Icons.arrow_right_alt_rounded,
              size: 10,
              color: Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            count,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.5),
              child: _miniSquare(),
            ),
          ),
        ),
      ],
    );
  }
}

class _YahtzeeBadge extends StatelessWidget {
  const _YahtzeeBadge();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.15,
      child: const Text(
        'Yahtzee',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 6.5,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _MiniDiceBadge extends StatelessWidget {
  final int value;

  const _MiniDiceBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D5C),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: _buildDotGrid(value),
      ),
    );
  }

  Widget _buildDotGrid(int val) {
    final dot = Container(
      width: 3.5,
      height: 3.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );

    final empty = const SizedBox(width: 3.5, height: 3.5);

    List<Widget> dots = [];
    switch (val) {
      case 1:
        dots = [empty, empty, empty, empty, dot, empty, empty, empty, empty];
        break;
      case 2:
        dots = [dot, empty, empty, empty, empty, empty, empty, empty, dot];
        break;
      case 3:
        dots = [dot, empty, empty, empty, dot, empty, empty, empty, dot];
        break;
      case 4:
        dots = [dot, empty, dot, empty, empty, empty, dot, empty, dot];
        break;
      case 5:
        dots = [dot, empty, dot, empty, dot, empty, dot, empty, dot];
        break;
      case 6:
        dots = [dot, empty, dot, dot, empty, dot, dot, empty, dot];
        break;
    }

    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      children: dots,
    );
  }
}

// ==========================================
// LOWER SECTION: CONTROLS & DICE
// ==========================================
class _LowerSectionControls extends StatefulWidget {
  const _LowerSectionControls();

  @override
  State<_LowerSectionControls> createState() => _LowerSectionControlsState();
}

class _LowerSectionControlsState extends State<_LowerSectionControls> {
  final Random _random = Random();
  final AudioPlayer _player = AudioPlayer();

  List<int> _displayValues = [1, 1, 1, 1, 1];
  List<double> _angles = [0.0, 0.0, 0.0, 0.0, 0.0];
  bool _isRolling = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _rollDice(GameState game) async {
    if (game.rollsRemaining <= 0 || game.isGameOver || _isRolling) return;

    setState(() {
      _isRolling = true;
    });

    if (game.isSoundEnabled) {
      try {
        await _player.setAsset('assets/audios/rolling-dice.mp3');
        _player.play();
      } catch (_) {}
    }

    int counter = 1;
    Timer.periodic(const Duration(milliseconds: 70), (timer) {
      counter++;

      setState(() {
        for (int i = 0; i < 5; i++) {
          if (!game.lockedDice[i]) {
            _displayValues[i] = _random.nextInt(6) + 1;
            _angles[i] = _random.nextDouble() * pi;
          }
        }
      });

      if (counter >= 13) {
        timer.cancel();

        final finalDice = List<int>.generate(
          5,
          (i) => game.lockedDice[i] ? game.dice[i] : _displayValues[i],
        );

        game.setDiceValues(finalDice);
        game.rollDice();

        setState(() {
          _isRolling = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    if (!_isRolling) {
      for (int i = 0; i < 5; i++) {
        _displayValues[i] = game.dice[i];
        _angles[i] = 0.0;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final isLocked = game.lockedDice[index];

              return GestureDetector(
                onTap: _isRolling ? null : () => game.toggleLockDie(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  transform: Matrix4.translationValues(0, isLocked ? -10 : 0, 0),
                  child: Transform.rotate(
                    angle: _angles[index],
                    child: DiceWidget(
                      value: _displayValues[index],
                      isLocked: isLocked,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 180,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  disabledBackgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: (game.rollsRemaining > 0 && !game.isGameOver && !_isRolling)
                    ? () => _rollDice(game)
                    : null,
                child: Text(
                  _isRolling
                      ? 'ROLLING...'
                      : (game.rollsRemaining == 3
                          ? 'FIRST ROLL'
                          : 'ROLL (${game.rollsRemaining})'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiceWidget extends StatelessWidget {
  final int value;
  final bool isLocked;

  const DiceWidget({
    super.key,
    required this.value,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFF6C5CE7) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLocked ? Colors.white : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isLocked
                ? const Color(0xFF6C5CE7).withOpacity(0.5)
                : Colors.black.withOpacity(0.25),
            blurRadius: isLocked ? 8 : 4,
            offset: Offset(0, isLocked ? 4 : 2),
          ),
        ],
      ),
      child: _buildPips(context),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 8.5,
      height: 8.5,
      decoration: BoxDecoration(
        color: isLocked ? Colors.white : Colors.black87,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPips(BuildContext context) {
    switch (value) {
      case 1:
        return Center(child: _buildDot());
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [_buildDot()]),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [_buildDot()]),
          ],
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [_buildDot()]),
            Center(child: _buildDot()),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [_buildDot()]),
          ],
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildDot(), _buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildDot(), _buildDot()],
            ),
          ],
        );
      case 5:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildDot(), _buildDot()],
            ),
            Center(child: _buildDot()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildDot(), _buildDot()],
            ),
          ],
        );
      case 6:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildDot(), _buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildDot(), _buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildDot(), _buildDot()],
            ),
          ],
        );
      default:
        return Center(child: _buildDot());
    }
  }
}