import 'package:flutter/material.dart';

class AppSwitchListTile extends StatelessWidget {
  const AppSwitchListTile({
    required this.isSelected,
    required this.label,
    required this.onChanged,
  });

  final bool isSelected;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      value: isSelected,
      onChanged: (value) => onChanged(
        value,
      ),
    );
  }
}
