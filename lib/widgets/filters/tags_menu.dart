import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/tag_bloc.dart';
import '../../constants/app_theme.dart';
import '../../models/tag.dart';
import '../../screens/tags_screen.dart';
import 'filter_pill.dart';

class TagsMenu extends StatelessWidget {
  final List<String> selectedTags;
  final String currentFilter;
  final ValueChanged<List<String>> onApply;

  const TagsMenu({
    super.key,
    required this.selectedTags,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      onTap: () async {
        context.read<TagBloc>().add(LoadTags());
        final state = context.read<TagBloc>().state;
        List<String> available = [];
        if (state is TagLoaded) {
          available = state.tags.map((t) => t.name).toList();
        }

        final current = selectedTags.toSet();
        final result = await showModalBottomSheet<List<String>>(
          context: context,
          backgroundColor: AppTheme.cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLg),
            ),
          ),
          builder: (ctx) {
            final temp = current.toSet();
            return StatefulBuilder(builder: (ctx, setState) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Tags',
                              style: Theme.of(ctx).textTheme.titleMedium),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                    builder: (_) => const TagsScreen()),
                              );
                            },
                            icon: const Icon(Icons.settings, size: 16),
                            label: const Text('Manage'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      if (available.isEmpty)
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppTheme.spacing2),
                          child: Text('No tags yet. Tap Manage to add.'),
                        )
                      else
                        ...available.map((name) => CheckboxListTile(
                              title: Text(name),
                              value: temp.contains(name),
                              onChanged: (v) => setState(() {
                                if (v == true) {
                                  temp.add(name);
                                } else {
                                  temp.remove(name);
                                }
                              }),
                            )),
                      const SizedBox(height: AppTheme.spacing2),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, <String>[]),
                            child: const Text('Clear'),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, temp.toList()),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );

        if (result != null) {
          onApply(result);
        }
      },
      child: FilterPill(
        label: 'Tags',
        isActive: selectedTags.isNotEmpty || currentFilter.startsWith('tag:'),
        activeColor: _getTagActiveColor(context, selectedTags),
        hasChevron: true,
      ),
    );
  }
}

Color _getTagActiveColor(BuildContext context, List<String> tags) {
  if (tags.length == 1) {
    final state = context.read<TagBloc>().state;
    if (state is TagLoaded) {
      final tag = state.tags.firstWhere(
        (t) => t.name == tags.first,
        orElse: () => Tag(id: '', name: tags.first, color: null),
      );
      if (tag.color != null) {
        return Color(int.parse(tag.color!.replaceFirst('#', '0xff')));
      }
    }
  }
  return AppTheme.primaryColor;
}
