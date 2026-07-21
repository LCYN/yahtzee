import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String id;
  final String name;
  final int score;
  final DateTime timestamp;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.score,
    required this.timestamp,
  });

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LeaderboardEntry(
      id: doc.id,
      name: data['name'] ?? 'Anonymous',
      score: (data['score'] as num?)?.toInt() ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name.trim().isEmpty ? 'Anonymous' : name.trim(),
      'score': score,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class LeaderboardService {
  static final CollectionReference _scoresCollection =
      FirebaseFirestore.instance.collection('leaderboard');

  /// Fetches top N scores in real time sorted by highest score
  static Stream<List<LeaderboardEntry>> getTopScores({int limit = 10}) {
    return _scoresCollection
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaderboardEntry.fromFirestore(doc))
            .toList());
  }

  /// Writes a new score document to Firestore
  static Future<void> addScore(String name, int score) async {
    final entry = LeaderboardEntry(
      id: '',
      name: name,
      score: score,
      timestamp: DateTime.now(),
    );
    await _scoresCollection.add(entry.toFirestore());
  }
}