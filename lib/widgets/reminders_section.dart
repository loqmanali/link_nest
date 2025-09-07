import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/reminder_bloc.dart';
import '../constants/app_theme.dart';
import '../models/reminder.dart';
import '../models/saved_post.dart';
import 'reminder_dialog.dart';

class RemindersSection extends StatelessWidget {
  final SavedPost post;
  const RemindersSection({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        if (state is ReminderLoaded) {
          final postReminders = state.reminders
              .where((reminder) => reminder.postId == post.id)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications,
                      size: 16, color: AppTheme.mutedForeground),
                  const SizedBox(width: 8),
                  const Text(
                    'Reminders',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.foregroundColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => ReminderDialog(
                        postId: post.id,
                        postTitle: post.title,
                        onSave: (dueAt, repeat) {
                          final reminder = Reminder(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            postId: post.id,
                            dueAt: dueAt,
                            repeat: repeat,
                          );
                          context
                              .read<ReminderBloc>()
                              .add(AddReminder(reminder));
                        },
                      ),
                    ),
                    tooltip: 'Add reminder',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: postReminders.isEmpty
                    ? const Text(
                        'No reminders set',
                        style: TextStyle(
                          color: AppTheme.mutedForeground,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: postReminders.map((reminder) {
                          final isOverdue =
                              reminder.dueAt.isBefore(DateTime.now());
                          return Container(
                            margin: EdgeInsets.only(
                              bottom: reminder != postReminders.last
                                  ? AppTheme.spacing2
                                  : 0,
                            ),
                            padding: const EdgeInsets.all(AppTheme.spacing2),
                            decoration: BoxDecoration(
                              color: isOverdue
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.blue.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                              border: Border.all(
                                color: isOverdue
                                    ? Colors.red.withValues(alpha: 0.3)
                                    : Colors.blue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isOverdue ? Icons.warning : Icons.schedule,
                                  size: 14,
                                  color: isOverdue
                                      ? Colors.red[700]
                                      : Colors.blue[700],
                                ),
                                const SizedBox(width: AppTheme.spacing2),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat("MMM d, yyyy 'at' h:mm a")
                                            .format(reminder.dueAt),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isOverdue
                                              ? Colors.red[700]
                                              : Colors.blue[700],
                                        ),
                                      ),
                                      if (reminder.repeat != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Repeats ${reminder.repeat}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _showDeleteReminderDialog(
                                      context, reminder),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppTheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showDeleteReminderDialog(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ReminderBloc>().add(DeleteReminder(reminder.id));
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.destructiveColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
