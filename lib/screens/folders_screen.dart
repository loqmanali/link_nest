import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../blocs/folder_bloc.dart';
import '../constants/app_theme.dart';
import '../models/folder.dart';
import 'folder_details_screen.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.cardColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Folders',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.foregroundColor,
                letterSpacing: -0.025,
              ),
        ),
        actions: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              onTap: () => context.read<FolderBloc>().add(SortFoldersByName()),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacing2),
                child: const Icon(
                  Iconsax.sort,
                  color: AppTheme.mutedForeground,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing1),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              onTap: () => context.read<FolderBloc>().add(SortFoldersByDate()),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacing2),
                child: const Icon(
                  Iconsax.clock,
                  color: AppTheme.mutedForeground,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing2),
        ],
      ),
      body: BlocBuilder<FolderBloc, FolderState>(
        builder: (context, state) {
          if (state is FolderLoading) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          } else if (state is FolderLoaded) {
            final folders = state.folders;

            if (folders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing4),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Iconsax.folder,
                            size: 48,
                            color: AppTheme.mutedForeground,
                          ),
                          const SizedBox(height: AppTheme.spacing3),
                          Text(
                            'No folders yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppTheme.foregroundColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacing2),
                          Text(
                            'Create folders to organize your links',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.mutedForeground,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          ElevatedButton.icon(
                            onPressed: () => _showAddFolderDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing4,
                                vertical: AppTheme.spacing3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMd),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Iconsax.add),
                            label: const Text('Create Folder'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;
                if (constraints.maxWidth >= 1200) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth >= 800) {
                  crossAxisCount = 3;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppTheme.spacing3,
                    mainAxisSpacing: AppTheme.spacing3,
                    // Give items a bit more height to avoid vertical overflow
                    childAspectRatio: 1.0,
                  ),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    final color = Color(
                        int.parse(folder.color.substring(1), radix: 16) +
                            0xFF000000);

                    return Material(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FolderDetailsScreen(folder: folder),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderColor),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLg),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(AppTheme.spacing4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMd),
                                      border: Border.all(
                                          color: color.withValues(alpha: 0.4)),
                                    ),
                                    child: Icon(Iconsax.folder,
                                        color: color, size: 24),
                                  ),
                                  const Spacer(),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditFolderDialog(context, folder);
                                      } else if (value == 'delete') {
                                        _showDeleteConfirmation(
                                            context, folder);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Iconsax.edit_2),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Iconsax.trash,
                                                color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacing3),
                              Text(
                                folder.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppTheme.foregroundColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (folder.description != null &&
                                  folder.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: AppTheme.spacing1),
                                  child: Text(
                                    folder.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.mutedForeground,
                                        ),
                                  ),
                                ),
                              // Use a small fixed spacing instead of Spacer to avoid overflow
                              const SizedBox(height: AppTheme.spacing2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacing2,
                                      vertical: AppTheme.spacing1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusSm),
                                      border: Border.all(
                                          color: AppTheme.borderColor),
                                    ),
                                    child: Text(
                                      '${folder.postCount} links',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: AppTheme.secondaryForeground,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is FolderError) {
            return Center(
              child: Text(
                state.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'folders_fab',
        onPressed: () => _showAddFolderDialog(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.accentForeground,
        child: const Icon(Iconsax.add),
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedColor = FolderColor.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Folder'),
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
                context.read<FolderBloc>().add(
                      AddFolder(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                        color: selectedColor,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditFolderDialog(BuildContext context, Folder folder) {
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
                context.read<FolderBloc>().add(
                      UpdateFolder(
                        folder.copyWith(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim().isEmpty
                              ? null
                              : descriptionController.text.trim(),
                          color: selectedColor,
                        ),
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Folder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
          'Are you sure you want to delete "${folder.name}"? '
          'All links will be removed from this folder (but not deleted).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FolderBloc>().add(DeleteFolder(folder.id));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
