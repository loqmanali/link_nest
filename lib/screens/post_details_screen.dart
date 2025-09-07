import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/folder_bloc.dart';
import '../blocs/post_bloc.dart';
import '../blocs/reminder_bloc.dart';
import '../constants/app_theme.dart';
import '../models/folder.dart';
import '../models/reminder.dart';
import '../models/saved_post.dart';
import '../repositories/folder_repository.dart';
import '../widgets/animated_form_field.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/highlights_section.dart';
import '../widgets/open_button.dart';
import '../widgets/priority_chip.dart';
import '../widgets/reminder_dialog.dart';
import '../widgets/reminders_section.dart';
import '../widgets/section_card.dart';
import '../widgets/tags_section.dart';
import '../widgets/type_chip.dart';
import 'webview_screen.dart';

class PostDetailsScreen extends HookWidget {
  final SavedPost post;

  const PostDetailsScreen({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    // Update lastOpenedAt when screen is first built
    useEffect(() {
      final updatedPost = post.copyWith(lastOpenedAt: DateTime.now());
      context.read<PostBloc>().add(UpdatePost(updatedPost));
      return null;
    }, []);

    // Form controllers initialized with existing values
    final titleController = useTextEditingController(text: post.title);
    final linkController = useTextEditingController(text: post.link);

    // State for dropdowns
    final selectedType = useState(post.type);
    final selectedPriority = useState(post.priority);
    final selectedPlatform = useState(post.platform);

    // Form key for validation
    final formKey = GlobalKey<FormState>();

    // State for edit mode
    final isEditing = useState(false);

    // Animation controllers
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    // Animations for edit mode transition
    useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      ),
    );

    // Run animation when edit mode changes
    useEffect(() {
      if (isEditing.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return null;
    }, [isEditing.value]);

    // Get current folder if post is in a folder
    final folderRepository = context.read<FolderRepository>();
    final currentFolder = post.folderId != null
        ? folderRepository.getFolderById(post.folderId!)
        : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.cardColor,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Post Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            color: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            onSelected: (value) {
              switch (value) {
                case 'folder':
                  _showFolderSelector(context, post);
                  break;
                case 'reminder':
                  _showReminderDialog(context);
                  break;
                case 'edit':
                  if (isEditing.value) {
                    // Save changes
                    if (formKey.currentState!.validate()) {
                      // Use the latest post from Bloc state to avoid overwriting tags/highlights
                      final postState = context.read<PostBloc>().state;
                      final latestPost = postState is PostLoaded
                          ? (postState.posts.firstWhere(
                              (p) => p.id == post.id,
                              orElse: () => post,
                            ))
                          : post;

                      _updatePost(
                        context,
                        latestPost.copyWith(
                          title: titleController.text.trim(),
                          link: linkController.text.trim(),
                          type: selectedType.value,
                          priority: selectedPriority.value,
                          platform: selectedPlatform.value,
                        ),
                      );
                      isEditing.value = false;
                    }
                  } else {
                    // Enter edit mode
                    // Sync controllers and selections with the latest post state
                    final postState = context.read<PostBloc>().state;
                    final latestPost = postState is PostLoaded
                        ? (postState.posts.firstWhere(
                            (p) => p.id == post.id,
                            orElse: () => post,
                          ))
                        : post;

                    titleController.text = latestPost.title;
                    linkController.text = latestPost.link;
                    selectedType.value = latestPost.type;
                    selectedPriority.value = latestPost.priority;
                    selectedPlatform.value = latestPost.platform;

                    isEditing.value = true;
                  }
                  break;
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'folder',
                child: Row(
                  children: [
                    Icon(
                      Icons.folder,
                      color: AppTheme.foregroundColor,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Add to folder',
                      style: TextStyle(
                        color: AppTheme.foregroundColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'reminder',
                child: Row(
                  children: [
                    Icon(
                      Icons.alarm_add,
                      color: AppTheme.foregroundColor,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Set reminder',
                      style: TextStyle(
                        color: AppTheme.foregroundColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isEditing.value
                            ? Icons.check_rounded
                            : Icons.edit_rounded,
                        key: ValueKey<bool>(isEditing.value),
                        color: isEditing.value
                            ? AppTheme.primaryColor
                            : AppTheme.foregroundColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing.value ? 'Save changes' : 'Edit post',
                      style: TextStyle(
                        color: isEditing.value
                            ? AppTheme.primaryColor
                            : AppTheme.foregroundColor,
                        fontSize: 14,
                        fontWeight: isEditing.value
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: AppTheme.errorColor,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Delete post',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing4),
          children: [
            // Type and Priority chips
            SectionCard(
              title: 'Classification',
              icon: Icons.label_outline,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TypeChip(type: selectedType.value),
                  const SizedBox(width: AppTheme.spacing3),
                  PriorityChip(priority: selectedPriority.value),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing4),

            // Current folder indicator (if in a folder)
            if (currentFolder != null)
              SectionCard(
                title: 'Folder',
                icon: Icons.folder_outlined,
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: Color(int.parse(currentFolder.color.substring(1),
                                radix: 16) +
                            0xFF000000)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: Color(int.parse(currentFolder.color.substring(1),
                                  radix: 16) +
                              0xFF000000)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder,
                        size: 16,
                        color: Color(int.parse(currentFolder.color.substring(1),
                                radix: 16) +
                            0xFF000000),
                      ),
                      const SizedBox(width: AppTheme.spacing2),
                      Expanded(
                        child: Text(
                          currentFolder.name,
                          style: TextStyle(
                            color: Color(int.parse(
                                    currentFolder.color.substring(1),
                                    radix: 16) +
                                0xFF000000),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _removeFromFolder(context, post),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacing1),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Color(int.parse(
                                    currentFolder.color.substring(1),
                                    radix: 16) +
                                0xFF000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (currentFolder != null)
              const SizedBox(height: AppTheme.spacing4),

            // Created date
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

            // Title field
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

            // Link field
            AnimatedFormField(
              label: 'LinkedIn Post URL',
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

            // Post Type and Priority dropdowns
            SectionCard(
              title: 'Settings',
              icon: Icons.settings_outlined,
              child: Column(
                children: [
                  // Post Type dropdown
                  DropdownField(
                    label: 'Post Type',
                    icon: Icons.category,
                    value: selectedType.value.toString().split('.').last,
                    items: PostType.values
                        .map((e) => e.toString().split('.').last)
                        .toList(),
                    onChanged: isEditing.value
                        ? (value) {
                            if (value != null) {
                              selectedType.value = PostType.values.firstWhere(
                                  (e) => e.toString().split('.').last == value);
                            }
                          }
                        : null,
                    isEditing: isEditing.value,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  // Priority dropdown
                  DropdownField(
                    label: 'Priority',
                    icon: Icons.flag,
                    value: selectedPriority.value.toString().split('.').last,
                    items: Priority.values
                        .map((e) => e.toString().split('.').last)
                        .toList(),
                    onChanged: isEditing.value
                        ? (value) {
                            if (value != null) {
                              selectedPriority.value = Priority.values
                                  .firstWhere((e) =>
                                      e.toString().split('.').last == value);
                            }
                          }
                        : null,
                    isEditing: isEditing.value,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  // Platform dropdown
                  DropdownField(
                    label: 'Platform',
                    icon: Icons.language,
                    value: selectedPlatform.value.toString().split('.').last,
                    items: Platform.values
                        .map((e) => e.toString().split('.').last)
                        .toList(),
                    onChanged: isEditing.value
                        ? (value) {
                            if (value != null) {
                              selectedPlatform.value = Platform.values
                                  .firstWhere((e) =>
                                      e.toString().split('.').last == value);
                            }
                          }
                        : null,
                    isEditing: isEditing.value,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing4),

            // Tags section
            TagsSection(isEditing: isEditing, post: post),

            const SizedBox(height: AppTheme.spacing4),

            // Highlights section
            HighlightsSection(isEditing: isEditing, post: post),

            const SizedBox(height: AppTheme.spacing4),

            // Reminders section
            RemindersSection(post: post),

            const SizedBox(height: AppTheme.spacing4),

            const SizedBox(height: AppTheme.spacing6),

            // Action buttons
            SectionCard(
              title: 'Actions',
              icon: Icons.launch,
              child: Column(
                children: [
                  // Open in App button
                  OpenButton(
                    label: 'OPEN IN APP',
                    icon: Icons.open_in_new,
                    isPrimary: true,
                    onPressed: () => _openInApp(context, post.link, post.title),
                  ),
                  const SizedBox(height: AppTheme.spacing3),
                  // Open in Browser button
                  OpenButton(
                    label: 'OPEN IN BROWSER',
                    icon: Icons.language,
                    isPrimary: false,
                    onPressed: () => _openInBrowser(post.link),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing6),
          ],
        ),
      ),
    );
  }

  void _updatePost(BuildContext context, SavedPost updatedPost) {
    context.read<PostBloc>().add(UpdatePost(updatedPost));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post updated successfully!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _deletePost(BuildContext context) {
    context.read<PostBloc>().add(DeletePost(post.id));

    Navigator.pop(context); // Close dialog
    Navigator.pop(context); // Go back to home

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post deleted'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this saved post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => _deletePost(context),
            child: const Text(
              'DELETE',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _openInApp(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(
          url: url,
          title: title,
        ),
      ),
    );
  }

  // Helper method to ensure URL has proper scheme
  String _ensureUrlScheme(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    // Default to https for URLs without scheme
    return 'https://$url';
  }

  Future<void> _openInBrowser(String url) async {
    final String properUrl = _ensureUrlScheme(url);
    final Uri uri = Uri.parse(properUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $properUrl');
    }
  }

  void _showFolderSelector(BuildContext context, SavedPost post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return BlocBuilder<FolderBloc, FolderState>(
          builder: (context, state) {
            if (state is FolderLoaded) {
              final folders = state.folders;
              final folderRepository = context.read<FolderRepository>();
              final currentFolder = post.folderId != null
                  ? folderRepository.getFolderById(post.folderId!)
                  : null;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Select Folder',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: folders.isEmpty
                        ? const Center(
                            child: Text('No folders available'),
                          )
                        : ListView.builder(
                            itemCount: folders.length,
                            itemBuilder: (context, index) {
                              final folder = folders[index];
                              final isSelected = post.folderId == folder.id;
                              final folderColor = Color(int.parse(
                                      folder.color.substring(1),
                                      radix: 16) +
                                  0xFF000000);

                              return ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: folderColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: folderColor, width: 1),
                                  ),
                                  child: Icon(Icons.folder,
                                      color: folderColor, size: 24),
                                ),
                                title: Text(folder.name),
                                subtitle: folder.description != null &&
                                        folder.description!.isNotEmpty
                                    ? Text(
                                        folder.description!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle,
                                        color: AppTheme.primaryColor)
                                    : null,
                                onTap: () {
                                  if (isSelected) {
                                    _removeFromFolder(context, post);
                                  } else {
                                    _addToFolder(context, post, folder);
                                  }
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentFolder != null)
                          TextButton(
                            onPressed: () {
                              _removeFromFolder(context, post);
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Remove from folder'),
                          )
                        else
                          const SizedBox(),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      },
    );
  }

  void _addToFolder(BuildContext context, SavedPost post, Folder folder) {
    context.read<FolderBloc>().add(AddPostToFolder(post.id, folder.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to folder: ${folder.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeFromFolder(BuildContext context, SavedPost post) {
    if (post.folderId != null) {
      context.read<FolderBloc>().add(RemovePostFromFolder(post.id));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from folder'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ReminderDialog(
        postId: post.id,
        postTitle: post.title,
        onSave: (dueAt, repeat) {
          final reminder = Reminder(
            id: '',
            postId: post.id,
            dueAt: dueAt,
            repeat: repeat,
          );
          context.read<ReminderBloc>().add(AddReminder(reminder));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder set successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}
