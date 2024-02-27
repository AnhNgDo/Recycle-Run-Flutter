import 'dart:async';

import 'persistence/local_storage_player_progress_persistence.dart';
import 'package:flutter/foundation.dart';

import 'persistence/player_progress_persistence.dart';

/// Encapsulates the player's progress.
class PlayerProgress extends ChangeNotifier {
  PlayerProgress({PlayerProgressPersistence? store})
      : _store = store ?? LocalStoragePlayerProgressPersistence() {
    getLatestFromStore();
  }

  /// To Do: If needed, replace this with some other mechanism for saving
  ///       the player's progress. Currently, this uses the local storage
  ///       (i.e. NSUserDefaults on iOS, SharedPreferences on Android
  ///       or local storage on the web).
  final PlayerProgressPersistence _store;

  // store times that player finishes each level
  List<int> _levelsFinished = [];

  /// The times for the levels that the player has finished so far.
  List<int> get levels => _levelsFinished;

  /// Fetches the latest data from the backing persistence store.
  Future<void> getLatestFromStore() async {
    final levelsFinished = await _store.getFinishedLevels();

    if (!listEquals(_levelsFinished, levelsFinished)) {
      _levelsFinished = _levelsFinished;
      notifyListeners();
    }
  }

  /// Resets the player's progress so it's like if they just started
  /// playing the game for the first time.
  void reset() {
    _store.reset();
    _levelsFinished.clear();
    notifyListeners();
  }

  /// Registers [level] as completed. Note: [level] must starts from 1.
  ///
  /// If new time is better than current time, it will update that
  /// value and save it to the injected persistence store.
  void setLevelFinished(int level, int time) {
    // if there is already a time for this level
    if (level <= _levelsFinished.length) {
      final currentTime = _levelsFinished[level - 1];
      if (time < currentTime) {
        _levelsFinished[level - 1] = time;
        notifyListeners();
        unawaited(_store.saveLevelFinished(level, time));
      }
    } else {
      // if player completed a brand new level
      _levelsFinished.add(time);
      notifyListeners();
      unawaited(_store.saveLevelFinished(level, time));
    }
  }
}
