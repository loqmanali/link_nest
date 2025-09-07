import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/folder.dart';
import '../repositories/folder_repository.dart';

// Events
abstract class FolderEvent extends Equatable {
  const FolderEvent();

  @override
  List<Object?> get props => [];
}

class LoadFolders extends FolderEvent {}

class AddFolder extends FolderEvent {
  final String name;
  final String? description;
  final String color;

  const AddFolder({
    required this.name,
    this.description,
    required this.color,
  });

  @override
  List<Object?> get props => [name, description, color];
}

class UpdateFolder extends FolderEvent {
  final Folder folder;

  const UpdateFolder(this.folder);

  @override
  List<Object?> get props => [folder];
}

class DeleteFolder extends FolderEvent {
  final String id;

  const DeleteFolder(this.id);

  @override
  List<Object?> get props => [id];
}

class AddPostToFolder extends FolderEvent {
  final String postId;
  final String folderId;

  const AddPostToFolder(this.postId, this.folderId);

  @override
  List<Object?> get props => [postId, folderId];
}

class RemovePostFromFolder extends FolderEvent {
  final String postId;

  const RemovePostFromFolder(this.postId);

  @override
  List<Object?> get props => [postId];
}

class SortFoldersByName extends FolderEvent {}

class SortFoldersByDate extends FolderEvent {}

// States
abstract class FolderState extends Equatable {
  const FolderState();

  @override
  List<Object?> get props => [];
}

class FolderInitial extends FolderState {}

class FolderLoading extends FolderState {}

class FolderLoaded extends FolderState {
  final List<Folder> folders;
  final bool sortedByName;

  const FolderLoaded(
    this.folders, {
    this.sortedByName = false,
  });

  @override
  List<Object?> get props => [folders, sortedByName];
}

class FolderError extends FolderState {
  final String message;

  const FolderError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class FolderBloc extends Bloc<FolderEvent, FolderState> {
  final FolderRepository folderRepository;
  bool _sortedByName = false;

  FolderBloc({required this.folderRepository}) : super(FolderInitial()) {
    on<LoadFolders>(_onLoadFolders);
    on<AddFolder>(_onAddFolder);
    on<UpdateFolder>(_onUpdateFolder);
    on<DeleteFolder>(_onDeleteFolder);
    on<AddPostToFolder>(_onAddPostToFolder);
    on<RemovePostFromFolder>(_onRemovePostFromFolder);
    on<SortFoldersByName>(_onSortFoldersByName);
    on<SortFoldersByDate>(_onSortFoldersByDate);
  }

  void _onLoadFolders(LoadFolders event, Emitter<FolderState> emit) {
    try {
      emit(FolderLoading());
      final folders = _sortedByName
          ? folderRepository.getFoldersSortedByName()
          : folderRepository.getFoldersSortedByDate();
      emit(FolderLoaded(folders, sortedByName: _sortedByName));
    } catch (e) {
      emit(FolderError('Failed to load folders: ${e.toString()}'));
    }
  }

  void _onAddFolder(AddFolder event, Emitter<FolderState> emit) async {
    try {
      if (state is FolderLoaded) {
        await folderRepository.addFolder(
          name: event.name,
          description: event.description,
          color: event.color,
        );
        add(LoadFolders());
      }
    } catch (e) {
      emit(FolderError('Failed to add folder: ${e.toString()}'));
    }
  }

  void _onUpdateFolder(UpdateFolder event, Emitter<FolderState> emit) async {
    try {
      if (state is FolderLoaded) {
        await folderRepository.updateFolder(event.folder);
        add(LoadFolders());
      }
    } catch (e) {
      emit(FolderError('Failed to update folder: ${e.toString()}'));
    }
  }

  void _onDeleteFolder(DeleteFolder event, Emitter<FolderState> emit) async {
    try {
      if (state is FolderLoaded) {
        await folderRepository.deleteFolder(event.id);
        add(LoadFolders());
      }
    } catch (e) {
      emit(FolderError('Failed to delete folder: ${e.toString()}'));
    }
  }

  void _onAddPostToFolder(
      AddPostToFolder event, Emitter<FolderState> emit) async {
    try {
      await folderRepository.addPostToFolder(event.postId, event.folderId);
      add(LoadFolders());
    } catch (e) {
      emit(FolderError('Failed to add post to folder: ${e.toString()}'));
    }
  }

  void _onRemovePostFromFolder(
      RemovePostFromFolder event, Emitter<FolderState> emit) async {
    try {
      await folderRepository.removePostFromFolder(event.postId);
      add(LoadFolders());
    } catch (e) {
      emit(FolderError('Failed to remove post from folder: ${e.toString()}'));
    }
  }

  void _onSortFoldersByName(
      SortFoldersByName event, Emitter<FolderState> emit) {
    try {
      if (state is FolderLoaded) {
        _sortedByName = true;
        final folders = folderRepository.getFoldersSortedByName();
        emit(FolderLoaded(folders, sortedByName: true));
      }
    } catch (e) {
      emit(FolderError('Failed to sort folders: ${e.toString()}'));
    }
  }

  void _onSortFoldersByDate(
      SortFoldersByDate event, Emitter<FolderState> emit) {
    try {
      if (state is FolderLoaded) {
        _sortedByName = false;
        final folders = folderRepository.getFoldersSortedByDate();
        emit(FolderLoaded(folders, sortedByName: false));
      }
    } catch (e) {
      emit(FolderError('Failed to sort folders: ${e.toString()}'));
    }
  }
}
