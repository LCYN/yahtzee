import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D44),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'LEADERBOARD',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query top 100 high scores ordered by score descending
        stream: FirebaseFirestore.instance
            .collection('leaderboard')
            .orderBy('score', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load leaderboard.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No high scores set yet!',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String name = data['name'] ?? 'Anonymous';
              final int score = (data['score'] ?? 0) as int;
              final int rank = index + 1;

              // Top 3 rank highlighting
              Color rankColor;
              Color tileColor;
              if (rank == 1) {
                rankColor = Colors.amber; // Gold
                tileColor = const Color(0xFF383526);
              } else if (rank == 2) {
                rankColor = const Color(0xFFC0C0C0); // Silver
                tileColor = const Color(0xFF2E3138);
              } else if (rank == 3) {
                rankColor = const Color(0xFFCD7F32); // Bronze
                tileColor = const Color(0xFF332B25);
              } else {
                rankColor = Colors.white38;
                tileColor = const Color(0xFF2D2D44);
              }

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(12),
                  border: rank <= 3
                      ? Border.all(color: rankColor.withOpacity(0.3), width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    // Rank Number (#1, #2, #3...)
                    SizedBox(
                      width: 45,
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          color: rankColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Player Name
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Score
                    Text(
                      '$score pts',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}