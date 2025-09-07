import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import './shadcn_select.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final bool isEditing;

  const DropdownField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.mutedForeground),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.foregroundColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: isEditing
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: ShadcnSelect<String>.fromOptions(
            options: items
                .map((item) => SelectOption(
                      value: item,
                      label: item,
                    ))
                .toList(),
            value: value,
            placeholder: 'Select $label',
            onChanged: (newValue) => onChanged?.call(newValue),
            width: double.infinity,
            enabled: isEditing,
          ),
        ),
      ],
    );
  }
}
