import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class TypeChip extends StatelessWidget {
  final String type;
  const TypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.getPostTypeColor(type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getPostTypeColor(type).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category,
            size: 16,
            color: AppTheme.getPostTypeColor(type),
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              color: AppTheme.getPostTypeColor(type),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
