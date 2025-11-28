import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RestTimer extends StatelessWidget {
  final int currentSeconds;
  final VoidCallback onClose;
  final Function(int) onAdjustTime;

  const RestTimer({
    super.key,
    required this.currentSeconds,
    required this.onClose,
    required this.onAdjustTime,
  });

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('휴식 시간',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: onClose,
              ),
            ],
          ),
          Text(
            _formatTime(currentSeconds),
            style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: currentSeconds == 0 ? Colors.red : Colors.blue),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimeButton(label: '-10초', onPressed: () => onAdjustTime(-10)),
              const SizedBox(width: 16),
              _TimeButton(label: '+10초', onPressed: () => onAdjustTime(10)),
              const SizedBox(width: 16),
              _TimeButton(label: '+30초', onPressed: () => onAdjustTime(30)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _TimeButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label),
    );
  }
}
