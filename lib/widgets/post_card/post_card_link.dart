import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../constants/app_theme.dart';

class PostCardLink extends HookWidget {
  final String link;
  final AnimationController copyController;
  final ValueNotifier<bool> isCopied;

  const PostCardLink({
    super.key,
    required this.link,
    required this.copyController,
    required this.isCopied,
  });

  @override
  Widget build(BuildContext context) {
    final copyAnimation = CurvedAnimation(
      parent: copyController,
      curve: Curves.easeInOut,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.mutedColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            onTap: () {
              Clipboard.setData(ClipboardData(text: link));
              isCopied.value = true;
            },
            child: AnimatedBuilder(
              animation: copyAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(AppTheme.spacing1),
                  decoration: BoxDecoration(
                    color: copyAnimation.value > 0
                        ? AppTheme.accentColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    copyAnimation.value > 0
                        ? Iconsax.tick_circle
                        : Iconsax.copy,
                    size: 14,
                    color: AppTheme.accentColor,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppTheme.spacing2),
          const Icon(
            Iconsax.link,
            size: 14,
            color: AppTheme.mutedForeground,
          ),
          const SizedBox(width: AppTheme.spacing2),
          Expanded(
            child: Text(
              link,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedForeground,
                    fontFamily: 'monospace',
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
