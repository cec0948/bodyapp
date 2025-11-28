import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/workout_provider.dart';
import 'calendar_screen.dart';
import 'daily_log_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCalendarView = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final selectedDate = provider.selectedDate;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(LucideIcons.dumbbell, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('BodyApp', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (!_isCalendarView)
            TextButton.icon(
              onPressed: () => setState(() => _isCalendarView = true),
              icon: const Icon(LucideIcons.calendar),
              label: const Text('달력'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isCalendarView)
            Expanded(
              child: CalendarScreen(
                onDateSelected: (date) {
                  provider.selectDate(date);
                  setState(() => _isCalendarView = false);
                },
              ),
            )
          else
            Expanded(
              child: DailyLogScreen(
                date: selectedDate,
              ),
            ),
        ],
      ),
    );
  }
}
