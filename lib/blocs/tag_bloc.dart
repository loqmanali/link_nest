import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/tag.dart';
import '../repositories/tag_repository.dart';

// Events
abstract class TagEvent extends Equatable {
  const TagEvent();
  @override
  List<Object?> get props => [];
}

class LoadTags extends TagEvent {}

class AddTag extends TagEvent {
  final Tag tag;
  const AddTag(this.tag);
  @override
  List<Object?> get props => [tag];
}

class UpdateTag extends TagEvent {
  final Tag tag;
  const UpdateTag(this.tag);
  @override
  List<Object?> get props => [tag];
}

class DeleteTag extends TagEvent {
  final String id;
  const DeleteTag(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class TagState extends Equatable {
  const TagState();
  @override
  List<Object?> get props => [];
}

class TagInitial extends TagState {}

class TagLoading extends TagState {}

class TagLoaded extends TagState {
  final List<Tag> tags;
  const TagLoaded(this.tags);
  @override
  List<Object?> get props => [tags];
}

class TagError extends TagState {
  final String message;
  const TagError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc with TagRepository integration
class TagBloc extends Bloc<TagEvent, TagState> {
  final TagRepository tagRepository;

  TagBloc({required this.tagRepository}) : super(TagInitial()) {
    on<LoadTags>((event, emit) async {
      try {
        emit(TagLoading());
        final tags = tagRepository.getAll();
        emit(TagLoaded(tags));
      } catch (e) {
        emit(TagError('Failed to load tags: ${e.toString()}'));
      }
    });

    on<AddTag>((event, emit) async {
      try {
        await tagRepository.add(name: event.tag.name, color: event.tag.color);
        add(LoadTags());
      } catch (e) {
        emit(TagError('Failed to add tag: ${e.toString()}'));
      }
    });

    on<UpdateTag>((event, emit) async {
      try {
        await tagRepository.update(event.tag);
        add(LoadTags());
      } catch (e) {
        emit(TagError('Failed to update tag: ${e.toString()}'));
      }
    });

    on<DeleteTag>((event, emit) async {
      try {
        await tagRepository.delete(event.id);
        add(LoadTags());
      } catch (e) {
        emit(TagError('Failed to delete tag: ${e.toString()}'));
      }
    });
  }
}
