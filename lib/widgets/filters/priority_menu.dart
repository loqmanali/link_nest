import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import 'filter_pill.dart';

class PriorityMenu extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onSelected;

  const PriorityMenu({
    super.key,
    required this.currentFilter,
    required this.onSelected,
  });

  bool get _isPrioritySelected =>
      currentFilter == 'high_priority' ||
      currentFilter == 'medium_priority' ||
      currentFilter == 'low_priority';

  @override
  Widget build(BuildContext context) {
    final isActive = _isPrioritySelected;
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'high_priority',
          child: _menuRow('High Priority', currentFilter == 'high_priority',
              color: AppTheme.highPriorityColor),
        ),
        PopupMenuItem(
          value: 'medium_priority',
          child: _menuRow('Medium Priority', currentFilter == 'medium_priority',
              color: AppTheme.mediumPriorityColor),
        ),
        PopupMenuItem(
          value: 'low_priority',
          child: _menuRow('Low Priority', currentFilter == 'low_priority',
              color: AppTheme.lowPriorityColor),
        ),
      ],
      child: FilterPill(
        label: 'Priority',
        isActive: isActive,
        activeColor: isActive
            ? _getFilterColor(currentFilter)
            : AppTheme.foregroundColor,
        hasChevron: true,
      ),
    );
  }

  Widget _menuRow(String label, bool selected, {required Color color}) {
    return Row(
      children: [
        if (selected) Icon(Icons.check_circle, size: 12, color: color),
        SizedBox(width: selected ? 8 : 24),
        Text(label),
      ],
    );
  }
}

Color _getFilterColor(String filter) {
  switch (filter) {
    case 'high_priority':
      return AppTheme.highPriorityColor;
    case 'medium_priority':
      return AppTheme.mediumPriorityColor;
    case 'low_priority':
      return AppTheme.lowPriorityColor;
    default:
      return AppTheme.foregroundColor;
  }
}
