import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'attachment.g.dart';

@HiveType(typeId: 5)
class Attachment with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String postId;

  @HiveField(2)
  final String type; // pdf | img | html

  @HiveField(3)
  final String localPath; // file path on device

  const Attachment({
    required this.id,
    required this.postId,
    required this.type,
    required this.localPath,
  });

  Attachment copyWith({
    String? id,
    String? postId,
    String? type,
    String? localPath,
  }) => Attachment(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        type: type ?? this.type,
        localPath: localPath ?? this.localPath,
      );

  @override
  List<Object?> get props => [id, postId, type, localPath];
}
