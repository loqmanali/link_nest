import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'annotation.g.dart';

@HiveType(typeId: 4)
class Annotation with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String postId;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final Map<String, dynamic>? ranges; // optional selection ranges

  const Annotation({
    required this.id,
    required this.postId,
    required this.text,
    required this.createdAt,
    this.ranges,
  });

  Annotation copyWith({
    String? id,
    String? postId,
    String? text,
    DateTime? createdAt,
    Map<String, dynamic>? ranges,
  }) => Annotation(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        text: text ?? this.text,
        createdAt: createdAt ?? this.createdAt,
        ranges: ranges ?? this.ranges,
      );

  @override
  List<Object?> get props => [id, postId, text, createdAt, ranges];
}
