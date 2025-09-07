import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../blocs/folder_bloc.dart';
import '../blocs/post_bloc.dart';
import '../blocs/tag_bloc.dart';
import '../constants/app_theme.dart';
import '../models/folder.dart';
import '../models/saved_post.dart';
import '../widgets/shadcn_select.dart';
import '../widgets/ui/button.dart';
import '../widgets/ui/card.dart';
import '../widgets/ui/input.dart';

class AddPostScreen extends HookWidget {
  final String? initialUrl;
  final Folder? preSelectedFolder;

  const AddPostScreen({
    super.key,
    this.initialUrl,
    this.preSelectedFolder,
  });

  @override
  Widget build(BuildContext context) {
    // Form controllers
    final linkController = useTextEditingController(text: initialUrl ?? '');
    final titleController = useTextEditingController();

    // State for dropdowns
    final selectedType = useState(PostType.article);
    final selectedPriority = useState(Priority.medium);
    final selectedPlatform = useState(Platform.linkedin);
    final selectedFolder = useState<Folder?>(preSelectedFolder);
    final selectedTags = useState<List<String>>([]);

    // Form key for validation
    final formKey = GlobalKey<FormState>();

    // Loading state
    final isLoading = useState(false);

    // Slide animation for fields
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    final slideAnimations = List.generate(
      6, // Number of animated elements
      (index) => Tween(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(
            index * 0.1, // Staggered start times
            0.7 + (index * 0.05),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    // Start animations when screen loads
    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    // Load folders
    useEffect(() {
      context.read<FolderBloc>().add(LoadFolders());
      return null;
    }, []);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.cardColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Add New Post',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.foregroundColor,
              ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: AppTheme.mutedForeground,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // URL Field
              SlideTransition(
                position: slideAnimations[0],
                child: FadeTransition(
                  opacity: animationController,
                  child: ShadcnInput(
                    label: 'URL',
                    placeholder: 'Enter post URL...',
                    controller: linkController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a URL';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacing6),

              // Title Field
              SlideTransition(
                position: slideAnimations[1],
                child: FadeTransition(
                  opacity: animationController,
                  child: ShadcnInput(
                    label: 'Title or Note',
                    placeholder: 'Enter a descriptive title...',
                    controller: titleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title or note';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacing8),

              // Selection Cards
              ShadcnCard(
                padding: const EdgeInsets.all(AppTheme.spacing5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Post Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.foregroundColor,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),

                    // Type Selection
                    SlideTransition(
                      position: slideAnimations[2],
                      child: FadeTransition(
                        opacity: animationController,
                        child: _buildModernDropdown(
                          context: context,
                          label: 'Type',
                          value: selectedType.value.toString(),
                          options:
                              PostType.values.map((e) => e.toString()).toList(),
                          onChanged: (value) {
                            final type = PostType.values.firstWhere(
                              (e) => e.toString() == value,
                            );
                            selectedType.value = type;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing4),

                    // Priority Selection
                    SlideTransition(
                      position: slideAnimations[3],
                      child: FadeTransition(
                        opacity: animationController,
                        child: _buildModernDropdown(
                          context: context,
                          label: 'Priority',
                          value: selectedPriority.value.toString(),
                          options:
                              Priority.values.map((e) => e.toString()).toList(),
                          onChanged: (value) {
                            final priority = Priority.values.firstWhere(
                              (e) => e.toString() == value,
                            );
                            selectedPriority.value = priority;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing4),

                    // Platform Selection
                    SlideTransition(
                      position: slideAnimations[4],
                      child: FadeTransition(
                        opacity: animationController,
                        child: _buildModernDropdown(
                          context: context,
                          label: 'Platform',
                          value: selectedPlatform.value.toString(),
                          options:
                              Platform.values.map((e) => e.toString()).toList(),
                          onChanged: (value) {
                            final platform = Platform.values.firstWhere(
                              (e) => e.toString() == value,
                            );
                            selectedPlatform.value = platform;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacing6),

              // Tags Selection
              SlideTransition(
                position: slideAnimations[5],
                child: FadeTransition(
                  opacity: animationController,
                  child: BlocBuilder<TagBloc, TagState>(
                    builder: (context, state) {
                      if (state is TagLoaded) {
                        return _buildTagsSelector(
                          context: context,
                          availableTags: state.tags.map((t) => t.name).toList(),
                          selectedTags: selectedTags.value,
                          onTagsChanged: (tags) {
                            selectedTags.value = tags;
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacing6),

              // Folder Selection
              SlideTransition(
                position: slideAnimations[5],
                child: FadeTransition(
                  opacity: animationController,
                  child: BlocBuilder<FolderBloc, FolderState>(
                    builder: (context, state) {
                      if (state is FolderLoaded) {
                        return _buildFolderSelector(
                          context: context,
                          folders: state.folders,
                          selectedFolder: selectedFolder.value,
                          onSelect: (folder) {
                            selectedFolder.value = folder;
                          },
                        );
                      }
                      return _buildFolderSelector(
                        context: context,
                        folders: [],
                        selectedFolder: selectedFolder.value,
                        onSelect: (folder) {
                          selectedFolder.value = folder;
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacing10),

              // Save Button
              SlideTransition(
                position: slideAnimations[5],
                child: FadeTransition(
                  opacity: animationController,
                  child: ShadcnButton(
                    text: 'Save Post',
                    isLoading: isLoading.value,
                    isFullWidth: true,
                    size: ButtonSize.lg,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        isLoading.value = true;

                        // Add post
                        context.read<PostBloc>().add(
                              AddPost(
                                link: linkController.text.trim(),
                                title: titleController.text.trim(),
                                type: selectedType.value,
                                priority: selectedPriority.value,
                                platform: selectedPlatform.value,
                                tags: selectedTags.value,
                              ),
                            );

                        // Add post to folder if selected
                        if (selectedFolder.value != null) {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            final posts = context
                                .read<PostBloc>()
                                .postRepository
                                .getAllPosts();
                            if (posts.isNotEmpty) {
                              final latestPost = posts.reduce((a, b) =>
                                  a.createdAt.isAfter(b.createdAt) ? a : b);

                              context.read<FolderBloc>().add(
                                    AddPostToFolder(latestPost.id,
                                        selectedFolder.value!.id),
                                  );
                            }
                          });
                        }

                        // Navigate back
                        Future.delayed(const Duration(milliseconds: 800), () {
                          Navigator.pop(context);
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacing10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDropdown({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.foregroundColor,
              ),
        ),
        const SizedBox(height: AppTheme.spacing2),
        ShadcnSelect<String>.fromOptions(
          options: options
              .map((option) => SelectOption(
                    value: option,
                    label: option.split('.').last,
                  ))
              .toList(),
          value: value,
          placeholder: 'Select $label',
          onChanged: onChanged,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildFolderSelector({
    required BuildContext context,
    required List<Folder> folders,
    required Folder? selectedFolder,
    required void Function(Folder?) onSelect,
  }) {
    return ShadcnCard(
      padding: const EdgeInsets.all(AppTheme.spacing5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Folder',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.foregroundColor,
                ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          ShadcnSelect<Folder?>.fromOptions(
            options: [
              const SelectOption<Folder?>(
                value: null,
                label: 'No Folder',
              ),
              ...folders.map((folder) => SelectOption<Folder?>(
                    value: folder,
                    label: folder.name,
                  )),
            ],
            value: selectedFolder,
            placeholder: 'Select a folder',
            onChanged: onSelect,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSelector({
    required BuildContext context,
    required List<String> availableTags,
    required List<String> selectedTags,
    required Function(List<String>) onTagsChanged,
  }) {
    return ShadcnCard(
      child: Column(
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
              TextButton.icon(
                onPressed: () => _showTagSelectionDialog(
                  context,
                  availableTags,
                  selectedTags,
                  onTagsChanged,
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Tags'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedTags.isEmpty)
            const Text(
              'No tags selected',
              style: TextStyle(
                color: AppTheme.mutedForeground,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: selectedTags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.mutedColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.tag,
                                size: 12, color: AppTheme.mutedForeground),
                            const SizedBox(width: 4),
                            Text(
                              tag,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                final updatedTags =
                                    List<String>.from(selectedTags);
                                updatedTags.remove(tag);
                                onTagsChanged(updatedTags);
                              },
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: AppTheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  void _showTagSelectionDialog(
    BuildContext context,
    List<String> availableTags,
    List<String> selectedTags,
    Function(List<String>) onTagsChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Tags'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableTags.length,
            itemBuilder: (context, index) {
              final tag = availableTags[index];
              final isSelected = selectedTags.contains(tag);

              return CheckboxListTile(
                title: Text(tag),
                value: isSelected,
                onChanged: (bool? value) {
                  final updatedTags = List<String>.from(selectedTags);
                  if (value == true) {
                    updatedTags.add(tag);
                  } else {
                    updatedTags.remove(tag);
                  }
                  onTagsChanged(updatedTags);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
