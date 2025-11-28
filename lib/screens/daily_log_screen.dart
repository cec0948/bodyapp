import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/workout_provider.dart';
import '../models/exercise.dart';
import '../models/workout_set.dart';
import '../widgets/exercise_card.dart';
import '../widgets/rest_timer.dart';
import '../data/default_data.dart'; // Import for bodyParts

class DailyLogScreen extends StatefulWidget {
  final DateTime date;

  const DailyLogScreen({super.key, required this.date});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  // Timer state is now managed by WorkoutProvider

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final exercises = provider.getExercisesForDate(widget.date);

    return Stack(
      children: [
        Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  DateFormat('MM월 d일 EEEE', 'ko_KR').format(widget.date),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: exercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('운동 기록이 없습니다.',
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  _showCopyDialog(context, provider),
                              child: const Text('다른 날짜에서 복사하기'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];
                          return ExerciseCard(
                            exercise: exercise,
                            onAddSet: (set) {
                              provider.addSet(widget.date, exercise, set);
                            },
                            onUpdateSet: (setIndex, set) {
                              provider.updateSet(
                                  widget.date, exercise, setIndex, set);
                            },
                            onDeleteSet: (setIndex) {
                              provider.removeSet(
                                  widget.date, exercise, setIndex);
                            },
                            onDeleteExercise: () {
                              provider.removeExercise(widget.date, exercise.id);
                            },
                            onSetComplete: (setIndex) {
                              // Toggle completion via provider
                              provider.toggleSetCompletion(exercise, setIndex);
                            },
                            onUpdateRestTime: (seconds) {
                              provider.updateRestTime(exercise, seconds);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddExerciseSheet(context, provider),
            label: const Text('운동 추가'),
            icon: const Icon(LucideIcons.plus),
          ),
        ),
        if (provider.isResting)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: RestTimer(
              currentSeconds: provider.currentRestTime,
              onClose: () {
                provider.cancelRestTimer();
              },
              onAdjustTime: (seconds) {
                provider.adjustRestTime(seconds);
              },
            ),
          ),
      ],
    );
  }

  void _showAddExerciseSheet(BuildContext context, WorkoutProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddExerciseSheet(
        allExercises: provider.allExercises,
        onAdd: (exercise) {
          provider.addExercise(widget.date, exercise);
          Navigator.pop(context);
        },
        onCreateCustom: (name, bodyPart) {
          final newExercise = Exercise(
            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            bodyPart: bodyPart,
            sets: [],
            isCustom: true,
            targetTool: TargetTool.barbell, // Default
          );
          provider.addCustomExercise(newExercise);
          provider.addExercise(widget.date, newExercise);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCopyDialog(BuildContext context, WorkoutProvider provider) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(), // Ensure dark theme for picker
          child: child!,
        );
      },
    ).then((picked) {
      if (picked != null) {
        // Show confirmation with details
        final exercises = provider.getExercisesForDate(picked);
        if (exercises.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('해당 날짜에 운동 기록이 없습니다.')),
          );
          return;
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${DateFormat('MM/dd').format(picked)} 운동 복사'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];
                  return ListTile(
                    title: Text(ex.name),
                    subtitle: Text('${ex.sets.length}세트'),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  provider.copyWorkout(picked, widget.date);
                  Navigator.pop(context);
                },
                child: const Text('복사'),
              ),
            ],
          ),
        );
      }
    });
  }
}

class AddExerciseSheet extends StatefulWidget {
  final List<Exercise> allExercises;
  final Function(Exercise) onAdd;
  final Function(String, String) onCreateCustom;

  const AddExerciseSheet({
    super.key,
    required this.allExercises,
    required this.onAdd,
    required this.onCreateCustom,
  });

  @override
  State<AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<AddExerciseSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedBodyPart = '가슴';
  final _customNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = widget.allExercises.where((ex) {
      final matchesSearch =
          ex.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesPart =
          _selectedBodyPart == '전체' || ex.bodyPart == _selectedBodyPart;
      return matchesSearch && matchesPart;
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SizedBox(
        height: 500,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '운동 선택'),
                Tab(text: '직접 추가'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Select Tab
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                labelText: '검색',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _selectedBodyPart,
                            items: bodyParts.map((part) {
                              return DropdownMenuItem(
                                  value: part, child: Text(part));
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedBodyPart = val!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredExercises.length,
                          itemBuilder: (context, index) {
                            final ex = filteredExercises[index];
                            return ListTile(
                              title: Text(ex.name),
                              subtitle: Text(ex.bodyPart),
                              trailing: const Icon(Icons.add),
                              onTap: () => widget.onAdd(ex),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // Create Custom Tab
                  Column(
                    children: [
                      TextField(
                        controller: _customNameController,
                        decoration: const InputDecoration(
                          labelText: '운동 이름',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: '가슴', // Default
                        decoration: const InputDecoration(
                          labelText: '부위',
                          border: OutlineInputBorder(),
                        ),
                        items: bodyParts.where((p) => p != '전체').map((part) {
                          return DropdownMenuItem(
                              value: part, child: Text(part));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedBodyPart =
                            val!), // Reusing variable but careful
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_customNameController.text.isNotEmpty) {
                              widget.onCreateCustom(
                                  _customNameController.text,
                                  _selectedBodyPart == '전체'
                                      ? '가슴'
                                      : _selectedBodyPart);
                            }
                          },
                          child: const Text('추가'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
