import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../blocs/folder_bloc.dart';
import '../blocs/post_bloc.dart';
import '../constants/app_theme.dart';
import '../models/folder.dart';
import '../models/saved_post.dart';

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

    // Shadcn UI theme colors
    final backgroundColor = Colors.grey[50];
    const cardColor = Colors.white;
    final borderColor = Colors.grey[200]!;
    final textColor = Colors.grey[800]!;
    final mutedTextColor = Colors.grey[500]!;
    const primaryColor = AppTheme.primaryColor;
    final hoverColor = Colors.grey[100]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        foregroundColor: textColor,
        title: Text(
          'Add Link',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: borderColor,
            height: 1,
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // URL Field
            SlideTransition(
              position: slideAnimations[0],
              child: FadeTransition(
                opacity: animationController,
                child: _buildShadcnField(
                  label: 'URL',
                  controller: linkController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a URL';
                    }
                    return null;
                  },
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  borderColor: borderColor,
                  cardColor: cardColor,
                  hoverColor: hoverColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title Field
            SlideTransition(
              position: slideAnimations[1],
              child: FadeTransition(
                opacity: animationController,
                child: _buildShadcnField(
                  label: 'Title or Note',
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title or note';
                    }
                    return null;
                  },
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  borderColor: borderColor,
                  cardColor: cardColor,
                  hoverColor: hoverColor,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Type Selection
            SlideTransition(
              position: slideAnimations[2],
              child: FadeTransition(
                opacity: animationController,
                child: _buildShadcnDropdown(
                  label: 'Type',
                  value: selectedType.value,
                  options: PostType.values,
                  onChanged: (value) {
                    if (value != null) {
                      selectedType.value = value;
                    }
                  },
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  borderColor: borderColor,
                  cardColor: cardColor,
                  hoverColor: hoverColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Priority Selection
            SlideTransition(
              position: slideAnimations[3],
              child: FadeTransition(
                opacity: animationController,
                child: _buildShadcnDropdown(
                  label: 'Priority',
                  value: selectedPriority.value,
                  options: Priority.values,
                  onChanged: (value) {
                    if (value != null) {
                      selectedPriority.value = value;
                    }
                  },
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  borderColor: borderColor,
                  cardColor: cardColor,
                  hoverColor: hoverColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Platform Selection
            SlideTransition(
              position: slideAnimations[4],
              child: FadeTransition(
                opacity: animationController,
                child: _buildShadcnDropdown(
                  label: 'Platform',
                  value: selectedPlatform.value,
                  options: Platform.values,
                  onChanged: (value) {
                    if (value != null) {
                      selectedPlatform.value = value;
                    }
                  },
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  borderColor: borderColor,
                  cardColor: cardColor,
                  hoverColor: hoverColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Folder Selection
            SlideTransition(
              position: slideAnimations[5],
              child: FadeTransition(
                opacity: animationController,
                child: BlocBuilder<FolderBloc, FolderState>(
                  builder: (context, state) {
                    if (state is FolderLoaded) {
                      return _buildShadcnFolderSelector(
                        label: 'Folder',
                        folders: state.folders,
                        selectedFolder: selectedFolder.value,
                        onSelect: (folder) {
                          selectedFolder.value = folder;
                        },
                        textColor: textColor,
                        mutedTextColor: mutedTextColor,
                        borderColor: borderColor,
                        cardColor: cardColor,
                        hoverColor: hoverColor,
                      );
                    }
                    return _buildShadcnFolderSelector(
                      label: 'Folder',
                      folders: [],
                      selectedFolder: selectedFolder.value,
                      onSelect: (folder) {
                        selectedFolder.value = folder;
                      },
                      textColor: textColor,
                      mutedTextColor: mutedTextColor,
                      borderColor: borderColor,
                      cardColor: cardColor,
                      hoverColor: hoverColor,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Save Button
            SlideTransition(
              position: slideAnimations[5],
              child: FadeTransition(
                opacity: animationController,
                child: _buildShadcnButton(
                  context: context,
                  isLoading: isLoading,
                  onSave: () {
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
                                  AddPostToFolder(
                                      latestPost.id, selectedFolder.value!.id),
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
                  primaryColor: primaryColor,
                  textColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildShadcnField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required Color textColor,
    required Color mutedTextColor,
    required Color borderColor,
    required Color cardColor,
    required Color hoverColor,
  }) {
    const primaryColor = AppTheme.primaryColor;
    return HookBuilder(
      builder: (context) {
        final isFocused = useState(false);
        final isHovered = useState(false);
        final focusNode = useFocusNode();

        useEffect(() {
          void listener() {
            isFocused.value = focusNode.hasFocus;
          }

          focusNode.addListener(listener);
          return () => focusNode.removeListener(listener);
        }, [focusNode]);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            MouseRegion(
              onEnter: (_) => isHovered.value = true,
              onExit: (_) => isHovered.value = false,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isFocused.value
                      ? cardColor
                      : (isHovered.value ? hoverColor : cardColor),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isFocused.value ? primaryColor : borderColor,
                    width: 1,
                  ),
                  boxShadow: isFocused.value || isHovered.value
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  validator: validator,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: mutedTextColor),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShadcnDropdown<T>({
    required String label,
    required T value,
    required List<T> options,
    required Function(T?) onChanged,
    required Color textColor,
    required Color mutedTextColor,
    required Color borderColor,
    required Color cardColor,
    required Color hoverColor,
  }) {
    const primaryColor = AppTheme.primaryColor;
    return HookBuilder(
      builder: (context) {
        final isOpen = useState(false);
        final isHovered = useState(false);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            MouseRegion(
              onEnter: (_) => isHovered.value = true,
              onExit: (_) => isHovered.value = false,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isOpen.value
                      ? cardColor
                      : (isHovered.value ? hoverColor : cardColor),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isOpen.value ? primaryColor : borderColor,
                    width: 1,
                  ),
                  boxShadow: isOpen.value || isHovered.value
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButtonFormField<T>(
                      value: value,
                      items: options.map((option) {
                        return DropdownMenuItem<T>(
                          value: option,
                          child: Text(
                            option.toString(),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: onChanged,
                      onTap: () {
                        isOpen.value = true;
                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (isOpen.value) isOpen.value = false;
                        });
                      },
                      icon: Icon(
                        Icons.expand_more_rounded,
                        color: mutedTextColor,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        border: InputBorder.none,
                      ),
                      dropdownColor: cardColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShadcnFolderSelector({
    required String label,
    required List<Folder> folders,
    required Folder? selectedFolder,
    required Function(Folder?) onSelect,
    required Color textColor,
    required Color mutedTextColor,
    required Color borderColor,
    required Color cardColor,
    required Color hoverColor,
  }) {
    return HookBuilder(
      builder: (context) {
        final isHovered = useState(false);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            MouseRegion(
              onEnter: (_) => isHovered.value = true,
              onExit: (_) => isHovered.value = false,
              child: GestureDetector(
                onTap: () => _showShadcnFolderBottomSheet(
                  context: context,
                  folders: folders,
                  selectedFolder: selectedFolder,
                  onSelect: onSelect,
                  textColor: textColor,
                  mutedTextColor: mutedTextColor,
                  borderColor: borderColor,
                  cardColor: cardColor,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isHovered.value ? hoverColor : cardColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor),
                    boxShadow: isHovered.value
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (selectedFolder != null) ...[
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Color(int.parse(
                                    selectedFolder.color.substring(1),
                                    radix: 16) +
                                0xFF000000),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedFolder.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ),
                      ] else
                        Expanded(
                          child: Text(
                            'Select folder (optional)',
                            style: TextStyle(
                              fontSize: 14,
                              color: mutedTextColor,
                            ),
                          ),
                        ),
                      Icon(
                        Icons.expand_more_rounded,
                        color: mutedTextColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShadcnButton({
    required BuildContext context,
    required ValueNotifier<bool> isLoading,
    required VoidCallback onSave,
    required Color primaryColor,
    required Color textColor,
  }) {
    return HookBuilder(
      builder: (context) {
        final isHovered = useState(false);
        final isPressed = useState(false);

        return MouseRegion(
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          child: GestureDetector(
            onTapDown: (_) => isPressed.value = true,
            onTapUp: (_) => isPressed.value = false,
            onTapCancel: () => isPressed.value = false,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: isLoading.value ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: textColor,
                  elevation: isPressed.value ? 1 : (isHovered.value ? 3 : 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
                child: isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showShadcnFolderBottomSheet({
    required BuildContext context,
    required List<Folder> folders,
    required Folder? selectedFolder,
    required Function(Folder?) onSelect,
    required Color textColor,
    required Color mutedTextColor,
    required Color borderColor,
    required Color cardColor,
  }) {
    const primaryColor = AppTheme.primaryColor;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return HookBuilder(
          builder: (context) {
            final animationController = useAnimationController(
              duration: const Duration(milliseconds: 300),
            );

            final slideAnimation = useMemoized(
              () => Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animationController,
                  curve: Curves.easeOutCubic,
                ),
              ),
            );

            useEffect(() {
              animationController.forward();
              return null;
            }, []);

            return SlideTransition(
              position: slideAnimation,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            'Select Folder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              onSelect(null);
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Folder list
                    Expanded(
                      child: folders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_off_rounded,
                                    size: 48,
                                    color: mutedTextColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No folders available',
                                    style: TextStyle(
                                      color: mutedTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: folders.length,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemBuilder: (context, index) {
                                final folder = folders[index];
                                final isSelected =
                                    selectedFolder?.id == folder.id;
                                final folderColor = Color(
                                  int.parse(folder.color.substring(1),
                                          radix: 16) +
                                      0xFF000000,
                                );

                                return HookBuilder(
                                  builder: (context) {
                                    final isHovered = useState(false);

                                    return MouseRegion(
                                      onEnter: (_) => isHovered.value = true,
                                      onExit: (_) => isHovered.value = false,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected || isHovered.value
                                              ? Colors.grey[100]
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: ListTile(
                                          leading: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: folderColor,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Icon(
                                              Icons.folder_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                          title: Text(
                                            folder.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                            ),
                                          ),
                                          subtitle: folder.description !=
                                                      null &&
                                                  folder.description!.isNotEmpty
                                              ? Text(
                                                  folder.description!,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: mutedTextColor,
                                                  ),
                                                )
                                              : null,
                                          trailing: isSelected
                                              ? const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: primaryColor,
                                                  size: 20,
                                                )
                                              : null,
                                          dense: true,
                                          onTap: () {
                                            onSelect(folder);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),

                    // Footer
                    Container(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 16 + MediaQuery.of(context).padding.bottom,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border(
                          top: BorderSide(color: borderColor),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.black.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
