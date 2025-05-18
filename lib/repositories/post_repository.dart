import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/saved_post.dart';

class PostRepository {
  late Box<SavedPost> _postsBox;
  final _uuid = const Uuid();

  PostRepository() {
    _initBox();
  }

  // Initialize the box safely
  Future<void> _initBox() async {
    try {
      if (Hive.isBoxOpen('saved_posts')) {
        _postsBox = Hive.box<SavedPost>('saved_posts');
      } else {
        _postsBox = await Hive.openBox<SavedPost>('saved_posts');
      }
    } catch (e) {
      print('Error initializing posts box: $e');
      // Try to recover
      try {
        await Hive.deleteBoxFromDisk('saved_posts');
        _postsBox = await Hive.openBox<SavedPost>('saved_posts');
      } catch (e) {
        print('Failed to recover posts box: $e');
      }
    }
  }

  // Get all posts
  List<SavedPost> getAllPosts() {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('saved_posts')) {
        _initBox();
      }
      return _postsBox.values.toList();
    } catch (e) {
      print('Error getting all posts: $e');
      return [];
    }
  }

  // Add new post
  Future<String> addPost({
    required String link,
    required String title,
    required String type,
    required String priority,
    required String platform,
  }) async {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('saved_posts')) {
        await _initBox();
      }

      final id = _uuid.v4();
      final post = SavedPost(
        id: id,
        link: link,
        title: title,
        type: type,
        priority: priority,
        createdAt: DateTime.now(),
        platform: platform,
      );

      await _postsBox.put(id, post);
      return id;
    } catch (e) {
      print('Error adding post: $e');
      return '';
    }
  }

  // Update existing post
  Future<void> updatePost(SavedPost post) async {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('saved_posts')) {
        await _initBox();
      }
      await _postsBox.put(post.id, post);
    } catch (e) {
      print('Error updating post: $e');
    }
  }

  // Delete post
  Future<void> deletePost(String id) async {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('saved_posts')) {
        await _initBox();
      }
      await _postsBox.delete(id);
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  // Get post by ID
  SavedPost? getPostById(String id) {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('saved_posts')) {
        _initBox();
      }
      return _postsBox.get(id);
    } catch (e) {
      print('Error getting post by ID: $e');
      return null;
    }
  }

  // Filter posts by type
  List<SavedPost> filterPostsByType(String type) {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('saved_posts')) {
        _initBox();
      }
      return _postsBox.values.where((post) => post.type == type).toList();
    } catch (e) {
      print('Error filtering posts by type: $e');
      return [];
    }
  }

  // Filter posts by priority
  List<SavedPost> filterPostsByPriority(String priority) {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('saved_posts')) {
        _initBox();
      }
      return _postsBox.values
          .where((post) => post.priority == priority)
          .toList();
    } catch (e) {
      print('Error filtering posts by priority: $e');
      return [];
    }
  }

  // Filter posts by platform
  List<SavedPost> filterPostsByPlatform(String platform) {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('saved_posts')) {
        _initBox();
      }
      return _postsBox.values
          .where((post) => post.platform == platform)
          .toList();
    } catch (e) {
      print('Error filtering posts by platform: $e');
      return [];
    }
  }

  // Sort posts by date (newest first)
  List<SavedPost> getPostsSortedByDate() {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('saved_posts')) {
        _initBox();
      }
      final posts = _postsBox.values.toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    } catch (e) {
      print('Error sorting posts by date: $e');
      return [];
    }
  }
}
