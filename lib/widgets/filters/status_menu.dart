import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import 'filter_pill.dart';

class StatusMenu extends StatelessWidget {
  final List<String> selectedStatuses;
  final ValueChanged<List<String>> onApply;

  const StatusMenu({
    super.key,
    required this.selectedStatuses,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      onTap: () async {
        final current = List<String>.from(selectedStatuses);
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
            List<String> options = const ['unread', 'read', 'starred'];
            return StatefulBuilder(builder: (ctx, setState) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status',
                          style: Theme.of(ctx).textTheme.titleMedium),
                      const SizedBox(height: AppTheme.spacing2),
                      ...options.map((s) => CheckboxListTile(
                            title: Text(s),
                            value: temp.contains(s),
                            onChanged: (v) => setState(() {
                              if (v == true) {
                                temp.add(s);
                              } else {
                                temp.remove(s);
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
                      )
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
        label: 'Status',
        isActive: selectedStatuses.isNotEmpty,
        activeColor: AppTheme.primaryColor,
        hasChevron: true,
      ),
    );
  }
}
