import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'saved_post.g.dart';

@HiveType(typeId: 0)
class SavedPost with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String link;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final String priority;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String platform;

  @HiveField(7)
  final String? folderId;

  SavedPost({
    required this.id,
    required this.link,
    required this.title,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.platform = 'Other',
    this.folderId,
  });

  // Create a copy of the post with updated fields
  SavedPost copyWith({
    String? id,
    String? link,
    String? title,
    String? type,
    String? priority,
    DateTime? createdAt,
    String? platform,
    String? folderId,
  }) {
    return SavedPost(
      id: id ?? this.id,
      link: link ?? this.link,
      title: title ?? this.title,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      platform: platform ?? this.platform,
      folderId: folderId ?? this.folderId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        link,
        title,
        type,
        priority,
        createdAt,
        platform,
        folderId,
      ];
}

// Define constants for post types
class PostType {
  static const String job = 'Job';
  static const String article = 'Article';
  static const String tip = 'Tip';
  static const String opportunity = 'Opportunity';
  static const String other = 'Other';

  static List<String> values = [job, article, tip, opportunity, other];
}

// Define constants for priority levels
class Priority {
  static const String high = 'High';
  static const String medium = 'Medium';
  static const String low = 'Low';

  static List<String> values = [high, medium, low];
}

// Define constants for platforms
class Platform {
  static const String linkedin = 'LinkedIn';
  static const String twitter = 'Twitter';
  static const String facebook = 'Facebook';
  static const String github = 'GitHub';
  static const String medium = 'Medium';
  static const String youtube = 'YouTube';
  static const String whatsapp = 'WhatsApp';
  static const String telegram = 'Telegram';
  static const String other = 'Other';

  static List<String> values = [
    linkedin,
    twitter,
    facebook,
    github,
    medium,
    youtube,
    whatsapp,
    telegram,
    other,
  ];
}
