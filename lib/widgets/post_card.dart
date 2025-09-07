import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

import '../constants/app_theme.dart';
import '../models/saved_post.dart';
import 'ui/card.dart';
import 'post_card/post_card_header.dart';
import 'post_card/post_card_link.dart';
import 'post_card/post_card_tags_status.dart';
import 'post_card/post_card_footer.dart';

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
    // Copy and share animation states
    final isCopied = useState(false);
    final isShared = useState(false);

    final copyController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    final shareController = useAnimationController(
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

    return AnimationConfiguration.staggeredGrid(
      position: 1,
      duration: const Duration(milliseconds: 375),
      columnCount: 1,
      child: SlideAnimation(
        verticalOffset: 30.0,
        child: FadeInAnimation(
          child: ShadcnCard(
            onTap: onTap,
            margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
            padding: const EdgeInsets.all(AppTheme.spacing5),
            showShadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostCardHeader(post: post),
                const SizedBox(height: AppTheme.spacing3),
                PostCardLink(
                  link: post.link,
                  copyController: copyController,
                  isCopied: isCopied,
                ),
                const SizedBox(height: AppTheme.spacing3),
                PostCardTagsStatus(post: post),
                const SizedBox(height: AppTheme.spacing4),
                PostCardFooter(
                  post: post,
                  formattedDate: formattedDate,
                  shareController: shareController,
                  isShared: isShared,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
