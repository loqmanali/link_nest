import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'tag.g.dart';

@HiveType(typeId: 2)
class Tag with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? color; // hex string e.g., #AABBCC

  const Tag({required this.id, required this.name, this.color});

  Tag copyWith({String? id, String? name, String? color}) => Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
      );

  @override
  List<Object?> get props => [id, name, color];
}
