import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../constants/app_theme.dart';
import '../../models/saved_post.dart';
import '../ui/badge.dart';

class PostCardHeader extends StatelessWidget {
  final SavedPost post;

  const PostCardHeader({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            post.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.foregroundColor,
                  height: 1.4,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppTheme.spacing3),
        Tooltip(
          message: post.status,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(post.status),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacing2),
        ShadcnBadge(
          text: post.priority,
          icon: _getPriorityIcon(post.priority),
          customColor: AppTheme.getPriorityColor(post.priority),
        ),
      ],
    );
  }
}

IconData _getPriorityIcon(String priority) {
  switch (priority) {
    case 'High':
      return Iconsax.arrow_up;
    case 'Medium':
      return Iconsax.minus;
    case 'Low':
      return Iconsax.arrow_down;
    default:
      return Iconsax.info_circle;
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'read':
      return Colors.green;
    case 'starred':
      return Colors.amber;
    case 'unread':
    default:
      return AppTheme.mutedForeground;
  }
}
