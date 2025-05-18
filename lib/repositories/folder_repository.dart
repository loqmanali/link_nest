import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/folder.dart';
import '../models/saved_post.dart';

class FolderRepository {
  final Box<Folder> _foldersBox = Hive.box<Folder>('folders');
  final Box<SavedPost> _postsBox = Hive.box<SavedPost>('saved_posts');
  final _uuid = const Uuid();

  // Get all folders
  List<Folder> getAllFolders() {
    return _foldersBox.values.toList();
  }

  // Add new folder
  Future<String> addFolder({
    required String name,
    String? description,
    required String color,
  }) async {
    final id = _uuid.v4();
    final folder = Folder(
      id: id,
      name: name,
      description: description,
      color: color,
      createdAt: DateTime.now(),
    );

    await _foldersBox.put(id, folder);
    return id;
  }

  // Update existing folder
  Future<void> updateFolder(Folder folder) async {
    await _foldersBox.put(folder.id, folder);
  }

  // Delete folder
  Future<void> deleteFolder(String id) async {
    // First, remove folder reference from all posts in this folder
    final postsInFolder =
        _postsBox.values.where((post) => post.folderId == id).toList();
    for (var post in postsInFolder) {
      final updatedPost = post.copyWith(folderId: null);
      await _postsBox.put(post.id, updatedPost);
    }

    // Then delete the folder
    await _foldersBox.delete(id);
  }

  // Get folder by ID
  Folder? getFolderById(String id) {
    return _foldersBox.get(id);
  }

  // Get posts in folder
  List<SavedPost> getPostsInFolder(String folderId) {
    return _postsBox.values.where((post) => post.folderId == folderId).toList();
  }

  // Add post to folder
  Future<void> addPostToFolder(String postId, String folderId) async {
    final post = _postsBox.get(postId);
    if (post != null) {
      final updatedPost = post.copyWith(folderId: folderId);
      await _postsBox.put(postId, updatedPost);

      // Update folder post count
      final folder = _foldersBox.get(folderId);
      if (folder != null) {
        final updatedFolder = folder.copyWith(postCount: folder.postCount + 1);
        await _foldersBox.put(folderId, updatedFolder);
      }
    }
  }

  // Remove post from folder
  Future<void> removePostFromFolder(String postId) async {
    final post = _postsBox.get(postId);
    if (post != null && post.folderId != null) {
      final folderId = post.folderId!;
      final updatedPost = post.copyWith(folderId: null);
      await _postsBox.put(postId, updatedPost);

      // Update folder post count
      final folder = _foldersBox.get(folderId);
      if (folder != null && folder.postCount > 0) {
        final updatedFolder = folder.copyWith(postCount: folder.postCount - 1);
        await _foldersBox.put(folderId, updatedFolder);
      }
    }
  }

  // Sort folders by name
  List<Folder> getFoldersSortedByName() {
    final folders = _foldersBox.values.toList();
    folders.sort((a, b) => a.name.compareTo(b.name));
    return folders;
  }

  // Sort folders by creation date
  List<Folder> getFoldersSortedByDate() {
    final folders = _foldersBox.values.toList();
    folders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return folders;
  }
}
