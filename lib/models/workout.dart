import 'exercise.dart';

class Workout {
  String date; // Format: yyyy-MM-dd
  List<Exercise> exercises;

  Workout({
    required this.date,
    required this.exercises,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      date: json['date'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
