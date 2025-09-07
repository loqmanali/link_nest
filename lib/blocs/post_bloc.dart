import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/saved_post.dart';
import '../repositories/post_repository.dart';

// Events
abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

// New: rename a tag across all posts
class RenameTagInAllPosts extends PostEvent {
  final String oldName;
  final String newName;

  const RenameTagInAllPosts(this.oldName, this.newName);

  @override
  List<Object?> get props => [oldName, newName];
}

// New: multi-select for type, priority, platform
class FilterPostsByTypes extends PostEvent {
  final List<String> types;
  const FilterPostsByTypes(this.types);
  @override
  List<Object?> get props => [types];
}

class FilterPostsByPriorities extends PostEvent {
  final List<String> priorities;
  const FilterPostsByPriorities(this.priorities);
  @override
  List<Object?> get props => [priorities];
}

class FilterPostsByPlatforms extends PostEvent {
  final List<String> platforms;
  const FilterPostsByPlatforms(this.platforms);
  @override
  List<Object?> get props => [platforms];
}

// New: multi-select statuses
class FilterPostsByStatuses extends PostEvent {
  final List<String> statuses;

  const FilterPostsByStatuses(this.statuses);

  @override
  List<Object?> get props => [statuses];
}

class FilterPostsByStatus extends PostEvent {
  final String status;

  const FilterPostsByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class FilterPostsByTags extends PostEvent {
  final List<String> tags;

  const FilterPostsByTags(this.tags);

  @override
  List<Object?> get props => [tags];
}

class SearchPosts extends PostEvent {
  final String query;

  const SearchPosts(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadPosts extends PostEvent {}

class AddPost extends PostEvent {
  final String link;
  final String title;
  final String type;
  final String priority;
  final String platform;
  final List<String> tags;
  final String status;

  const AddPost({
    required this.link,
    required this.title,
    required this.type,
    required this.priority,
    required this.platform,
    this.tags = const [],
    this.status = 'unread',
  });

  @override
  List<Object?> get props =>
      [link, title, type, priority, platform, tags, status];
}

class UpdatePost extends PostEvent {
  final SavedPost post;

  const UpdatePost(this.post);

  @override
  List<Object?> get props => [post];
}

class DeletePost extends PostEvent {
  final String id;

  const DeletePost(this.id);

  @override
  List<Object?> get props => [id];
}

// New: remove a tag (by name) from all posts
class RemoveTagFromAllPosts extends PostEvent {
  final String tagName;

  const RemoveTagFromAllPosts(this.tagName);

  @override
  List<Object?> get props => [tagName];
}

class FilterPostsByType extends PostEvent {
  final String type;

  const FilterPostsByType(this.type);

  @override
  List<Object?> get props => [type];
}

class FilterPostsByPriority extends PostEvent {
  final String priority;

  const FilterPostsByPriority(this.priority);

  @override
  List<Object?> get props => [priority];
}

class FilterPostsByPlatform extends PostEvent {
  final String platform;

  const FilterPostsByPlatform(this.platform);

  @override
  List<Object?> get props => [platform];
}

// New event for applying multiple filters
class ApplyMultipleFilters extends PostEvent {
  final String? type;
  final String? priority;
  final String? platform;
  final String? status;
  final List<String>? tags;
  final String? query;
  final bool clearType;
  final bool clearPriority;
  final bool clearPlatform;
  final bool clearStatus;
  final bool clearTags;
  final bool clearQuery;

  const ApplyMultipleFilters({
    this.type,
    this.priority,
    this.platform,
    this.status,
    this.tags,
    this.query,
    this.clearType = false,
    this.clearPriority = false,
    this.clearPlatform = false,
    this.clearStatus = false,
    this.clearTags = false,
    this.clearQuery = false,
  });

  @override
  List<Object?> get props => [
        type,
        priority,
        platform,
        status,
        tags,
        query,
        clearType,
        clearPriority,
        clearPlatform,
        clearStatus,
        clearTags,
        clearQuery,
      ];
}

class SortPostsByDate extends PostEvent {}

class ClearFilters extends PostEvent {}

// States
abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<SavedPost> posts;
  final bool filtered;
  final String? activeTypeFilter;
  final String? activePriorityFilter;
  final String? activePlatformFilter;
  final String? activeStatusFilter;
  final List<String>? activeTagsFilter;
  final String? searchQuery;

  const PostLoaded(
    this.posts, {
    this.filtered = false,
    this.activeTypeFilter,
    this.activePriorityFilter,
    this.activePlatformFilter,
    this.activeStatusFilter,
    this.activeTagsFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        posts,
        filtered,
        activeTypeFilter,
        activePriorityFilter,
        activePlatformFilter,
        activeStatusFilter,
        activeTagsFilter,
        searchQuery,
      ];
}

class PostError extends PostState {
  final String message;

  const PostError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;
  String? _activeTypeFilter;
  String? _activePriorityFilter;
  String? _activePlatformFilter;
  String? _activeStatusFilter;
  List<String>? _activeStatusesFilter;
  List<String>? _activeTypesFilter;
  List<String>? _activePrioritiesFilter;
  List<String>? _activePlatformsFilter;
  List<String>? _activeTagsFilter;
  String? _searchQuery;

  PostBloc({required this.postRepository}) : super(PostInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<AddPost>(_onAddPost);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
    on<RemoveTagFromAllPosts>(_onRemoveTagFromAllPosts);
    on<RenameTagInAllPosts>(_onRenameTagInAllPosts);
    on<FilterPostsByType>(_onFilterPostsByType);
    on<FilterPostsByPriority>(_onFilterPostsByPriority);
    on<FilterPostsByPlatform>(_onFilterPostsByPlatform);
    on<FilterPostsByTypes>(_onFilterPostsByTypes);
    on<FilterPostsByPriorities>(_onFilterPostsByPriorities);
    on<FilterPostsByPlatforms>(_onFilterPostsByPlatforms);
    on<FilterPostsByStatus>(_onFilterPostsByStatus);
    on<FilterPostsByStatuses>(_onFilterPostsByStatuses);
    on<FilterPostsByTags>(_onFilterPostsByTags);
    on<SearchPosts>(_onSearchPosts);
    on<ApplyMultipleFilters>(_onApplyMultipleFilters);
    on<SortPostsByDate>(_onSortPostsByDate);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onRenameTagInAllPosts(
      RenameTagInAllPosts event, Emitter<PostState> emit) async {
    try {
      final all = postRepository.getAllPosts();
      final target = event.oldName.toLowerCase();
      final replacement = event.newName;

      for (final p in all) {
        bool changed = false;
        final newTags = p.tags.map((t) {
          if (t.toLowerCase() == target) {
            changed = true;
            return replacement;
          }
          return t;
        }).toList();
        if (changed) {
          final updated = p.copyWith(tags: newTags);
          await postRepository.updatePost(updated);
        }
      }
      add(LoadPosts());
    } catch (e) {
      emit(PostError('Failed to rename tag in posts: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveTagFromAllPosts(
      RemoveTagFromAllPosts event, Emitter<PostState> emit) async {
    try {
      final all = postRepository.getAllPosts();
      final target = event.tagName.toLowerCase();

      for (final p in all) {
        final newTags = p.tags.where((t) => t.toLowerCase() != target).toList();
        if (newTags.length != p.tags.length) {
          final updated = p.copyWith(tags: newTags);
          await postRepository.updatePost(updated);
        }
      }
      add(LoadPosts());
    } catch (e) {
      emit(PostError('Failed to remove tag from posts: ${e.toString()}'));
    }
  }

  void _onFilterPostsByStatus(
      FilterPostsByStatus event, Emitter<PostState> emit) {
    try {
      _activeStatusFilter = event.status;
      _activeStatusesFilter = null;
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to filter posts by status: ${e.toString()}'));
    }
  }

  void _onFilterPostsByStatuses(
      FilterPostsByStatuses event, Emitter<PostState> emit) {
    try {
      _activeStatusesFilter = event.statuses;
      _activeStatusFilter = null;
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to filter posts by statuses: ${e.toString()}'));
    }
  }

  void _onFilterPostsByTags(FilterPostsByTags event, Emitter<PostState> emit) {
    try {
      _activeTagsFilter = event.tags;
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to filter posts by tags: ${e.toString()}'));
    }
  }

  void _onSearchPosts(SearchPosts event, Emitter<PostState> emit) {
    try {
      _searchQuery = event.query.trim().isEmpty ? null : event.query.trim();
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to search posts: ${e.toString()}'));
    }
  }

  void _onLoadPosts(LoadPosts event, Emitter<PostState> emit) {
    try {
      emit(PostLoading());
      final posts = postRepository.getAllPosts();
      emit(PostLoaded(
        posts,
        activeTypeFilter: _activeTypeFilter,
        activePriorityFilter: _activePriorityFilter,
        activePlatformFilter: _activePlatformFilter,
        activeStatusFilter: _activeStatusFilter,
        activeTagsFilter: _activeTagsFilter,
        searchQuery: _searchQuery,
        filtered: _activeTypeFilter != null ||
            _activePriorityFilter != null ||
            _activePlatformFilter != null ||
            _activeStatusFilter != null ||
            (_activeTagsFilter != null && _activeTagsFilter!.isNotEmpty) ||
            (_searchQuery != null && _searchQuery!.isNotEmpty),
      ));
    } catch (e) {
      emit(PostError('Failed to load posts: ${e.toString()}'));
    }
  }

  void _onAddPost(AddPost event, Emitter<PostState> emit) async {
    try {
      if (state is PostLoaded) {
        await postRepository.addPost(
          link: event.link,
          title: event.title,
          type: event.type,
          priority: event.priority,
          platform: event.platform,
          tags: event.tags,
          status: event.status,
        );
        add(LoadPosts());
      }
    } catch (e) {
      emit(PostError('Failed to add post: ${e.toString()}'));
    }
  }

  void _onUpdatePost(UpdatePost event, Emitter<PostState> emit) async {
    try {
      if (state is PostLoaded) {
        await postRepository.updatePost(event.post);
        add(LoadPosts());
      }
    } catch (e) {
      emit(PostError('Failed to update post: ${e.toString()}'));
    }
  }

  void _onDeletePost(DeletePost event, Emitter<PostState> emit) async {
    try {
      if (state is PostLoaded) {
        await postRepository.deletePost(event.id);
        add(LoadPosts());
      }
    } catch (e) {
      emit(PostError('Failed to delete post: ${e.toString()}'));
    }
  }

  void _onFilterPostsByType(FilterPostsByType event, Emitter<PostState> emit) {
    try {
      _activeTypeFilter = event.type;
      _activeTypesFilter = null;
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to filter posts: ${e.toString()}'));
    }
  }

  void _onFilterPostsByPriority(
      FilterPostsByPriority event, Emitter<PostState> emit) {
    try {
      _activePriorityFilter = event.priority;
      _activePrioritiesFilter = null;
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to filter posts: ${e.toString()}'));
    }
  }

  void _onFilterPostsByPlatform(
      FilterPostsByPlatform event, Emitter<PostState> emit) {
    try {
      _activePlatformFilter = event.platform;
      _activePlatformsFilter = null;
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to filter posts by platform: ${e.toString()}'));
    }
  }

  void _onFilterPostsByTypes(
      FilterPostsByTypes event, Emitter<PostState> emit) {
    try {
      _activeTypesFilter = event.types;
      _activeTypeFilter = null;
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to filter posts by types: ${e.toString()}'));
    }
  }

  void _onFilterPostsByPriorities(
      FilterPostsByPriorities event, Emitter<PostState> emit) {
    try {
      _activePrioritiesFilter = event.priorities;
      _activePriorityFilter = null;
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to filter posts by priorities: ${e.toString()}'));
    }
  }

  void _onFilterPostsByPlatforms(
      FilterPostsByPlatforms event, Emitter<PostState> emit) {
    try {
      _activePlatformsFilter = event.platforms;
      _activePlatformFilter = null;
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to filter posts by platforms: ${e.toString()}'));
    }
  }

  void _onApplyMultipleFilters(
      ApplyMultipleFilters event, Emitter<PostState> emit) {
    try {
      // Update filters based on event
      if (event.type != null) {
        _activeTypeFilter = event.type;
      } else if (event.clearType) {
        _activeTypeFilter = null;
      }

      if (event.priority != null) {
        _activePriorityFilter = event.priority;
      } else if (event.clearPriority) {
        _activePriorityFilter = null;
      }

      if (event.platform != null) {
        _activePlatformFilter = event.platform;
      } else if (event.clearPlatform) {
        _activePlatformFilter = null;
      }

      if (event.status != null) {
        _activeStatusFilter = event.status;
        // Ensure multi-select is cleared when a single status is applied
        _activeStatusesFilter = null;
      } else if (event.clearStatus) {
        // Clear both single and multi-select status filters
        _activeStatusFilter = null;
        _activeStatusesFilter = null;
      }

      if (event.tags != null) {
        _activeTagsFilter = event.tags;
      } else if (event.clearTags) {
        _activeTagsFilter = null;
      }

      if (event.query != null) {
        final q = event.query!.trim();
        _searchQuery = q.isEmpty ? null : q;
      } else if (event.clearQuery) {
        _searchQuery = null;
      }

      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to apply multiple filters: ${e.toString()}'));
    }
  }

  void _applyFilters(Emitter<PostState> emit) {
    emit(PostLoading());
    List<SavedPost> filteredPosts = postRepository.getAllPosts();

    // Apply type filter (multi-select takes precedence)
    if (_activeTypesFilter != null && _activeTypesFilter!.isNotEmpty) {
      final set = _activeTypesFilter!.toSet();
      filteredPosts =
          filteredPosts.where((post) => set.contains(post.type)).toList();
    } else if (_activeTypeFilter != null) {
      filteredPosts = filteredPosts
          .where((post) => post.type == _activeTypeFilter)
          .toList();
    }

    // Apply priority filter (multi-select takes precedence)
    if (_activePrioritiesFilter != null &&
        _activePrioritiesFilter!.isNotEmpty) {
      final set = _activePrioritiesFilter!.toSet();
      filteredPosts =
          filteredPosts.where((post) => set.contains(post.priority)).toList();
    } else if (_activePriorityFilter != null) {
      filteredPosts = filteredPosts
          .where((post) => post.priority == _activePriorityFilter)
          .toList();
    }

    // Apply platform filter (multi-select takes precedence)
    if (_activePlatformsFilter != null && _activePlatformsFilter!.isNotEmpty) {
      final set = _activePlatformsFilter!.toSet();
      filteredPosts =
          filteredPosts.where((post) => set.contains(post.platform)).toList();
    } else if (_activePlatformFilter != null) {
      filteredPosts = filteredPosts
          .where((post) => post.platform == _activePlatformFilter)
          .toList();
    }

    // Apply status filter (multi-select takes precedence)
    if (_activeStatusesFilter != null && _activeStatusesFilter!.isNotEmpty) {
      final set = _activeStatusesFilter!.toSet();
      filteredPosts =
          filteredPosts.where((post) => set.contains(post.status)).toList();
    } else if (_activeStatusFilter != null) {
      filteredPosts = filteredPosts
          .where((post) => post.status == _activeStatusFilter)
          .toList();
    }

    // Apply tags filter (any match)
    if (_activeTagsFilter != null && _activeTagsFilter!.isNotEmpty) {
      final tagSet = _activeTagsFilter!.map((t) => t.toLowerCase()).toSet();
      filteredPosts = filteredPosts
          .where(
              (post) => post.tags.any((t) => tagSet.contains(t.toLowerCase())))
          .toList();
    }

    // Apply text search (title/link)
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final q = _searchQuery!.toLowerCase();
      filteredPosts = filteredPosts
          .where((post) =>
              post.title.toLowerCase().contains(q) ||
              post.link.toLowerCase().contains(q))
          .toList();
    }

    emit(PostLoaded(
      filteredPosts,
      filtered: _activeTypeFilter != null ||
          (_activeTypesFilter != null && _activeTypesFilter!.isNotEmpty) ||
          _activePriorityFilter != null ||
          (_activePrioritiesFilter != null &&
              _activePrioritiesFilter!.isNotEmpty) ||
          _activePlatformFilter != null ||
          (_activePlatformsFilter != null &&
              _activePlatformsFilter!.isNotEmpty) ||
          _activeStatusFilter != null ||
          (_activeStatusesFilter != null &&
              _activeStatusesFilter!.isNotEmpty) ||
          (_activeTagsFilter != null && _activeTagsFilter!.isNotEmpty) ||
          (_searchQuery != null && _searchQuery!.isNotEmpty),
      activeTypeFilter: _activeTypeFilter,
      activePriorityFilter: _activePriorityFilter,
      activePlatformFilter: _activePlatformFilter,
      activeStatusFilter: _activeStatusFilter,
      activeTagsFilter: _activeTagsFilter,
      searchQuery: _searchQuery,
    ));
  }

  void _onSortPostsByDate(SortPostsByDate event, Emitter<PostState> emit) {
    try {
      emit(PostLoading());
      final sortedPosts = postRepository.getPostsSortedByDate();
      emit(PostLoaded(
        sortedPosts,
        activeTypeFilter: _activeTypeFilter,
        activePriorityFilter: _activePriorityFilter,
        activePlatformFilter: _activePlatformFilter,
        activeStatusFilter: _activeStatusFilter,
        activeTagsFilter: _activeTagsFilter,
        searchQuery: _searchQuery,
        filtered: _activeTypeFilter != null ||
            _activePriorityFilter != null ||
            _activePlatformFilter != null ||
            _activeStatusFilter != null ||
            (_activeTagsFilter != null && _activeTagsFilter!.isNotEmpty) ||
            (_searchQuery != null && _searchQuery!.isNotEmpty),
      ));
    } catch (e) {
      emit(PostError('Failed to sort posts: ${e.toString()}'));
    }
  }

  void _onClearFilters(ClearFilters event, Emitter<PostState> emit) {
    _activeTypeFilter = null;
    _activePriorityFilter = null;
    _activePlatformFilter = null;
    _activeStatusFilter = null;
    // Clear all multi-select filters as well
    _activeTypesFilter = null;
    _activePrioritiesFilter = null;
    _activePlatformsFilter = null;
    _activeStatusesFilter = null;
    _activeTagsFilter = null;
    _searchQuery = null;
    add(LoadPosts());
  }
}
