import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/post_bloc.dart';
import '../constants/app_theme.dart';
import '../models/saved_post.dart';

class HighlightsSection extends StatelessWidget {
  final ValueNotifier<bool> isEditing;
  final SavedPost post;

  const HighlightsSection({super.key, required this.isEditing, required this.post});

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
                const Icon(Icons.highlight, size: 16, color: AppTheme.mutedForeground),
                const SizedBox(width: 8),
                const Text(
                  'Highlights',
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
                      builder: (context) {
                        final controller = TextEditingController();
                        return AlertDialog(
                          title: const Text('Add Highlight'),
                          content: TextField(
                            controller: controller,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Enter highlight text...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (controller.text.trim().isNotEmpty) {
                                  final updatedPost = currentPost.copyWith(
                                    highlights: [
                                      ...currentPost.highlights,
                                      controller.text.trim(),
                                    ],
                                  );
                                  context.read<PostBloc>().add(UpdatePost(updatedPost));
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    ),
                    tooltip: 'Add highlight',
                  ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing3),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: currentPost.highlights.isEmpty
                  ? const Text(
                      'No highlights added',
                      style: TextStyle(
                        color: AppTheme.mutedForeground,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: currentPost.highlights.asMap().entries.map((entry) {
                        final index = entry.key;
                        final highlight = entry.value;
                        return Container(
                          margin: EdgeInsets.only(
                            bottom: index < currentPost.highlights.length - 1 ? AppTheme.spacing2 : 0,
                          ),
                          padding: const EdgeInsets.all(AppTheme.spacing2),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(
                              color: Colors.yellow.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.format_quote,
                                size: 14,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: AppTheme.spacing2),
                              Expanded(
                                child: Text(
                                  highlight,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              if (isEditing.value)
                                GestureDetector(
                                  onTap: () {
                                    final updatedHighlights = List<String>.from(currentPost.highlights);
                                    updatedHighlights.removeAt(index);
                                    final updatedPost = currentPost.copyWith(highlights: updatedHighlights);
                                    context.read<PostBloc>().add(UpdatePost(updatedPost));
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppTheme.mutedForeground,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        );
      },
    );
  }
}
