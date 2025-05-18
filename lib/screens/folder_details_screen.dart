import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/folder_bloc.dart';
import '../models/folder.dart';
import '../models/saved_post.dart';
import '../repositories/folder_repository.dart';
import '../repositories/post_repository.dart';
import 'add_post_screen.dart';
import 'post_details_screen.dart';

class FolderDetailsScreen extends StatelessWidget {
  final Folder folder;

  const FolderDetailsScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    // Get the folder color
    final color =
        Color(int.parse(folder.color.substring(1), radix: 16) + 0xFF000000);

    // Get posts in this folder
    final folderRepository = context.read<FolderRepository>();
    final postsInFolder = folderRepository.getPostsInFolder(folder.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditFolderDialog(context),
            tooltip: 'Edit folder',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Folder header
          Container(
            padding: const EdgeInsets.all(16),
            color: color.withOpacity(0.1),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(Icons.folder, color: color, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (folder.description != null &&
                          folder.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            folder.description!,
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        '${postsInFolder.length} links',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Posts list
          Expanded(
            child: postsInFolder.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.link_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No links in this folder',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add links to "${folder.name}" folder',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: postsInFolder.length,
                    itemBuilder: (context, index) {
                      final post = postsInFolder[index];
                      return _buildPostCard(context, post);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'folder_details_fab',
        onPressed: () {
          // Navigate to add post screen with pre-selected folder
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostScreen(
                preSelectedFolder: folder,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, SavedPost post) {
    // Get icon based on platform
    IconData platformIcon;
    switch (post.platform) {
      case Platform.linkedin:
        platformIcon = Icons.work;
        break;
      case Platform.twitter:
        platformIcon = Icons.chat;
        break;
      case Platform.github:
        platformIcon = Icons.code;
        break;
      case Platform.youtube:
        platformIcon = Icons.video_library;
        break;
      default:
        platformIcon = Icons.link;
    }

    // Get color based on priority
    Color priorityColor;
    switch (post.priority) {
      case Priority.high:
        priorityColor = Colors.red;
        break;
      case Priority.medium:
        priorityColor = Colors.orange;
        break;
      case Priority.low:
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.blue;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Get the post from repository to ensure we have the latest data
          final postRepository = context.read<PostRepository>();
          final currentPost = postRepository.getPostById(post.id);

          if (currentPost != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailsScreen(post: currentPost),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(platformIcon, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'remove') {
                        _showRemoveConfirmation(context, post);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.folder_off),
                            SizedBox(width: 8),
                            Text('Remove from folder'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.link,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: priorityColor),
                    ),
                    child: Text(
                      post.priority,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      post.type,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(post.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showEditFolderDialog(BuildContext context) {
    final nameController = TextEditingController(text: folder.name);
    final descriptionController =
        TextEditingController(text: folder.description ?? '');
    String selectedColor = folder.color;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Folder'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                  hintText: 'Enter folder name',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter folder description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Folder Color',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: FolderColor.values.map((colorHex) {
                      final color = Color(
                          int.parse(colorHex.substring(1), radix: 16) +
                              0xFF000000);
                      final isSelected = selectedColor == colorHex;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedColor = colorHex;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final updatedFolder = folder.copyWith(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  color: selectedColor,
                );

                context.read<FolderBloc>().add(UpdateFolder(updatedFolder));
                Navigator.pop(context);

                // Pop back to folders screen after a short delay to allow update to complete
                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.pop(context);
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRemoveConfirmation(BuildContext context, SavedPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Folder'),
        content: Text(
          'Are you sure you want to remove "${post.title}" from this folder?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FolderBloc>().add(RemovePostFromFolder(post.id));
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
