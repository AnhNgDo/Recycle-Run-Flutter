import 'package:shared_preferences/shared_preferences.dart';

import 'player_progress_persistence.dart';

/// Implementation of [PlayerProgressPersistence] using Shared Preferences.
/// Stores and retrieves player progress data for completed levels.
class LocalStoragePlayerProgressPersistence extends PlayerProgressPersistence {
  /// Future for accessing Shared Preferences instance.
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<List<int>> getFinishedLevels() async {
    // Get Shared Preferences instance.
    final prefs = await instanceFuture;

    // Retrieve serialized list of finished levels (storing completion times).
    final serialized = prefs.getStringList('levelsFinished') ?? [];

    // Convert serialized strings to ints and return as a list.
    return serialized.map(int.parse).toList();
  }

  @override
  Future<void> saveLevelFinished(int level, int time) async {
    // Get Shared Preferences instance.
    final prefs = await instanceFuture;

    // Retrieve current serialized data.
    final serialized = prefs.getStringList('levelsFinished') ?? [];

    // If level is within existing data:
    if (level <= serialized.length) {
      // Check if current time is better than stored time.
      final currentTime = int.parse(serialized[level - 1]);
      if (time < currentTime) {
        // Update time if better.
        serialized[level - 1] = time.toString();
      }
    } else {
      // Add new level completion data.
      serialized.add(time.toString());
    }

    // Save updated data back to Shared Preferences.
    await prefs.setStringList('levelsFinished', serialized);
  }

  @override
  Future<void> reset() async {
    // Get Shared Preferences instance.
    final prefs = await instanceFuture;

    // Remove all stored progress data.
    await prefs.remove('levelsFinished');
  }
}
