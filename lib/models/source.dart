import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'source.g.dart';

@HiveType(typeId: 6)
class Source with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String platform; // LinkedIn, Twitter, etc.

  @HiveField(2)
  final String? author;

  @HiveField(3)
  final String link;

  const Source({
    required this.id,
    required this.platform,
    required this.link,
    this.author,
  });

  Source copyWith({
    String? id,
    String? platform,
    String? author,
    String? link,
  }) => Source(
        id: id ?? this.id,
        platform: platform ?? this.platform,
        author: author ?? this.author,
        link: link ?? this.link,
      );

  @override
  List<Object?> get props => [id, platform, author, link];
}
