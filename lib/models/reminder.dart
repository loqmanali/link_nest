import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 3)
class Reminder with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String postId;

  @HiveField(2)
  final DateTime dueAt;

  @HiveField(3)
  final String? repeat; // e.g., none, daily, weekly, monthly

  const Reminder({
    required this.id,
    required this.postId,
    required this.dueAt,
    this.repeat,
  });

  Reminder copyWith({
    String? id,
    String? postId,
    DateTime? dueAt,
    String? repeat,
  }) => Reminder(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        dueAt: dueAt ?? this.dueAt,
        repeat: repeat ?? this.repeat,
      );

  @override
  List<Object?> get props => [id, postId, dueAt, repeat];
}
