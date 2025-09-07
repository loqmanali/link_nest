import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/reminder.dart';
import '../repositories/reminder_repository.dart';

// Events
abstract class ReminderEvent extends Equatable {
  const ReminderEvent();
  @override
  List<Object?> get props => [];
}

class LoadReminders extends ReminderEvent {}

class AddReminder extends ReminderEvent {
  final Reminder reminder;
  const AddReminder(this.reminder);
  @override
  List<Object?> get props => [reminder];
}

class DeleteReminder extends ReminderEvent {
  final String id;
  const DeleteReminder(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class ReminderState extends Equatable {
  const ReminderState();
  @override
  List<Object?> get props => [];
}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class ReminderLoaded extends ReminderState {
  final List<Reminder> reminders;
  const ReminderLoaded(this.reminders);
  @override
  List<Object?> get props => [reminders];
}

class ReminderError extends ReminderState {
  final String message;
  const ReminderError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc with ReminderRepository integration
class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository reminderRepository;

  ReminderBloc({required this.reminderRepository}) : super(ReminderInitial()) {
    on<LoadReminders>((event, emit) async {
      try {
        emit(ReminderLoading());
        final reminders = reminderRepository.getAll();
        emit(ReminderLoaded(reminders));
      } catch (e) {
        emit(ReminderError('Failed to load reminders: ${e.toString()}'));
      }
    });

    on<AddReminder>((event, emit) async {
      try {
        await reminderRepository.add(
          postId: event.reminder.postId,
          dueAt: event.reminder.dueAt,
          repeat: event.reminder.repeat,
        );
        add(LoadReminders());
      } catch (e) {
        emit(ReminderError('Failed to add reminder: ${e.toString()}'));
      }
    });

    on<DeleteReminder>((event, emit) async {
      try {
        await reminderRepository.delete(event.id);
        add(LoadReminders());
      } catch (e) {
        emit(ReminderError('Failed to delete reminder: ${e.toString()}'));
      }
    });
  }
}
