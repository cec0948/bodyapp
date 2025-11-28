import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';

class StorageService {
  static const String _storageKey = 'workouts';

  Future<void> saveWorkouts(Map<String, Workout> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      workouts.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString(_storageKey, jsonString);
  }

  Future<Map<String, Workout>> loadWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      return {};
    }

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return jsonMap.map((key, value) => MapEntry(
            key,
            Workout.fromJson(value as Map<String, dynamic>),
          ));
    } catch (e) {
      print('Error loading workouts: $e');
      return {};
    }
  }
}
