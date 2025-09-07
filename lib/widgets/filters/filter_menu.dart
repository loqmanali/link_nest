import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import 'filter_pill.dart';

class FilterMenu extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onSelected;

  const FilterMenu({
    super.key,
    required this.currentFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentFilter == 'all' || currentFilter == 'sort_date';
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'all',
          child: Row(
            children: [
              if (currentFilter == 'all')
                const Icon(Icons.check_circle,
                    size: 16, color: AppTheme.primaryColor),
              SizedBox(width: currentFilter == 'all' ? 8 : 24),
              const Text('All Posts'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'sort_date',
          child: Row(
            children: [
              if (currentFilter == 'sort_date')
                const Icon(Icons.check_circle,
                    size: 16, color: AppTheme.primaryColor),
              SizedBox(width: currentFilter == 'sort_date' ? 8 : 24),
              const Text('Sort by Date'),
            ],
          ),
        ),
      ],
      child: FilterPill(
        label: 'Filter',
        isActive: isActive,
        activeColor: _getFilterColor(currentFilter),
        hasChevron: true,
      ),
    );
  }
}

Color _getFilterColor(String filter) {
  // Default primary for top-level filter pill
  return AppTheme.primaryColor;
}
