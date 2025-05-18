import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'folder.g.dart';

@HiveType(typeId: 1)
class Folder with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String color;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int postCount;

  Folder({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.createdAt,
    this.postCount = 0,
  });

  // Create a copy of the folder with updated fields
  Folder copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    DateTime? createdAt,
    int? postCount,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      postCount: postCount ?? this.postCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        color,
        createdAt,
        postCount,
      ];
}

// Define constants for folder colors
class FolderColor {
  static const String blue = '#2196F3';
  static const String green = '#4CAF50';
  static const String red = '#F44336';
  static const String purple = '#9C27B0';
  static const String orange = '#FF9800';
  static const String teal = '#009688';
  static const String pink = '#E91E63';
  static const String indigo = '#3F51B5';

  static List<String> values = [
    blue,
    green,
    red,
    purple,
    orange,
    teal,
    pink,
    indigo,
  ];
}
