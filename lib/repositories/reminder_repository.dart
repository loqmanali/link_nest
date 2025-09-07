import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/reminder.dart';

class ReminderRepository {
  late Box<Reminder> _reminderBox;
  final _uuid = const Uuid();

  ReminderRepository() {
    _initBox();
  }

  Future<void> _initBox() async {
    if (Hive.isBoxOpen('reminders')) {
      _reminderBox = Hive.box<Reminder>('reminders');
    } else {
      _reminderBox = await Hive.openBox<Reminder>('reminders');
    }
  }

  List<Reminder> getAll() {
    if (!Hive.isBoxOpen('reminders')) {
      _initBox();
    }
    return _reminderBox.values.toList();
  }

  Future<String> add({required String postId, required DateTime dueAt, String? repeat}) async {
    if (!Hive.isBoxOpen('reminders')) {
      await _initBox();
    }
    final id = _uuid.v4();
    final item = Reminder(id: id, postId: postId, dueAt: dueAt, repeat: repeat);
    await _reminderBox.put(id, item);
    return id;
  }

  Future<void> delete(String id) async {
    if (!Hive.isBoxOpen('reminders')) {
      await _initBox();
    }
    await _reminderBox.delete(id);
  }
}
