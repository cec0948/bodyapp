import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/exercise.dart';
import '../models/workout_set.dart';
import 'number_input.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final Function(WorkoutSet?) onAddSet;
  final Function(int, WorkoutSet) onUpdateSet;
  final Function(int) onDeleteSet;
  final Function() onDeleteExercise;
  final Function(int)
      onSetComplete; // Changed to just index, toggle handled in provider
  final Function(int) onUpdateRestTime;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onAddSet,
    required this.onUpdateSet,
    required this.onDeleteSet,
    required this.onDeleteExercise,
    required this.onSetComplete,
    required this.onUpdateRestTime,
  });

  double _getWeightIncrement() {
    switch (exercise.targetTool) {
      case TargetTool.barbell:
        return 5.0;
      case TargetTool.dumbbell:
        return 2.0;
      case TargetTool.machine:
        return 5.0;
      case TargetTool.bodyweight:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1E293B), // Dark card background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2,
                      size: 20, color: Colors.redAccent),
                  onPressed: onDeleteExercise,
                ),
              ],
            ),
            // Global Rest Time Setting (Default for new sets)
            Row(
              children: [
                const Icon(LucideIcons.timer, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('기본 휴식 시간', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: exercise.restTime,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  underline: Container(height: 1, color: Colors.grey),
                  items: [30, 60, 90, 120, 180, 240, 300].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('${value}초'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      onUpdateRestTime(val);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Header
            Row(
              children: [
                const Expanded(
                    flex: 1,
                    child: Text('세트',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey))),
                if (exercise.targetTool != TargetTool.bodyweight)
                  const Expanded(
                      flex: 3,
                      child: Text('kg',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey))),
                const Expanded(
                    flex: 3,
                    child: Text('회',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey))),
                const Expanded(
                    flex: 1,
                    child:
                        Icon(LucideIcons.check, size: 16, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            // Sets
            ...exercise.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              final isCompleted = set.isCompleted;

              return Opacity(
                opacity: isCompleted ? 0.5 : 1.0, // Dim if completed
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              child: Text('${index + 1}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                          if (exercise.targetTool != TargetTool.bodyweight)
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: NumberInput(
                                  value: set.weight,
                                  onChanged: (val) {
                                    onUpdateSet(
                                        index,
                                        WorkoutSet(
                                            weight: val,
                                            reps: set.reps,
                                            isCompleted: set.isCompleted,
                                            restTime: set.restTime));
                                  },
                                  increment: _getWeightIncrement(),
                                  isInteger:
                                      exercise.targetTool == TargetTool.dumbbell
                                          ? true
                                          : false,
                                ),
                              ),
                            ),
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: NumberInput(
                                value: set.reps.toDouble(),
                                onChanged: (val) {
                                  onUpdateSet(
                                      index,
                                      WorkoutSet(
                                          weight: set.weight,
                                          reps: val.toInt(),
                                          isCompleted: set.isCompleted,
                                          restTime: set.restTime));
                                },
                                increment: 1.0,
                                isInteger: true,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Checkbox(
                              value: set.isCompleted,
                              onChanged: (val) {
                                onSetComplete(index);
                              },
                              activeColor: Colors.blue,
                              checkColor: Colors.white,
                              side: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      // Per-set Rest Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 16), // Indent slightly
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.timer,
                                    size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                DropdownButton<int>(
                                  value: set.restTime ?? exercise.restTime,
                                  isDense: true,
                                  dropdownColor: const Color(0xFF1E293B),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  underline: Container(),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      size: 16, color: Colors.grey),
                                  items: [30, 60, 90, 120, 180, 240, 300]
                                      .map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text('휴식 ${value}초'),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      onUpdateSet(
                                          index,
                                          WorkoutSet(
                                              weight: set.weight,
                                              reps: set.reps,
                                              isCompleted: set.isCompleted,
                                              restTime: val));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Pass null to let provider handle smart defaults
                  onAddSet(null);
                },
                icon:
                    const Icon(LucideIcons.plus, size: 16, color: Colors.blue),
                label:
                    const Text('세트 추가', style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
