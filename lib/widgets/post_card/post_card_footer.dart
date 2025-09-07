import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/app_theme.dart';
import '../../models/saved_post.dart';
import '../ui/badge.dart';
import 'action_icon_button.dart';
import '../../blocs/post_bloc.dart';

class PostCardFooter extends HookWidget {
  final SavedPost post;
  final String formattedDate;
  final AnimationController shareController;
  final ValueNotifier<bool> isShared;

  const PostCardFooter({
    super.key,
    required this.post,
    required this.formattedDate,
    required this.shareController,
    required this.isShared,
  });

  @override
  Widget build(BuildContext context) {
    final shareAnimation = CurvedAnimation(
      parent: shareController,
      curve: Curves.easeInOut,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppTheme.spacing2,
          children: [
            ShadcnBadge(
              text: post.type,
              icon: _getTypeIcon(post.type),
              customColor: AppTheme.getPostTypeColor(post.type),
              variant: BadgeVariant.secondary,
            ),
            if (post.platform.isNotEmpty)
              ShadcnBadge(
                text: post.platform,
                icon: _getPlatformIcon(post.platform),
                customColor: AppTheme.getPlatformColor(post.platform),
                variant: BadgeVariant.outline,
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing2),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing1, vertical: AppTheme.spacing1),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: post.status == Status.starred ? 'Unstar' : 'Star',
                    child: ActionIconButton(
                      icon: Iconsax.star,
                      color: post.status == Status.starred
                          ? Colors.amber
                          : AppTheme.mutedForeground,
                      onTap: () => _toggleStar(context),
                      semanticLabel: 'Toggle star',
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing1),
                  Tooltip(
                    message:
                        post.status == Status.read ? 'Mark unread' : 'Mark read',
                    child: ActionIconButton(
                      icon: post.status == Status.read
                          ? Iconsax.tick_circle
                          : Iconsax.eye,
                      color: post.status == Status.read
                          ? Colors.green
                          : AppTheme.mutedForeground,
                      onTap: () => _toggleRead(context),
                      semanticLabel: 'Toggle read',
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing1),
                  Tooltip(
                    message: 'Share',
                    child: AnimatedBuilder(
                      animation: shareAnimation,
                      builder: (context, child) {
                        final highlight = shareAnimation.value > 0;
                        return ActionIconButton(
                          icon:
                              highlight ? Iconsax.tick_circle : Iconsax.share,
                          color: AppTheme.accentColor,
                          onTap: () {
                            final String shareText = '${post.title}\n${post.link}';
                            Share.share(shareText);
                            isShared.value = true;
                          },
                          semanticLabel: 'Share post',
                          highlighted: highlight,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacing2),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.calendar,
                    size: 12,
                    color: AppTheme.mutedForeground,
                  ),
                  const SizedBox(width: AppTheme.spacing1),
                  Text(
                    formattedDate,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mutedForeground,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleStar(BuildContext context) {
    final newStatus =
        post.status == Status.starred ? Status.unread : Status.starred;
    final updated = post.copyWith(status: newStatus);
    context.read<PostBloc>().add(UpdatePost(updated));
  }

  void _toggleRead(BuildContext context) {
    if (post.status == Status.read) {
      final updated = post.copyWith(status: Status.unread);
      context.read<PostBloc>().add(UpdatePost(updated));
    } else {
      final updated =
          post.copyWith(status: Status.read, lastOpenedAt: DateTime.now());
      context.read<PostBloc>().add(UpdatePost(updated));
    }
  }
}

IconData _getTypeIcon(String type) {
  switch (type) {
    case 'Job':
      return Iconsax.briefcase;
    case 'Article':
      return Iconsax.document;
    case 'Tip':
      return Iconsax.lamp;
    case 'Opportunity':
      return Iconsax.star;
    case 'Other':
      return Iconsax.more;
    default:
      return Iconsax.info_circle;
  }
}

IconData _getPlatformIcon(String platform) {
  if (platform.isEmpty) {
    return Iconsax.mobile;
  }
  switch (platform.toLowerCase()) {
    case 'twitter':
    case 'x':
      return Iconsax.message;
    case 'linkedin':
      return Iconsax.briefcase;
    case 'facebook':
      return Iconsax.message_favorite;
    case 'instagram':
      return Iconsax.camera;
    case 'youtube':
      return Iconsax.play;
    case 'github':
      return Iconsax.code;
    case 'medium':
      return Iconsax.document;
    case 'reddit':
      return Iconsax.message_question;
    case 'whatsapp':
      return Iconsax.message_text;
    case 'telegram':
      return Iconsax.send;
    default:
      return Iconsax.mobile;
  }
}
