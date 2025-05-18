import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/folder_bloc.dart';
import '../blocs/post_bloc.dart';
import '../constants/app_theme.dart';
import '../models/folder.dart';
import '../models/saved_post.dart';
import '../repositories/folder_repository.dart';
import 'webview_screen.dart';

class PostDetailsScreen extends HookWidget {
  final SavedPost post;

  const PostDetailsScreen({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
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

    // Platform options
    final platforms = Platform.values;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Post Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          // Folder button
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () => _showFolderSelector(context, post),
            tooltip: 'Add to folder',
          ),
          // Toggle edit mode
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Container(
                key: ValueKey<bool>(isEditing.value),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isEditing.value
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEditing.value ? Icons.check_rounded : Icons.edit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            onPressed: () {
              if (isEditing.value) {
                // Save changes
                if (formKey.currentState!.validate()) {
                  _updatePost(
                    context,
                    post.copyWith(
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
                isEditing.value = true;
              }
            },
          ),
          // Delete post
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Type and Priority chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTypeChip(context, selectedType.value),
                const SizedBox(width: 12),
                _buildPriorityChip(context, selectedPriority.value),
              ],
            ),

            const SizedBox(height: 16),

            // Current folder indicator (if in a folder)
            if (currentFolder != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Color(int.parse(currentFolder.color.substring(1),
                              radix: 16) +
                          0xFF000000)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(int.parse(currentFolder.color.substring(1),
                                radix: 16) +
                            0xFF000000)
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder,
                      size: 16,
                      color: Color(int.parse(currentFolder.color.substring(1),
                              radix: 16) +
                          0xFF000000),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'In folder: ${currentFolder.name}',
                      style: TextStyle(
                        color: Color(int.parse(currentFolder.color.substring(1),
                                radix: 16) +
                            0xFF000000),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _removeFromFolder(context, post),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Color(int.parse(currentFolder.color.substring(1),
                                radix: 16) +
                            0xFF000000),
                      ),
                    ),
                  ],
                ),
              ),

            // Created date
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: AppTheme.lightTextColor),
                  const SizedBox(width: 8),
                  Text(
                    'Added on ${DateFormat('MMMM d, yyyy').format(post.createdAt)}',
                    style: const TextStyle(
                      color: AppTheme.lightTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Title field
            _buildAnimatedFormField(
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

            const SizedBox(height: 16),

            // Link field
            _buildAnimatedFormField(
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

            const SizedBox(height: 16),

            // Post Type dropdown
            _buildAnimatedDropdown(
              label: 'Post Type',
              icon: Icons.category,
              value: selectedType.value,
              items: PostType.values,
              onChanged: isEditing.value
                  ? (value) {
                      if (value != null) {
                        selectedType.value = value;
                      }
                    }
                  : null,
              isEditing: isEditing.value,
            ),

            const SizedBox(height: 16),

            // Priority dropdown
            _buildAnimatedDropdown(
              label: 'Priority',
              icon: Icons.flag,
              value: selectedPriority.value,
              items: Priority.values,
              onChanged: isEditing.value
                  ? (value) {
                      if (value != null) {
                        selectedPriority.value = value;
                      }
                    }
                  : null,
              isEditing: isEditing.value,
            ),

            const SizedBox(height: 16),

            // Platform dropdown
            _buildAnimatedDropdown(
              label: 'Platform',
              icon: Icons.language,
              value: selectedPlatform.value,
              items: platforms,
              onChanged: isEditing.value
                  ? (value) {
                      if (value != null) {
                        selectedPlatform.value = value;
                      }
                    }
                  : null,
              isEditing: isEditing.value,
            ),

            const SizedBox(height: 24),

            // Action buttons
            Card(
              margin: const EdgeInsets.only(top: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                side: BorderSide(
                  color: AppTheme.getPostTypeColor(selectedType.value)
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Open in App button
                    _buildOpenButton(
                      label: 'OPEN IN APP',
                      icon: Icons.open_in_new,
                      isPrimary: true,
                      onPressed: () =>
                          _openInApp(context, post.link, post.title),
                    ),
                    const SizedBox(height: 12),
                    // Open in Browser button
                    _buildOpenButton(
                      label: 'OPEN IN BROWSER',
                      icon: Icons.language,
                      isPrimary: false,
                      onPressed: () => _openInBrowser(post.link),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom button for Open in App/Browser
  Widget _buildOpenButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: isPrimary ? AppTheme.primaryColor : Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            border: isPrimary
                ? null
                : Border.all(color: AppTheme.primaryColor, width: 1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppTheme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : AppTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Type chip
  Widget _buildTypeChip(BuildContext context, String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.getPostTypeColor(type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getPostTypeColor(type).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category,
            size: 16,
            color: AppTheme.getPostTypeColor(type),
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              color: AppTheme.getPostTypeColor(type),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Priority chip
  Widget _buildPriorityChip(BuildContext context, String priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.getPriorityColor(priority).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getPriorityColor(priority).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag,
            size: 16,
            color: AppTheme.getPriorityColor(priority),
          ),
          const SizedBox(width: 4),
          Text(
            priority,
            style: TextStyle(
              color: AppTheme.getPriorityColor(priority),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Animated form field
  Widget _buildAnimatedFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool readOnly,
    required bool isEditing,
    required FormFieldValidator<String> validator,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: isEditing
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: BorderSide(
              color: isEditing ? AppTheme.primaryColor : Colors.grey[300]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: BorderSide(
              color: isEditing ? AppTheme.primaryColor : Colors.grey[300]!,
              width: isEditing ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // Animated dropdown
  Widget _buildAnimatedDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    required bool isEditing,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: isEditing
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: BorderSide(
              color: isEditing ? AppTheme.primaryColor : Colors.grey[300]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: BorderSide(
              color: isEditing ? AppTheme.primaryColor : Colors.grey[300]!,
              width: isEditing ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
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

  Future<void> _openInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
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
                                    color: folderColor.withOpacity(0.2),
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
}
