import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import '../constants/app_theme.dart';
import '../extensions/string_extension.dart';

class ReminderDialog extends HookWidget {
  final String postId;
  final String postTitle;
  final Function(DateTime dueAt, String? repeat) onSave;

  const ReminderDialog({
    super.key,
    required this.postId,
    required this.postTitle,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDate = useState<DateTime?>(null);
    final selectedTime = useState<TimeOfDay?>(null);
    final selectedRepeat = useState<String?>('none');

    final repeatOptions = ['none', 'daily', 'weekly', 'monthly'];

    return AlertDialog(
      title: const Text('Set Reminder'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For: ${postTitle.length > 30 ? '${postTitle.substring(0, 30)}...' : postTitle}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedForeground,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              'Date',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.foregroundColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  selectedDate.value = date;
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing3,
                  vertical: AppTheme.spacing3,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: AppTheme.spacing2),
                    Text(
                      selectedDate.value != null
                          ? DateFormat('MMM d, yyyy').format(selectedDate.value!)
                          : 'Select date',
                      style: TextStyle(
                        color: selectedDate.value != null
                            ? AppTheme.foregroundColor
                            : AppTheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Text(
              'Time',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.foregroundColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  selectedTime.value = time;
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing3,
                  vertical: AppTheme.spacing3,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: AppTheme.spacing2),
                    Text(
                      selectedTime.value != null
                          ? selectedTime.value!.format(context)
                          : 'Select time',
                      style: TextStyle(
                        color: selectedTime.value != null
                            ? AppTheme.foregroundColor
                            : AppTheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Text(
              'Repeat',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.foregroundColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            DropdownButtonFormField<String>(
              value: selectedRepeat.value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing3,
                  vertical: AppTheme.spacing3,
                ),
              ),
              items: repeatOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option == 'none' ? 'No repeat' : option.capitalize()),
                );
              }).toList(),
              onChanged: (value) => selectedRepeat.value = value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: selectedDate.value != null && selectedTime.value != null
              ? () {
                  final dueAt = DateTime(
                    selectedDate.value!.year,
                    selectedDate.value!.month,
                    selectedDate.value!.day,
                    selectedTime.value!.hour,
                    selectedTime.value!.minute,
                  );
                  final repeat = selectedRepeat.value == 'none' ? null : selectedRepeat.value;
                  onSave(dueAt, repeat);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Set Reminder'),
        ),
      ],
    );
  }
}
