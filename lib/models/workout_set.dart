class WorkoutSet {
  double weight;
  int reps;
  bool isCompleted;
  int? restTime; // Optional, in seconds. If null, use exercise default.

  WorkoutSet({
    required this.weight,
    required this.reps,
    this.isCompleted = false,
    this.restTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'reps': reps,
      'isCompleted': isCompleted,
      'restTime': restTime,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      restTime: json['restTime'] as int?,
    );
  }
}
