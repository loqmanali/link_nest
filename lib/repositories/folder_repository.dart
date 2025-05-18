import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/folder.dart';
import '../models/saved_post.dart';

class FolderRepository {
  late Box<Folder> _foldersBox;
  late Box<SavedPost> _postsBox;
  final _uuid = const Uuid();

  FolderRepository() {
    _initBoxes();
  }

  // Initialize boxes safely
  Future<void> _initBoxes() async {
    try {
      // Initialize folders box
      if (Hive.isBoxOpen('folders')) {
        _foldersBox = Hive.box<Folder>('folders');
      } else {
        _foldersBox = await Hive.openBox<Folder>('folders');
      }

      // Initialize posts box
      if (Hive.isBoxOpen('saved_posts')) {
        _postsBox = Hive.box<SavedPost>('saved_posts');
      } else {
        _postsBox = await Hive.openBox<SavedPost>('saved_posts');
      }
    } catch (e) {
      print('Error initializing folder repositories: $e');
      // Try to recover
      try {
        if (!Hive.isBoxOpen('folders')) {
          await Hive.deleteBoxFromDisk('folders');
          _foldersBox = await Hive.openBox<Folder>('folders');
        }
        if (!Hive.isBoxOpen('saved_posts')) {
          await Hive.deleteBoxFromDisk('saved_posts');
          _postsBox = await Hive.openBox<SavedPost>('saved_posts');
        }
      } catch (e) {
        print('Failed to recover boxes: $e');
      }
    }
  }

  // Get all folders
  List<Folder> getAllFolders() {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('folders')) {
        _initBoxes();
      }
      return _foldersBox.values.toList();
    } catch (e) {
      print('Error getting all folders: $e');
      return [];
    }
  }

  // Add new folder
  Future<String> addFolder({
    required String name,
    String? description,
    required String color,
  }) async {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('folders')) {
        await _initBoxes();
      }

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
    } catch (e) {
      print('Error adding folder: $e');
      return '';
    }
  }

  // Update existing folder
  Future<void> updateFolder(Folder folder) async {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('folders')) {
        await _initBoxes();
      }
      await _foldersBox.put(folder.id, folder);
    } catch (e) {
      print('Error updating folder: $e');
    }
  }

  // Delete folder
  Future<void> deleteFolder(String id) async {
    try {
      // Safety check - make sure boxes are open
      if (!Hive.isBoxOpen('folders') || !Hive.isBoxOpen('saved_posts')) {
        await _initBoxes();
      }

      // First, remove folder reference from all posts in this folder
      final postsInFolder =
          _postsBox.values.where((post) => post.folderId == id).toList();
      for (var post in postsInFolder) {
        final updatedPost = post.copyWith(folderId: null);
        await _postsBox.put(post.id, updatedPost);
      }

      // Then delete the folder
      await _foldersBox.delete(id);
    } catch (e) {
      print('Error deleting folder: $e');
    }
  }

  // Get folder by ID
  Folder? getFolderById(String id) {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('folders')) {
        _initBoxes();
      }
      return _foldersBox.get(id);
    } catch (e) {
      print('Error getting folder by ID: $e');
      return null;
    }
  }

  // Get posts in folder
  List<SavedPost> getPostsInFolder(String folderId) {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('saved_posts')) {
        _initBoxes();
      }
      return _postsBox.values
          .where((post) => post.folderId == folderId)
          .toList();
    } catch (e) {
      print('Error getting posts in folder: $e');
      return [];
    }
  }

  // Add post to folder
  Future<void> addPostToFolder(String postId, String folderId) async {
    try {
      // Safety check - make sure boxes are open
      if (!Hive.isBoxOpen('folders') || !Hive.isBoxOpen('saved_posts')) {
        await _initBoxes();
      }

      final post = _postsBox.get(postId);
      if (post != null) {
        final updatedPost = post.copyWith(folderId: folderId);
        await _postsBox.put(postId, updatedPost);

        // Update folder post count
        final folder = _foldersBox.get(folderId);
        if (folder != null) {
          final updatedFolder =
              folder.copyWith(postCount: folder.postCount + 1);
          await _foldersBox.put(folderId, updatedFolder);
        }
      }
    } catch (e) {
      print('Error adding post to folder: $e');
    }
  }

  // Remove post from folder
  Future<void> removePostFromFolder(String postId) async {
    try {
      // Safety check - make sure boxes are open
      if (!Hive.isBoxOpen('folders') || !Hive.isBoxOpen('saved_posts')) {
        await _initBoxes();
      }

      final post = _postsBox.get(postId);
      if (post != null && post.folderId != null) {
        final folderId = post.folderId!;
        final updatedPost = post.copyWith(folderId: null);
        await _postsBox.put(postId, updatedPost);

        // Update folder post count
        final folder = _foldersBox.get(folderId);
        if (folder != null && folder.postCount > 0) {
          final updatedFolder =
              folder.copyWith(postCount: folder.postCount - 1);
          await _foldersBox.put(folderId, updatedFolder);
        }
      }
    } catch (e) {
      print('Error removing post from folder: $e');
    }
  }

  // Sort folders by name
  List<Folder> getFoldersSortedByName() {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('folders')) {
        _initBoxes();
      }
      final folders = _foldersBox.values.toList();
      folders.sort((a, b) => a.name.compareTo(b.name));
      return folders;
    } catch (e) {
      print('Error sorting folders by name: $e');
      return [];
    }
  }

  // Sort folders by creation date
  List<Folder> getFoldersSortedByDate() {
    try {
      // Safety check - make sure box is open
      if (!Hive.isBoxOpen('folders')) {
        _initBoxes();
      }
      final folders = _foldersBox.values.toList();
      folders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return folders;
    } catch (e) {
      print('Error sorting folders by date: $e');
      return [];
    }
  }
}
