import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/workout_set.dart';
import '../services/storage_service.dart';
import '../data/default_data.dart';

class WorkoutProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  Map<String, Workout> _workouts = {};
  List<Exercise> _customExercises = [];
  DateTime _selectedDate = DateTime.now();

  // Timer related
  Timer? _restTimer;
  int _currentRestTime = 0;
  bool _isResting = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Map<String, Workout> get workouts => _workouts;
  DateTime get selectedDate => _selectedDate;
  int get currentRestTime => _currentRestTime;
  bool get isResting => _isResting;

  List<Exercise> get allExercises {
    return [...defaultExercises, ..._customExercises];
  }

  WorkoutProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _workouts = await _storageService.loadWorkouts();
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<Exercise> getExercisesForDate(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return _workouts[dateKey]?.exercises ?? [];
  }

  void addExercise(DateTime date, Exercise exercise) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);

    if (!_workouts.containsKey(dateKey)) {
      _workouts[dateKey] = Workout(date: dateKey, exercises: []);
    }

    final newExercise = Exercise(
      id: exercise.id,
      name: exercise.name,
      bodyPart: exercise.bodyPart,
      sets: [],
      isCustom: exercise.isCustom,
      targetTool: exercise.targetTool,
      restTime: exercise.restTime,
    );

    _workouts[dateKey]!.exercises.add(newExercise);
    _saveData();
    notifyListeners();
  }

  void removeExercise(DateTime date, String exerciseId) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    if (_workouts.containsKey(dateKey)) {
      _workouts[dateKey]!.exercises.removeWhere((ex) => ex.id == exerciseId);
      _saveData();
      notifyListeners();
    }
  }

  void removeExerciseAt(DateTime date, int index) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    if (_workouts.containsKey(dateKey)) {
      if (index >= 0 && index < _workouts[dateKey]!.exercises.length) {
        _workouts[dateKey]!.exercises.removeAt(index);
        _saveData();
      }
    }
  }

  Exercise? _getLastHistoricalExercise(
      String exerciseName, DateTime currentDate) {
    // Sort dates descending
    final sortedDates = _workouts.keys.toList()..sort((a, b) => b.compareTo(a));
    final currentDateKey = DateFormat('yyyy-MM-dd').format(currentDate);

    print('Looking for history for $exerciseName before $currentDateKey');

    for (final dateKey in sortedDates) {
      // Skip future dates or the current date (we want strictly previous history)
      if (dateKey.compareTo(currentDateKey) >= 0) continue;

      final workout = _workouts[dateKey];
      if (workout == null) continue;

      try {
        final exercise = workout.exercises.firstWhere(
          (ex) => ex.name == exerciseName && ex.sets.isNotEmpty,
        );
        print('Found history on $dateKey: ${exercise.sets.last.weight}kg');
        return exercise;
      } catch (e) {
        // Exercise not found in this workout
        continue;
      }
    }
    print('No history found for $exerciseName');
    return null;
  }

  void addSet(DateTime date, Exercise exerciseInstance, WorkoutSet? set) {
    WorkoutSet newSet;
    if (set != null) {
      newSet = set;
    } else if (exerciseInstance.sets.isNotEmpty) {
      final lastSet = exerciseInstance.sets.last;
      newSet = WorkoutSet(
        weight: lastSet.weight,
        reps: lastSet.reps,
        restTime: lastSet.restTime ?? exerciseInstance.restTime,
        isCompleted: false,
      );
    } else {
      // Try to find last set from history
      final lastHistoricalExercise =
          _getLastHistoricalExercise(exerciseInstance.name, date);
      if (lastHistoricalExercise != null &&
          lastHistoricalExercise.sets.isNotEmpty) {
        final lastSet = lastHistoricalExercise.sets.last;
        newSet = WorkoutSet(
          weight: lastSet.weight,
          reps: lastSet.reps,
          // Use effective rest time from history
          restTime: lastSet.restTime ?? lastHistoricalExercise.restTime,
          isCompleted: false,
        );
      } else {
        newSet = WorkoutSet(
          weight: 0,
          reps: 0,
          restTime: exerciseInstance.restTime,
          isCompleted: false,
        );
      }
    }

    exerciseInstance.sets.add(newSet);
    _saveData();
    notifyListeners();
  }

  void updateSet(DateTime date, Exercise exerciseInstance, int setIndex,
      WorkoutSet newSet) {
    if (setIndex >= 0 && setIndex < exerciseInstance.sets.length) {
      exerciseInstance.sets[setIndex] = newSet;
      _saveData();
      notifyListeners();
    }
  }

  void removeSet(DateTime date, Exercise exerciseInstance, int setIndex) {
    if (setIndex >= 0 && setIndex < exerciseInstance.sets.length) {
      exerciseInstance.sets.removeAt(setIndex);
      _saveData();
      notifyListeners();
    }
  }

  void updateRestTime(Exercise exerciseInstance, int seconds) {
    exerciseInstance.restTime = seconds;
    _saveData();
    notifyListeners();
  }

  void adjustRestTime(int seconds) {
    _currentRestTime += seconds;
    if (_currentRestTime < 0) _currentRestTime = 0;
    notifyListeners();
  }

  void toggleSetCompletion(Exercise exerciseInstance, int setIndex) {
    if (setIndex >= 0 && setIndex < exerciseInstance.sets.length) {
      final set = exerciseInstance.sets[setIndex];
      set.isCompleted = !set.isCompleted;

      if (set.isCompleted) {
        final duration = set.restTime ?? exerciseInstance.restTime;
        _startRestTimer(duration);
      } else {
        _cancelRestTimer();
      }

      _saveData();
      notifyListeners();
    }
  }

  void _startRestTimer(int duration) {
    _cancelRestTimer();
    _currentRestTime = duration;
    _isResting = true;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentRestTime > 0) {
        _currentRestTime--;
        notifyListeners();
      } else {
        _restTimer?.cancel();
        _restTimer = null;
        _playAlarm();
      }
    });
  }

  void cancelRestTimer() {
    _cancelRestTimer();
  }

  void _cancelRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
    _isResting = false;
    _currentRestTime = 0;
    _stopAlarm();
    notifyListeners();
  }

  Future<void> _playAlarm() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.5);
      await _audioPlayer.play(AssetSource('sounds/boxing_bell.mp3'));
    } catch (e) {
      print('Error playing alarm: $e');
    }
  }

  Future<void> _stopAlarm() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      print('Error stopping alarm: $e');
    }
  }

  void copyWorkout(DateTime sourceDate, DateTime targetDate) {
    final sourceKey = DateFormat('yyyy-MM-dd').format(sourceDate);
    final targetKey = DateFormat('yyyy-MM-dd').format(targetDate);

    final sourceWorkout = _workouts[sourceKey];
    if (sourceWorkout == null || sourceWorkout.exercises.isEmpty) return;

    final newExercises = sourceWorkout.exercises.map((ex) {
      return Exercise(
        id: ex.id,
        name: ex.name,
        bodyPart: ex.bodyPart,
        isCustom: ex.isCustom,
        targetTool: ex.targetTool,
        restTime: ex.restTime,
        sets: ex.sets
            .map((s) => WorkoutSet(
                  weight: s.weight,
                  reps: s.reps,
                  isCompleted: false,
                  restTime: s.restTime,
                ))
            .toList(),
      );
    }).toList();

    if (!_workouts.containsKey(targetKey)) {
      _workouts[targetKey] = Workout(date: targetKey, exercises: []);
    }

    _workouts[targetKey]!.exercises.addAll(newExercises);
    _saveData();
    notifyListeners();
  }

  void moveWorkout(DateTime sourceDate, DateTime targetDate) {
    copyWorkout(sourceDate, targetDate);
    final sourceKey = DateFormat('yyyy-MM-dd').format(sourceDate);
    _workouts[sourceKey]?.exercises.clear();
    _saveData();
    notifyListeners();
  }

  void addCustomExercise(Exercise exercise) {
    _customExercises.add(exercise);
    notifyListeners();
  }

  void deleteCustomExercise(String id) {
    _customExercises.removeWhere((ex) => ex.id == id);
    notifyListeners();
  }

  Future<void> _saveData() async {
    await _storageService.saveWorkouts(_workouts);
  }
}
