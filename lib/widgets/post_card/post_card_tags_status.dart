import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../constants/app_theme.dart';
import '../../models/saved_post.dart';

class PostCardTagsStatus extends StatelessWidget {
  final SavedPost post;

  const PostCardTagsStatus({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spacing2,
      runSpacing: AppTheme.spacing1,
      children: [
        // Status badge (always visible)
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            color: _getStatusColor(post.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: _getStatusColor(post.status).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(post.status),
                size: 12,
                color: _getStatusColor(post.status),
              ),
              const SizedBox(width: AppTheme.spacing1),
              Text(
                post.status.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(post.status),
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
        // Tag chips
        ...post.tags.take(3).map((tag) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing2,
                vertical: AppTheme.spacing1,
              ),
              decoration: BoxDecoration(
                color: AppTheme.mutedColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.tag,
                    size: 10,
                    color: AppTheme.mutedForeground,
                  ),
                  const SizedBox(width: AppTheme.spacing1),
                  Text(
                    tag,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mutedForeground,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            )),
        if (post.tags.length > 3)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing2,
              vertical: AppTheme.spacing1,
            ),
            decoration: BoxDecoration(
              color: AppTheme.mutedColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Text(
              '+${post.tags.length - 3}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedForeground,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
      ],
    );
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

IconData _getStatusIcon(String status) {
  switch (status) {
    case 'read':
      return Iconsax.tick_circle;
    case 'starred':
      return Iconsax.star;
    case 'unread':
    default:
      return Iconsax.eye;
  }
}
