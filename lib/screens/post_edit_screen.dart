import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../blocs/post_bloc.dart';
import '../constants/app_theme.dart';
import '../models/saved_post.dart';
import '../widgets/animated_form_field.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/highlights_section.dart';
import '../widgets/section_card.dart';
import '../widgets/tags_section.dart';

class PostEditScreen extends HookWidget {
  const PostEditScreen({super.key, required this.post});

  final SavedPost post;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    // Controllers with initial values
    final titleController = useTextEditingController(text: post.title);
    final linkController = useTextEditingController(text: post.link);

    // Editable state (always true on edit screen)
    final isEditing = useState(true);

    // Dropdown states
    final selectedType = useState(post.type);
    final selectedPriority = useState(post.priority);
    final selectedPlatform = useState(post.platform);

    void save() {
      if (formKey.currentState!.validate()) {
        // Use the latest post from Bloc state to avoid overwriting tags/highlights
        final postState = context.read<PostBloc>().state;
        final latestPost = postState is PostLoaded
            ? (postState.posts.firstWhere(
                (p) => p.id == post.id,
                orElse: () => post,
              ))
            : post;

        final updated = latestPost.copyWith(
          title: titleController.text.trim(),
          link: linkController.text.trim(),
          type: selectedType.value,
          priority: selectedPriority.value,
          platform: selectedPlatform.value,
        );
        context.read<PostBloc>().add(UpdatePost(updated));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post updated successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.pop(context);
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.cardColor,
        centerTitle: true,
        title: const Text('Edit Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppTheme.primaryColor),
            onPressed: save,
            tooltip: 'Save changes',
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          children: [
            // Created date (read-only info)
            SectionCard(
              title: 'Created',
              icon: Icons.schedule,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: AppTheme.mutedColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: AppTheme.mutedForeground),
                    const SizedBox(width: AppTheme.spacing2),
                    Text(
                      DateFormat('MMMM d, yyyy').format(post.createdAt),
                      style: const TextStyle(
                        color: AppTheme.mutedForeground,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacing4),

            // Title
            AnimatedFormField(
              label: 'Title / Note',
              icon: Icons.title,
              controller: titleController,
              readOnly: !isEditing.value,
              isEditing: isEditing.value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title or note';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.spacing4),

            // Link
            AnimatedFormField(
              label: 'Post URL',
              icon: Icons.link,
              controller: linkController,
              readOnly: !isEditing.value,
              isEditing: isEditing.value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the LinkedIn post URL';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.spacing4),

            // Settings
            SectionCard(
              title: 'Settings',
              icon: Icons.settings_outlined,
              child: Column(
                children: [
                  DropdownField(
                    label: 'Post Type',
                    icon: Icons.category,
                    value: selectedType.value.toString().split('.').last,
                    items: PostType.values
                        .map((e) => e.toString().split('.').last)
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedType.value = PostType.values.firstWhere(
                            (e) => e.toString().split('.').last == value);
                      }
                    },
                    isEditing: true,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  DropdownField(
                    label: 'Priority',
                    icon: Icons.flag,
                    value: selectedPriority.value.toString().split('.').last,
                    items: Priority.values
                        .map((e) => e.toString().split('.').last)
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedPriority.value = Priority.values.firstWhere(
                            (e) => e.toString().split('.').last == value);
                      }
                    },
                    isEditing: true,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  DropdownField(
                    label: 'Platform',
                    icon: Icons.language,
                    value: selectedPlatform.value.toString().split('.').last,
                    items: Platform.values
                        .map((e) => e.toString().split('.').last)
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedPlatform.value = Platform.values.firstWhere(
                            (e) => e.toString().split('.').last == value);
                      }
                    },
                    isEditing: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing3),

            // Tags and Highlights (editable)
            TagsSection(isEditing: isEditing, post: post),
            const SizedBox(height: AppTheme.spacing2),

            HighlightsSection(isEditing: isEditing, post: post),

            const SizedBox(height: AppTheme.spacing2),

            // Reminders management

            const SizedBox(height: AppTheme.spacing6),

            // Save button for convenience
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save changes'),
              ),
            ),
            const SizedBox(height: AppTheme.spacing6),
          ],
        ),
      ),
    );
  }
}
