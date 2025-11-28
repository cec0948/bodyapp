import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';

class CalendarScreen extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const CalendarScreen({super.key, required this.onDateSelected});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final workouts = provider.workouts;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Custom Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {}, // Placeholder for menu
                ),
                Row(
                  children: [
                    Text(
                      DateFormat('yyyy.MM').format(_focusedDay),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () {}, // Placeholder for info
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {}, // Placeholder for settings
                    ),
                  ],
                ),
              ],
            ),
          ),
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            rowHeight: 130, // Increased height for detailed list
            daysOfWeekHeight: 30,
            headerVisible: false, // Hide default header
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDateSelected(selectedDay);
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              final dateKey = DateFormat('yyyy-MM-dd').format(day);
              return workouts[dateKey]?.exercises ?? [];
            },
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: EdgeInsets.zero, // Remove margin for grid look
              defaultTextStyle:
                  TextStyle(color: Colors.transparent), // Hide default text
              weekendTextStyle:
                  TextStyle(color: Colors.transparent), // Hide default text
              todayDecoration: BoxDecoration(), // Disable default decoration
              selectedDecoration: BoxDecoration(), // Disable default decoration
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.grey, fontSize: 12),
              weekendStyle: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildDetailedCalendarCell(
                    context, day, workouts, provider);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildDetailedCalendarCell(
                    context, day, workouts, provider,
                    isSelected: true);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildDetailedCalendarCell(
                    context, day, workouts, provider,
                    isToday: true);
              },
              markerBuilder: (context, day, events) {
                return const SizedBox(); // Hide default markers
              },
            ),
          ),
          const SizedBox(height: 8),
          // Daily Summary
          _buildDailySummary(provider, _selectedDay ?? DateTime.now()),
        ],
      ),
    );
  }

  Widget _buildDetailedCalendarCell(BuildContext context, DateTime day,
      Map<String, Workout> workouts, WorkoutProvider provider,
      {bool isSelected = false, bool isToday = false}) {
    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    final workout = workouts[dateKey];

    // Determine date color
    Color dateColor = Colors.white;
    if (day.weekday == DateTime.sunday) {
      dateColor = const Color(0xFFEF4444); // Red
    } else if (day.weekday == DateTime.saturday) {
      dateColor = const Color(0xFF3B82F6); // Blue
    }

    // Calculate stats
    int totalSets = 0;
    final bodyParts = <String, int>{};
    if (workout != null) {
      for (var ex in workout.exercises) {
        totalSets += ex.sets.length;
        bodyParts[ex.bodyPart] = (bodyParts[ex.bodyPart] ?? 0) + ex.sets.length;
      }
    }

    // Sort body parts by count (descending)
    final sortedParts = bodyParts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Widget content = Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.white.withOpacity(0.1), width: 0.5), // Grid lines
        color: isSelected ? Colors.white.withOpacity(0.05) : null,
      ),
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Number
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: isToday
                  ? const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: dateColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Stats List
          if (totalSets > 0) ...[
            _buildStatTag(
                '${totalSets}세트', const Color(0xFF1E3A8A)), // Dark Blue
            ...sortedParts.take(4).map((entry) {
              return _buildStatTag(
                  '${entry.key} ${entry.value}', const Color(0xFF1E3A8A));
            }),
          ],
        ],
      ),
    );

    return LongPressDraggable<DateTime>(
      delay: const Duration(milliseconds: 300),
      data: day,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black54)],
            border: Border.all(color: const Color(0xFF3B82F6), width: 2),
          ),
          child: Center(
            child: Text(
              DateFormat('MM/dd').format(day),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      child: DragTarget<DateTime>(
        onWillAccept: (data) => data != null && data != day,
        onAccept: (sourceDate) {
          _showMoveOrCopyDialog(context, provider, sourceDate, day);
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              border: candidateData.isNotEmpty
                  ? Border.all(color: const Color(0xFF10B981), width: 2)
                  : null,
            ),
            child: content,
          );
        },
      ),
    );
  }

  Widget _buildStatTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFBFDBFE), // Light Blue Text
          fontSize: 10,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showMoveOrCopyDialog(BuildContext context, WorkoutProvider provider,
      DateTime source, DateTime target) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          '${DateFormat('MM/dd').format(source)} → ${DateFormat('MM/dd').format(target)}',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text('운동 기록을 복사하거나 이동하시겠습니까?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.copyWorkout(source, target);
            },
            child: const Text('복사', style: TextStyle(color: Color(0xFF3B82F6))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.moveWorkout(source, target);
            },
            child: const Text('이동', style: TextStyle(color: Color(0xFF3B82F6))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummary(WorkoutProvider provider, DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final workout = provider.workouts[dateKey];

    if (workout == null || workout.exercises.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center,
                size: 48, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              '운동 기록이 없습니다.',
              style: TextStyle(color: Colors.white.withOpacity(0.3)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workout.exercises.length,
      itemBuilder: (context, index) {
        final exercise = workout.exercises[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              exercise.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: Text(
              '${exercise.sets.length}세트 • ${exercise.bodyPart}',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {
              // Optional: Navigate to detail or edit
            },
          ),
        );
      },
    );
  }
}
