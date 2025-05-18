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

class LoadPosts extends PostEvent {}

class AddPost extends PostEvent {
  final String link;
  final String title;
  final String type;
  final String priority;
  final String platform;

  const AddPost({
    required this.link,
    required this.title,
    required this.type,
    required this.priority,
    required this.platform,
  });

  @override
  List<Object?> get props => [link, title, type, priority, platform];
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
  final bool clearType;
  final bool clearPriority;
  final bool clearPlatform;

  const ApplyMultipleFilters({
    this.type,
    this.priority,
    this.platform,
    this.clearType = false,
    this.clearPriority = false,
    this.clearPlatform = false,
  });

  @override
  List<Object?> get props =>
      [type, priority, platform, clearType, clearPriority, clearPlatform];
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

  const PostLoaded(
    this.posts, {
    this.filtered = false,
    this.activeTypeFilter,
    this.activePriorityFilter,
    this.activePlatformFilter,
  });

  @override
  List<Object?> get props => [
        posts,
        filtered,
        activeTypeFilter,
        activePriorityFilter,
        activePlatformFilter,
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

  PostBloc({required this.postRepository}) : super(PostInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<AddPost>(_onAddPost);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
    on<FilterPostsByType>(_onFilterPostsByType);
    on<FilterPostsByPriority>(_onFilterPostsByPriority);
    on<FilterPostsByPlatform>(_onFilterPostsByPlatform);
    on<ApplyMultipleFilters>(_onApplyMultipleFilters);
    on<SortPostsByDate>(_onSortPostsByDate);
    on<ClearFilters>(_onClearFilters);
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
        filtered: _activeTypeFilter != null ||
            _activePriorityFilter != null ||
            _activePlatformFilter != null,
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
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to filter posts: ${e.toString()}'));
    }
  }

  void _onFilterPostsByPriority(
      FilterPostsByPriority event, Emitter<PostState> emit) {
    try {
      _activePriorityFilter = event.priority;
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to filter posts: ${e.toString()}'));
    }
  }

  void _onFilterPostsByPlatform(
      FilterPostsByPlatform event, Emitter<PostState> emit) {
    try {
      _activePlatformFilter = event.platform;
      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to filter posts by platform: ${e.toString()}'));
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

      _applyFilters(emit);
    } catch (e) {
      emit(PostError('Failed to apply multiple filters: ${e.toString()}'));
    }
  }

  void _applyFilters(Emitter<PostState> emit) {
    emit(PostLoading());
    List<SavedPost> filteredPosts = postRepository.getAllPosts();

    // Apply type filter
    if (_activeTypeFilter != null) {
      filteredPosts = filteredPosts
          .where((post) => post.type == _activeTypeFilter)
          .toList();
    }

    // Apply priority filter
    if (_activePriorityFilter != null) {
      filteredPosts = filteredPosts
          .where((post) => post.priority == _activePriorityFilter)
          .toList();
    }

    // Apply platform filter
    if (_activePlatformFilter != null) {
      filteredPosts = filteredPosts
          .where((post) => post.platform == _activePlatformFilter)
          .toList();
    }

    emit(PostLoaded(
      filteredPosts,
      filtered: _activeTypeFilter != null ||
          _activePriorityFilter != null ||
          _activePlatformFilter != null,
      activeTypeFilter: _activeTypeFilter,
      activePriorityFilter: _activePriorityFilter,
      activePlatformFilter: _activePlatformFilter,
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
        filtered: _activeTypeFilter != null ||
            _activePriorityFilter != null ||
            _activePlatformFilter != null,
      ));
    } catch (e) {
      emit(PostError('Failed to sort posts: ${e.toString()}'));
    }
  }

  void _onClearFilters(ClearFilters event, Emitter<PostState> emit) {
    _activeTypeFilter = null;
    _activePriorityFilter = null;
    _activePlatformFilter = null;
    add(LoadPosts());
  }
}
