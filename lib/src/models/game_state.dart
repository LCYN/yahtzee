import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ScoreCategory {
  ones,
  twos,
  threes,
  fours,
  fives,
  sixes,
  threeOfAKind,
  fourOfAKind,
  fullHouse,
  smallStraight,
  largeStraight,
  yahtzee,
  chance,
}

class GameState extends ChangeNotifier {
  final SharedPreferences prefs;
  late bool _isSoundEnabled;

  GameState({required this.prefs}) {
    // Read the saved setting synchronously (defaults to true if not set yet)
    _isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
  }

  bool get isSoundEnabled => _isSoundEnabled;

  // Toggle sound setting and save to device
  Future<void> toggleSound(bool value) async {
    _isSoundEnabled = value;
    notifyListeners(); // Updates UI immediately
    await prefs.setBool('isSoundEnabled', value);
  }
  // Helper method to play audio only if sound is toggled ON
  void playSoundEffect(String soundPath) {
    if (!_isSoundEnabled) return; // Silent if sound is OFF
    // Your audio player code here (e.g. Flame Audio, audioplayers, etc.)
  }
  List<int> dice = [1, 1, 1, 1, 1];
  List<bool> lockedDice = [false, false, false, false, false];
  Map<ScoreCategory, int> scores = {};
  
  int rollsRemaining = 3;
  int yahtzeeBonusCount = 0;

  // Getters
  int get currentRound => (scores.length >= 13) ? 13 : scores.length + 1;
  bool get isGameOver => scores.length >= 13;
  bool get isCurrentRollYahtzee => dice.length == 5 && dice.every((d) => d == dice[0]);
  int? get yahtzeeScore => scores[ScoreCategory.yahtzee];
  bool get hasScoredYahtzee50 => yahtzeeScore == 50;
  
  int get totalScore => grandTotal; // Alias getter for UI compatibility

  // ==========================================
  // 1. ROLL DICE (Guaranteed to decrease rollsRemaining)
  // ==========================================
  void rollDice() {
    if (rollsRemaining <= 0) return;

    final random = Random();
    for (int i = 0; i < 5; i++) {
      if (!lockedDice[i]) {
        dice[i] = random.nextInt(6) + 1;
      }
    }
    rollsRemaining--; // <-- Decrements 3 -> 2 -> 1 -> 0
    notifyListeners();
  }

  // ==========================================
  // 2. TOGGLE LOCK DIE (Allowed whenever rollsRemaining < 3)
  // ==========================================
  void toggleLockDie(int index) {
    if (index >= 0 && index < lockedDice.length) {
      // Allow locking/unlocking as long as at least 1 roll has been made
      if (rollsRemaining < 3) {
        lockedDice[index] = !lockedDice[index];
        notifyListeners();
      }
    }
  }

  // ==========================================
  // 3. SELECT CATEGORY (Scores & Resets Turn)
  // ==========================================
  void selectCategory(ScoreCategory category) {
    // 1. Prevent selecting an already filled category
    if (scores.containsKey(category)) return;

    // 2. Prevent selecting before rolling at least once
    if (rollsRemaining == 3) return;

    // Multiple Yahtzee & Joker Bonus Check
    if (isCurrentRollYahtzee && yahtzeeScore != null) {
      if (hasScoredYahtzee50) {
        yahtzeeBonusCount++;
      }
    }

    // Apply score
    scores[category] = calculateScore(category, dice);

    // RESET FOR NEXT TURN
    rollsRemaining = 3;
    lockedDice = [false, false, false, false, false];
    notifyListeners();

  }

  // Reset entire game
  void resetGame() {
    scores.clear();
    dice = [1, 1, 1, 1, 1];
    lockedDice = [false, false, false, false, false];
    rollsRemaining = 3;
    yahtzeeBonusCount = 0;
    notifyListeners();
  }

  void setDiceValues(List<int> newValues) {
    if (newValues.length == 5) {
      dice = List.from(newValues);
      notifyListeners();
    }
  }

  // ==========================================
  // SCORING ENGINE & JOKER RULES
  // ==========================================
  int calculateScore(ScoreCategory category, List<int> currentDice) {
    bool isYahtzee = currentDice.length == 5 && currentDice.every((d) => d == currentDice[0]);

    if (!isYahtzee || yahtzeeScore == null) {
      return _calculateStandardScore(category, currentDice);
    }

    // Joker Rules
    int diceVal = currentDice[0];
    ScoreCategory upperCategory = _getUpperCategoryForValue(diceVal);
    bool isUpperCategoryEmpty = scores[upperCategory] == null;

    if (isUpperCategoryEmpty) {
      return (category == upperCategory) ? (diceVal * 5) : 0;
    }

    bool isLowerCategory = [
      ScoreCategory.threeOfAKind,
      ScoreCategory.fourOfAKind,
      ScoreCategory.fullHouse,
      ScoreCategory.smallStraight,
      ScoreCategory.largeStraight,
      ScoreCategory.yahtzee,
      ScoreCategory.chance,
    ].contains(category);

    if (isLowerCategory) {
      switch (category) {
        case ScoreCategory.fullHouse:
          return 25;
        case ScoreCategory.smallStraight:
          return 30;
        case ScoreCategory.largeStraight:
          return 40;
        case ScoreCategory.threeOfAKind:
        case ScoreCategory.fourOfAKind:
        case ScoreCategory.chance:
          return currentDice.fold(0, (a, b) => a + b);
        default:
          return _calculateStandardScore(category, currentDice);
      }
    }

    return 0;
  }

  int _calculateStandardScore(ScoreCategory category, List<int> currentDice) {
    int sum = currentDice.fold(0, (a, b) => a + b);
    Map<int, int> counts = {};
    for (var d in currentDice) {
      counts[d] = (counts[d] ?? 0) + 1;
    }

    switch (category) {
      case ScoreCategory.ones:
        return (counts[1] ?? 0) * 1;
      case ScoreCategory.twos:
        return (counts[2] ?? 0) * 2;
      case ScoreCategory.threes:
        return (counts[3] ?? 0) * 3;
      case ScoreCategory.fours:
        return (counts[4] ?? 0) * 4;
      case ScoreCategory.fives:
        return (counts[5] ?? 0) * 5;
      case ScoreCategory.sixes:
        return (counts[6] ?? 0) * 6;
      case ScoreCategory.threeOfAKind:
        return counts.values.any((c) => c >= 3) ? sum : 0;
      case ScoreCategory.fourOfAKind:
        return counts.values.any((c) => c >= 4) ? sum : 0;
      case ScoreCategory.fullHouse:
        bool has3 = counts.values.contains(3);
        bool has2 = counts.values.contains(2);
        bool has5 = counts.values.contains(5);
        return (has3 && has2) || has5 ? 25 : 0;
      case ScoreCategory.smallStraight:
        return _hasStraight(counts.keys.toList(), 4) ? 30 : 0;
      case ScoreCategory.largeStraight:
        return _hasStraight(counts.keys.toList(), 5) ? 40 : 0;
      case ScoreCategory.yahtzee:
        return counts.values.contains(5) ? 50 : 0;
      case ScoreCategory.chance:
        return sum;
    }
  }

  bool _hasStraight(List<int> uniqueDice, int lengthNeeded) {
    uniqueDice.sort();
    int consecutive = 1;
    int maxConsecutive = 1;
    for (int i = 0; i < uniqueDice.length - 1; i++) {
      if (uniqueDice[i + 1] == uniqueDice[i] + 1) {
        consecutive++;
        if (consecutive > maxConsecutive) maxConsecutive = consecutive;
      } else if (uniqueDice[i + 1] != uniqueDice[i]) {
        consecutive = 1;
      }
    }
    return maxConsecutive >= lengthNeeded;
  }

  ScoreCategory _getUpperCategoryForValue(int val) {
    switch (val) {
      case 1: return ScoreCategory.ones;
      case 2: return ScoreCategory.twos;
      case 3: return ScoreCategory.threes;
      case 4: return ScoreCategory.fours;
      case 5: return ScoreCategory.fives;
      case 6: return ScoreCategory.sixes;
      default: return ScoreCategory.ones;
    }
  }

  int get upperSectionScore {
    int total = 0;
    for (var cat in [
      ScoreCategory.ones,
      ScoreCategory.twos,
      ScoreCategory.threes,
      ScoreCategory.fours,
      ScoreCategory.fives,
      ScoreCategory.sixes,
    ]) {
      total += scores[cat] ?? 0;
    }
    return total;
  }

  bool get hasUpperBonus => upperSectionScore >= 63;
  int get upperBonusPoints => hasUpperBonus ? 35 : 0;
  int get totalYahtzeeBonusPoints => yahtzeeBonusCount * 100;

  int get grandTotal {
    int sum = scores.values.fold(0, (a, b) => a + b);
    sum += upperBonusPoints;
    sum += totalYahtzeeBonusPoints;
    return sum;
  }
}