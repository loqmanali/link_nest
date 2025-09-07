import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class UpdateQuery extends SearchEvent {
  final String query;
  const UpdateQuery(this.query);
  @override
  List<Object?> get props => [query];
}

class UpdateFilters extends SearchEvent {
  final String? type;
  final String? priority;
  final String? platform;
  final String? status;
  final List<String>? tags;
  const UpdateFilters({
    this.type,
    this.priority,
    this.platform,
    this.status,
    this.tags,
  });
  @override
  List<Object?> get props => [type, priority, platform, status, tags];
}

class ClearSearch extends SearchEvent {}

// States
class SearchState extends Equatable {
  final String query;
  final String? type;
  final String? priority;
  final String? platform;
  final String? status;
  final List<String> tags;
  const SearchState({
    this.query = '',
    this.type,
    this.priority,
    this.platform,
    this.status,
    this.tags = const [],
  });

  SearchState copyWith({
    String? query,
    String? type,
    String? priority,
    String? platform,
    String? status,
    List<String>? tags,
  }) => SearchState(
        query: query ?? this.query,
        type: type ?? this.type,
        priority: priority ?? this.priority,
        platform: platform ?? this.platform,
        status: status ?? this.status,
        tags: tags ?? this.tags,
      );

  @override
  List<Object?> get props => [query, type, priority, platform, status, tags];
}

// Bloc (acts as UI aggregator; PostBloc holds actual list)
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState()) {
    on<UpdateQuery>((event, emit) {
      emit(state.copyWith(query: event.query));
    });
    on<UpdateFilters>((event, emit) {
      emit(state.copyWith(
        type: event.type,
        priority: event.priority,
        platform: event.platform,
        status: event.status,
        tags: event.tags,
      ));
    });
    on<ClearSearch>((event, emit) {
      emit(const SearchState());
    });
  }
}
