import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import 'filter_pill.dart';

class TypeMenu extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onSelected;

  const TypeMenu({
    super.key,
    required this.currentFilter,
    required this.onSelected,
  });

  bool get _isTypeSelected =>
      currentFilter == 'job' ||
      currentFilter == 'article' ||
      currentFilter == 'tip' ||
      currentFilter == 'opportunity' ||
      currentFilter == 'other';

  @override
  Widget build(BuildContext context) {
    final isActive = _isTypeSelected;
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'job',
          child: _menuRow('Jobs', currentFilter == 'job',
              color: AppTheme.jobColor),
        ),
        PopupMenuItem(
          value: 'article',
          child: _menuRow('Articles', currentFilter == 'article',
              color: AppTheme.articleColor),
        ),
        PopupMenuItem(
          value: 'tip',
          child: _menuRow('Tips', currentFilter == 'tip',
              color: AppTheme.tipColor),
        ),
        PopupMenuItem(
          value: 'opportunity',
          child: _menuRow('Opportunities', currentFilter == 'opportunity',
              color: AppTheme.opportunityColor),
        ),
        PopupMenuItem(
          value: 'other',
          child: _menuRow('Other', currentFilter == 'other',
              color: AppTheme.otherColor),
        ),
      ],
      child: FilterPill(
        label: 'Type',
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
    case 'job':
      return AppTheme.jobColor;
    case 'article':
      return AppTheme.articleColor;
    case 'tip':
      return AppTheme.tipColor;
    case 'opportunity':
      return AppTheme.opportunityColor;
    case 'other':
      return AppTheme.otherColor;
    default:
      return AppTheme.foregroundColor;
  }
}
