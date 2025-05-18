import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_theme.dart';
import '../models/saved_post.dart';

class PostCard extends HookWidget {
  final SavedPost post;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Animation controllers
    final hoverController = useAnimationController(
      duration: const Duration(milliseconds: 200),
      initialValue: 0,
    );

    final elevationAnimation = useAnimation(
      Tween<double>(begin: 2, end: 8).animate(
        CurvedAnimation(parent: hoverController, curve: Curves.easeInOut),
      ),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 1.0, end: 1.03).animate(
        CurvedAnimation(parent: hoverController, curve: Curves.easeInOut),
      ),
    );

    final borderColorAnimation = useAnimation(
          ColorTween(
            begin: post.platform.isNotEmpty
                ? AppTheme.getPlatformColor(post.platform)
                    .withValues(alpha: 0.3)
                : AppTheme.getPostTypeColor(post.type).withValues(alpha: 0.3),
            end: post.platform.isNotEmpty
                ? AppTheme.getPlatformColor(post.platform)
                    .withValues(alpha: 0.8)
                : AppTheme.getPostTypeColor(post.type).withValues(alpha: 0.8),
          ).animate(
            CurvedAnimation(parent: hoverController, curve: Curves.easeInOut),
          ),
        ) ??
        (post.platform.isNotEmpty
            ? AppTheme.getPlatformColor(post.platform).withValues(alpha: 0.3)
            : AppTheme.getPostTypeColor(post.type).withValues(alpha: 0.3));

    // Copy animation state
    final isCopied = useState(false);
    final copyController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    useEffect(() {
      if (isCopied.value) {
        copyController.forward().then((_) {
          copyController.reset();
          isCopied.value = false;
        });
      }
      return null;
    }, [isCopied.value]);

    // Share animation state
    final isShared = useState(false);
    final shareController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    useEffect(() {
      if (isShared.value) {
        shareController.forward().then((_) {
          shareController.reset();
          isShared.value = false;
        });
      }
      return null;
    }, [isShared.value]);

    // Format date
    final formattedDate = DateFormat('MMM d, yyyy').format(post.createdAt);

    return MouseRegion(
      onEnter: (_) => hoverController.forward(),
      onExit: (_) => hoverController.reverse(),
      child: AnimationConfiguration.staggeredGrid(
        position: 1,
        duration: const Duration(milliseconds: 375),
        columnCount: 1,
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: Transform.scale(
              scale: scaleAnimation,
              child: Card(
                margin: const EdgeInsets.only(bottom: AppTheme.defaultPadding),
                elevation: elevationAnimation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  side: BorderSide(
                    color: borderColorAnimation,
                    width: 1,
                  ),
                ),
                // shadowColor: post.platform.isNotEmpty
                //     ? AppTheme.getPlatformColor(post.platform)
                //     : AppTheme.getPostTypeColor(post.type),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: AppTheme.smallPadding),
                        _buildLink(context, copyController, isCopied),
                        const SizedBox(height: AppTheme.defaultPadding),
                        _buildFooter(
                            context, formattedDate, shareController, isShared),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            post.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppTheme.smallPadding),
        _buildPriorityChip(context),
      ],
    );
  }

  Widget _buildLink(BuildContext context, AnimationController copyController,
      ValueNotifier<bool> isCopied) {
    final copyAnimation = CurvedAnimation(
      parent: copyController,
      curve: Curves.easeInOut,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.smallPadding,
        vertical: 6.0,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Clipboard.setData(ClipboardData(text: post.link));
              isCopied.value = true;
            },
            child: AnimatedBuilder(
              animation: copyAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: copyAnimation.value > 0
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    copyAnimation.value > 0
                        ? Iconsax.tick_circle
                        : Iconsax.copy,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Iconsax.link,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              post.link,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, String formattedDate,
      AnimationController shareController, ValueNotifier<bool> isShared) {
    final shareAnimation = CurvedAnimation(
      parent: shareController,
      curve: Curves.easeInOut,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildTypeChip(context),
            if (post.platform.isNotEmpty) ...[
              const SizedBox(width: AppTheme.smallPadding),
              _buildPlatformChip(context),
            ],
          ],
        ),
        Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                final String shareText = '${post.title}\n${post.link}';
                Share.share(shareText);
                isShared.value = true;
              },
              child: AnimatedBuilder(
                animation: shareAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: shareAnimation.value > 0
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      shareAnimation.value > 0
                          ? Iconsax.tick_circle
                          : Iconsax.share,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Iconsax.calendar,
              size: 12,
              color: AppTheme.lightTextColor,
            ),
            const SizedBox(width: 4),
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTextColor,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityChip(BuildContext context) {
    final color = AppTheme.getPriorityColor(post.priority);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.smallPadding,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            post.priority,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getPriorityIcon() {
    switch (post.priority) {
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

  Widget _buildTypeChip(BuildContext context) {
    final color = AppTheme.getPostTypeColor(post.type);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.smallPadding,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTypeIcon(),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            post.type,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (post.type) {
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

  Widget _buildPlatformChip(BuildContext context) {
    final color = post.platform.isNotEmpty
        ? AppTheme.getPlatformColor(post.platform)
        : Colors.blueGrey;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.smallPadding,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPlatformIcon(),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            post.platform,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon() {
    if (post.platform.isEmpty) {
      return Iconsax.mobile;
    }

    switch (post.platform.toLowerCase()) {
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
}
