import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_theme.dart';
import '../blocs/post_bloc.dart';
import '../blocs/tag_bloc.dart';
import '../models/saved_post.dart';
import '../screens/tags_screen.dart';

class TagsSection extends StatelessWidget {
  final ValueNotifier<bool> isEditing;
  final SavedPost post;

  const TagsSection({super.key, required this.isEditing, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        final currentPost = state is PostLoaded
            ? (state.posts.firstWhere(
                (p) => p.id == post.id,
                orElse: () => post,
              ))
            : post;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tag, size: 16, color: AppTheme.mutedForeground),
                const SizedBox(width: 8),
                const Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.foregroundColor,
                  ),
                ),
                const Spacer(),
                if (isEditing.value)
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => BlocBuilder<TagBloc, TagState>(
                        builder: (context, state) {
                          if (state is TagLoaded) {
                            return AlertDialog(
                              title: const Text('Add Tag'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: state.tags.length,
                                  itemBuilder: (context, index) {
                                    final tag = state.tags[index];
                                    final isSelected = currentPost.tags.contains(tag.name);

                                    return ListTile(
                                      title: Text(tag.name),
                                      trailing: isSelected
                                          ? const Icon(Icons.check, color: Colors.green)
                                          : null,
                                      onTap: isSelected
                                          ? null
                                          : () {
                                              final updatedPost = currentPost.copyWith(
                                                tags: [...currentPost.tags, tag.name],
                                              );
                                              context.read<PostBloc>().add(UpdatePost(updatedPost));
                                              Navigator.pop(context);
                                            },
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const TagsScreen()),
                                    );
                                  },
                                  child: const Text('Manage Tags'),
                                ),
                              ],
                            );
                          }
                          return const AlertDialog(
                            title: Text('Loading...'),
                            content: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                    tooltip: 'Add tag',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing3),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: currentPost.tags.isEmpty
                  ? const Text(
                      'No tags added',
                      style: TextStyle(
                        color: AppTheme.mutedForeground,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Wrap(
                      spacing: AppTheme.spacing2,
                      runSpacing: AppTheme.spacing1,
                      children: currentPost.tags
                          .map((tag) => Container(
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
                                      Icons.tag,
                                      size: 12,
                                      color: AppTheme.mutedForeground,
                                    ),
                                    const SizedBox(width: AppTheme.spacing1),
                                    Text(
                                      tag,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (isEditing.value) ...[
                                      const SizedBox(width: AppTheme.spacing1),
                                      GestureDetector(
                                        onTap: () {
                                          final updatedPost = currentPost.copyWith(
                                            tags: currentPost.tags.where((t) => t != tag).toList(),
                                          );
                                          context.read<PostBloc>().add(UpdatePost(updatedPost));
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 12,
                                          color: AppTheme.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }
}
