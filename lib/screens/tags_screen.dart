import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../blocs/post_bloc.dart';
import '../blocs/tag_bloc.dart';
import '../constants/app_theme.dart';
import '../models/tag.dart';
import '../widgets/empty_state.dart';
import '../widgets/ui/input.dart';

class TagsScreen extends HookWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.cardColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Tags',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.foregroundColor,
                letterSpacing: -0.025,
              ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(AppTheme.spacing2),
            child: Material(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                onTap: () => _showAddTagDialog(context),
                child: const Padding(
                  padding: EdgeInsets.all(AppTheme.spacing2),
                  child: Icon(
                    Iconsax.add,
                    color: AppTheme.accentForeground,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<TagBloc, TagState>(
        builder: (context, state) {
          if (state is TagLoading) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          } else if (state is TagLoaded) {
            if (state.tags.isEmpty) {
              return const EmptyState(
                icon: Iconsax.tag,
                message: 'No tags yet',
                subMessage: 'Create your first tag to organize your posts',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              itemCount: state.tags.length,
              itemBuilder: (context, index) {
                final tag = state.tags[index];
                return _buildTagCard(context, tag);
              },
            );
          } else if (state is TagError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 48,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildTagCard(BuildContext context, Tag tag) {
    final tagColor = tag.color != null
        ? Color(int.parse(tag.color!.replaceFirst('#', '0xFF')))
        : AppTheme.mutedForeground;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: BlocBuilder<PostBloc, PostState>(
        builder: (context, postState) {
          final usage = postState is PostLoaded
              ? postState.posts
                  .where((p) => p.tags
                      .any((t) => t.toLowerCase() == tag.name.toLowerCase()))
                  .length
              : 0;
          final hasUsage = usage > 0;
          // Haptic feedback flags per swipe gesture
          bool sentLeftHaptic = false;
          bool sentRightHaptic = false;

          return Dismissible(
            key: ValueKey(tag.id),
            direction: DismissDirection.horizontal,
            background: Container(
              alignment: Alignment.centerLeft,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              child: const Row(
                children: [
                  Icon(Iconsax.edit, color: AppTheme.primaryColor, size: 20),
                  SizedBox(width: AppTheme.spacing2),
                  Text('Edit',
                      style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
              color: AppTheme.destructiveColor.withValues(alpha: 0.12),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Delete',
                      style: TextStyle(
                          color: AppTheme.destructiveColor,
                          fontWeight: FontWeight.w600)),
                  SizedBox(width: AppTheme.spacing2),
                  Icon(Iconsax.trash,
                      color: AppTheme.destructiveColor, size: 20),
                ],
              ),
            ),
            onUpdate: (details) {
              // Fire a light haptic once when progress crosses threshold per direction
              if (details.direction == DismissDirection.startToEnd) {
                if (!sentLeftHaptic && details.progress > 0.6) {
                  HapticFeedback.selectionClick();
                  sentLeftHaptic = true;
                }
              } else if (details.direction == DismissDirection.endToStart) {
                if (!sentRightHaptic && details.progress > 0.6) {
                  HapticFeedback.selectionClick();
                  sentRightHaptic = true;
                }
              }
            },
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                _showEditTagDialog(context, tag);
                return false;
              }
              if (direction == DismissDirection.endToStart) {
                _showDeleteConfirmation(context, tag);
                return false;
              }
              return false;
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing2,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: tagColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Iconsax.tag,
                  color: tagColor,
                  size: 20,
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      tag.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.foregroundColor,
                          ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing2,
                      vertical: AppTheme.spacing1,
                    ),
                    decoration: BoxDecoration(
                      color: hasUsage
                          ? AppTheme.primaryColor.withValues(alpha: 0.10)
                          : AppTheme.mutedColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(
                        color: hasUsage
                            ? AppTheme.primaryColor.withValues(alpha: 0.30)
                            : AppTheme.borderColor,
                      ),
                    ),
                    child: Text(
                      usage.toString(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: hasUsage
                                ? AppTheme.primaryColor
                                : AppTheme.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              subtitle: tag.color != null
                  ? Text(
                      tag.color!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.mutedForeground,
                          ),
                    )
                  : null,
              trailing: null,
            ),
          );
        },
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _TagDialog(
        title: 'Add Tag',
        onSave: (name, color) {
          final tag = Tag(id: '', name: name, color: color);
          context.read<TagBloc>().add(AddTag(tag));
        },
      ),
    );
  }

  void _showEditTagDialog(BuildContext context, Tag tag) {
    showDialog(
      context: context,
      builder: (ctx) => _TagDialog(
        title: 'Edit Tag',
        initialName: tag.name,
        initialColor: tag.color,
        onSave: (name, color) {
          final updatedTag = tag.copyWith(name: name, color: color);
          final oldName = tag.name;
          context.read<TagBloc>().add(UpdateTag(updatedTag));
          if (oldName.trim() != name.trim()) {
            context
                .read<PostBloc>()
                .add(RenameTagInAllPosts(oldName.trim(), name.trim()));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tag renamed and updated across all posts'),
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Tag tag) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text('Are you sure you want to delete "${tag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.destructiveColor,
            ),
            onPressed: () {
              // Delete tag entity
              context.read<TagBloc>().add(DeleteTag(tag.id));
              // Remove this tag from all posts
              context.read<PostBloc>().add(RemoveTagFromAllPosts(tag.name));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Tag deleted and removed from all posts')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TagDialog extends HookWidget {
  final String title;
  final String? initialName;
  final String? initialColor;
  final Function(String name, String? color) onSave;

  const _TagDialog({
    required this.title,
    required this.onSave,
    this.initialName,
    this.initialColor,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController(text: initialName ?? '');
    final colorController = useTextEditingController(text: initialColor ?? '');
    final selectedColor = useState<Color?>(
      initialColor != null
          ? Color(int.parse(initialColor!.replaceFirst('#', '0xFF')))
          : null,
    );

    final predefinedColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
    ];

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShadcnInput(
                label: 'Tag Name',
                controller: nameController,
                placeholder: 'Enter tag name',
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                'Color (optional)',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.foregroundColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              Wrap(
                spacing: AppTheme.spacing2,
                runSpacing: AppTheme.spacing2,
                children: predefinedColors.map((color) {
                  final isSelected = selectedColor.value == color;
                  return GestureDetector(
                    onTap: () {
                      selectedColor.value = color;
                      colorController.text =
                          '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: isSelected
                            ? Border.all(
                                color: AppTheme.foregroundColor, width: 2)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Iconsax.tick_circle,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spacing3),
              ShadcnInput(
                label: 'Custom Color (hex)',
                controller: colorController,
                placeholder: '#FF5733',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isNotEmpty) {
              final color = colorController.text.trim().isEmpty
                  ? null
                  : colorController.text.trim();
              onSave(name, color);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
