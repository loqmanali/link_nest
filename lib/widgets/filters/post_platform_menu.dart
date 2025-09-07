import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import 'filter_pill.dart';

class PostPlatformMenu extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onSelected;

  const PostPlatformMenu({
    super.key,
    required this.currentFilter,
    required this.onSelected,
  });

  bool get _isPlatformSelected =>
      currentFilter == 'linkedin' ||
      currentFilter == 'twitter' ||
      currentFilter == 'facebook' ||
      currentFilter == 'github' ||
      currentFilter == 'medium' ||
      currentFilter == 'youtube' ||
      currentFilter == 'whatsapp' ||
      currentFilter == 'telegram' ||
      currentFilter == 'other_platform';

  @override
  Widget build(BuildContext context) {
    final isActive = _isPlatformSelected;
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        _item('linkedin', 'LinkedIn', Colors.blue),
        _item('twitter', 'Twitter', Colors.lightBlueAccent),
        _item('facebook', 'Facebook', Colors.indigo),
        _item('github', 'GitHub', Colors.black87),
        _item('medium', 'Medium', Colors.green),
        _item('youtube', 'YouTube', Colors.red),
        _item('whatsapp', 'WhatsApp', Colors.green),
        _item('telegram', 'Telegram', Colors.lightBlue),
        _item('other_platform', 'Other', Colors.grey),
      ],
      child: FilterPill(
        label: 'Platform',
        isActive: isActive,
        activeColor: isActive
            ? _getFilterColor(currentFilter)
            : AppTheme.foregroundColor,
        hasChevron: true,
      ),
    );
  }

  PopupMenuItem<String> _item(String value, String label, Color color) {
    final selected = currentFilter == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (selected) Icon(Icons.check_circle, size: 16, color: color),
          SizedBox(width: selected ? 8 : 24),
          Text(label),
        ],
      ),
    );
  }
}

Color _getFilterColor(String filter) {
  switch (filter) {
    case 'linkedin':
      return Colors.blue;
    case 'twitter':
      return Colors.lightBlueAccent;
    case 'facebook':
      return Colors.indigo;
    case 'github':
      return Colors.black87;
    case 'medium':
      return Colors.green;
    case 'youtube':
      return Colors.red;
    case 'whatsapp':
      return Colors.green;
    case 'telegram':
      return Colors.lightBlue;
    case 'other_platform':
      return Colors.grey;
    default:
      return AppTheme.foregroundColor;
  }
}
