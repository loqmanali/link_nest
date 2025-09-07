import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'saved_post.g.dart';

// Sentinel to differentiate between an omitted parameter and an explicit null
const _unset = Object();

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

  // New fields
  @HiveField(8)
  final List<String> tags;

  @HiveField(9)
  final String status; // unread | read | starred

  // Extended metadata
  @HiveField(10)
  final DateTime savedAt; // when saved into app

  @HiveField(11)
  final DateTime? lastOpenedAt; // last time opened/read

  @HiveField(12)
  final String? summary; // generated or manual

  @HiveField(13)
  final List<String> keywords; // generated or manual

  @HiveField(14)
  final String contentType; // e.g., Article, Video, Thread, etc.

  @HiveField(15)
  final List<String> highlights; // key bullets

  SavedPost({
    required this.id,
    required this.link,
    required this.title,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.platform = 'Other',
    this.folderId,
    List<String>? tagsParam,
    String? statusParam,
    DateTime? savedAt,
    this.lastOpenedAt,
    this.summary,
    List<String>? keywordsParam,
    String? contentType,
    List<String>? highlightsParam,
  })
      : savedAt = savedAt ?? DateTime.now(),
        contentType = contentType ?? type,
        tags = tagsParam ?? const [],
        status = statusParam ?? Status.unread,
        keywords = keywordsParam ?? const [],
        highlights = highlightsParam ?? const [];

  // Create a copy of the post with updated fields
  SavedPost copyWith({
    String? id,
    String? link,
    String? title,
    String? type,
    String? priority,
    DateTime? createdAt,
    String? platform,
    Object? folderId = _unset,
    List<String>? tags,
    String? status,
    DateTime? savedAt,
    DateTime? lastOpenedAt,
    String? summary,
    List<String>? keywords,
    String? contentType,
    List<String>? highlights,
  }) {
    return SavedPost(
      id: id ?? this.id,
      link: link ?? this.link,
      title: title ?? this.title,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      platform: platform ?? this.platform,
      folderId: identical(folderId, _unset) ? this.folderId : folderId as String?,
      tagsParam: tags ?? this.tags,
      statusParam: status ?? this.status,
      savedAt: savedAt ?? this.savedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      summary: summary ?? this.summary,
      keywordsParam: keywords ?? this.keywords,
      contentType: contentType ?? this.contentType,
      highlightsParam: highlights ?? this.highlights,
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
        tags,
        status,
        savedAt,
        lastOpenedAt,
        summary,
        keywords,
        contentType,
        highlights,
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

// Define constants for read status
class Status {
  static const String unread = 'unread';
  static const String read = 'read';
  static const String starred = 'starred';

  static List<String> values = [unread, read, starred];
}
