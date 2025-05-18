import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/saved_post.dart';

class PostRepository {
  final Box<SavedPost> _postsBox = Hive.box<SavedPost>('saved_posts');
  final _uuid = const Uuid();

  // Get all posts
  List<SavedPost> getAllPosts() {
    return _postsBox.values.toList();
  }

  // Add new post
  Future<String> addPost({
    required String link,
    required String title,
    required String type,
    required String priority,
    required String platform,
  }) async {
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
  }

  // Update existing post
  Future<void> updatePost(SavedPost post) async {
    await _postsBox.put(post.id, post);
  }

  // Delete post
  Future<void> deletePost(String id) async {
    await _postsBox.delete(id);
  }

  // Get post by ID
  SavedPost? getPostById(String id) {
    return _postsBox.get(id);
  }

  // Filter posts by type
  List<SavedPost> filterPostsByType(String type) {
    return _postsBox.values.where((post) => post.type == type).toList();
  }

  // Filter posts by priority
  List<SavedPost> filterPostsByPriority(String priority) {
    return _postsBox.values.where((post) => post.priority == priority).toList();
  }

  // Filter posts by platform
  List<SavedPost> filterPostsByPlatform(String platform) {
    return _postsBox.values.where((post) => post.platform == platform).toList();
  }

  // Sort posts by date (newest first)
  List<SavedPost> getPostsSortedByDate() {
    final posts = _postsBox.values.toList();
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }
}
