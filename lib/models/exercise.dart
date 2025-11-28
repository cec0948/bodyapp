import 'workout_set.dart';

enum TargetTool {
  barbell,
  dumbbell,
  machine,
  bodyweight,
}

class Exercise {
  String id;
  String name;
  String bodyPart;
  List<WorkoutSet> sets;
  bool isCustom;
  TargetTool targetTool;
  int restTime; // Seconds

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.sets,
    this.isCustom = false,
    this.targetTool = TargetTool.barbell,
    this.restTime = 60,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bodyPart': bodyPart,
      'sets': sets.map((s) => s.toJson()).toList(),
      'isCustom': isCustom,
      'targetTool': targetTool.index,
      'restTime': restTime,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      bodyPart: json['bodyPart'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>))
          .toList(),
      isCustom: json['isCustom'] as bool? ?? false,
      targetTool: TargetTool.values[json['targetTool'] as int? ?? 0],
      restTime: json['restTime'] as int? ?? 60,
    );
  }
}
