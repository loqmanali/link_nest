import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/folder_bloc.dart';
import '../blocs/post_bloc.dart';
import '../blocs/reminder_bloc.dart';
import '../constants/app_theme.dart';
import '../models/folder.dart';
import '../models/reminder.dart';
import '../models/saved_post.dart';
import '../repositories/folder_repository.dart';
import '../utils/embed_store.dart';
import '../utils/linkedin_utils.dart';
import '../widgets/generic_embed.dart';
import '../widgets/highlights_section.dart';
import '../widgets/tags_section.dart';
import '../widgets/reminder_dialog.dart';
import 'post_edit_screen.dart';

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

    // Note: PostDetails is read-only viewer now; editing happens in PostEditScreen

    // Load saved Embed URL (if any); otherwise derive from post.link
    final embedUrlState = useState<String?>(null);
    useEffect(() {
      Future.microtask(() async {
        final saved = await EmbedStore.getEmbedUrl(post.id);
        if (saved != null && saved.isNotEmpty) {
          embedUrlState.value = saved;
        } else {
          // Derive an embed URL from the post link for inline rendering
          final derived = LinkedInUtils.toEmbedUrl(post.link) ??
              _ensureUrlScheme(post.link);
          embedUrlState.value = derived;
        }
      });
      return null;
    }, const []);

    // Note: repositories are accessed within the specific action handlers as needed

    // Read-only flag for details screen (no editing inside details)
    final isEditing = useState(false);

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
                case 'edit_embed':
                  _showEditEmbedDialog(context, embedUrlState);
                  break;
                case 'edit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostEditScreen(post: post),
                    ),
                  );
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
              // const PopupMenuItem<String>(
              //   value: 'edit_embed',
              //   child: Row(
              //     children: [
              //       Icon(
              //         Icons.link,
              //         color: AppTheme.foregroundColor,
              //         size: 20,
              //       ),
              //       SizedBox(width: 12),
              //       Text(
              //         'Edit embed URL',
              //         style: TextStyle(
              //           color: AppTheme.foregroundColor,
              //           fontSize: 14,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      color: AppTheme.foregroundColor,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Edit post',
                      style: TextStyle(
                        color: AppTheme.foregroundColor,
                        fontSize: 14,
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
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        children: [
          // Embed preview only
          if (embedUrlState.value != null && embedUrlState.value!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: GenericEmbed(
                    embedUrl: embedUrlState.value!,
                    height: 900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (kIsWeb &&
                        !embedUrlState.value!.contains('linkedin.com'))
                      const Icon(Icons.info_outline,
                          size: 16, color: AppTheme.mutedForeground),
                    if (kIsWeb &&
                        !embedUrlState.value!.contains('linkedin.com'))
                      const SizedBox(width: 6),
                    if (kIsWeb &&
                        !embedUrlState.value!.contains('linkedin.com'))
                      Expanded(
                        child: Text(
                          'Some providers may block embedding via CSP. If the preview does not load, open in browser.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.mutedForeground),
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => _openInBrowser(
                        embedUrlState.value!,
                      ),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Open in browser'),
                    ),
                  ],
                ),
              ],
            ),

          if (embedUrlState.value != null && embedUrlState.value!.isNotEmpty)
            const SizedBox(height: AppTheme.spacing4),

          // Read-only Tags under the embed
          TagsSection(isEditing: isEditing, post: post),

          const Divider(),
          // Read-only Highlights under the embed
          HighlightsSection(isEditing: isEditing, post: post),

          const SizedBox(height: AppTheme.spacing6),

          // Subtle tertiary Edit button under sections
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostEditScreen(post: post),
                  ),
                );
              },
              icon: const Icon(Icons.edit_rounded, color: AppTheme.mutedForeground),
              label: const Text(
                'Edit post',
                style: TextStyle(color: AppTheme.mutedForeground),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacing10),
        ],
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

  void _showEditEmbedDialog(
    BuildContext context,
    ValueNotifier<String?> embedUrlState,
  ) {
    final controller = TextEditingController(text: embedUrlState.value ?? '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Embed URL'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'https://www.example.com/embed/...',
              labelText: 'Embed URL',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await EmbedStore.remove(post.id);
                embedUrlState.value = null;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Embed URL removed')),
                );
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final v = controller.text.trim();
                if (v.isNotEmpty) {
                  String toSave = v;
                  // Auto-convert LinkedIn URLs to embed URLs when possible
                  final li = LinkedInUtils.toEmbedUrl(v);
                  if (li != null) {
                    toSave = li;
                  }
                  // Ensure URL scheme
                  if (!toSave.startsWith('http://') &&
                      !toSave.startsWith('https://')) {
                    toSave = 'https://$toSave';
                  }

                  await EmbedStore.setEmbedUrl(post.id, toSave);
                  embedUrlState.value = toSave;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Embed URL saved')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
