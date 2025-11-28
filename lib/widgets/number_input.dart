import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NumberInput extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final double increment;
  final bool isInteger;
  final String suffix;

  const NumberInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.increment = 1.0,
    this.isInteger = false,
    this.suffix = '',
  });

  void _updateValue(double delta) {
    double newValue = value + delta;
    if (newValue < 0) newValue = 0;
    onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(LucideIcons.minus, () => _updateValue(-increment)),
        Container(
          width: 60, // Fixed width for alignment
          alignment: Alignment.center,
          child: Text(
            '${isInteger ? value.toInt() : value.toStringAsFixed(1)}$suffix',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        _buildButton(LucideIcons.plus, () => _updateValue(increment)),
      ],
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
