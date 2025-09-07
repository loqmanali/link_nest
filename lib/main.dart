import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'blocs/folder_bloc.dart';
import 'blocs/post_bloc.dart';
import 'blocs/reminder_bloc.dart';
import 'blocs/tag_bloc.dart';
import 'constants/app_theme.dart';
import 'models/annotation.dart';
import 'models/attachment.dart';
import 'models/folder.dart';
import 'models/reminder.dart';
import 'models/saved_post.dart';
import 'models/source.dart';
import 'models/tag.dart';
import 'repositories/folder_repository.dart';
import 'repositories/post_repository.dart';
import 'repositories/reminder_repository.dart';
import 'repositories/tag_repository.dart';
import 'screens/home_screen.dart';

// Global navigator key for accessing context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  if (kIsWeb) {
    // For web platform, initialize without a specific path
    await Hive.initFlutter();
  } else {
    // For mobile platforms, use path_provider
    try {
      final appDocumentDirectory =
          await path_provider.getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDirectory.path);
    } catch (e) {
      log('Error initializing Hive: $e', name: 'Hive', error: e);
      // Fallback to initializing without a path
      await Hive.initFlutter();
    }
  }

  // Register Hive adapters
  try {
    Hive.registerAdapter(SavedPostAdapter());
    Hive.registerAdapter(FolderAdapter());
    Hive.registerAdapter(TagAdapter());
    Hive.registerAdapter(ReminderAdapter());
    Hive.registerAdapter(AnnotationAdapter());
    Hive.registerAdapter(AttachmentAdapter());
    Hive.registerAdapter(SourceAdapter());
  } catch (e) {
    log('Error registering adapters: $e', name: 'Hive', error: e);
  }

  // Open Hive boxes
  try {
    await Hive.openBox<SavedPost>('saved_posts');
    await Hive.openBox<Folder>('folders');
    await Hive.openBox<Tag>('tags');
    await Hive.openBox<Reminder>('reminders');
  } catch (e) {
    log('Error opening Hive boxes: $e', name: 'Hive', error: e);
    // Try deleting and recreating boxes if they're corrupted
    await Hive.deleteBoxFromDisk('saved_posts');
    await Hive.deleteBoxFromDisk('folders');
    await Hive.deleteBoxFromDisk('tags');
    await Hive.deleteBoxFromDisk('reminders');
    await Hive.openBox<SavedPost>('saved_posts');
    await Hive.openBox<Folder>('folders');
    await Hive.openBox<Tag>('tags');
    await Hive.openBox<Reminder>('reminders');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => PostRepository()),
        RepositoryProvider(create: (context) => FolderRepository()),
        RepositoryProvider(create: (context) => TagRepository()),
        RepositoryProvider(create: (context) => ReminderRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              final repository = context.read<PostRepository>();
              return PostBloc(postRepository: repository)..add(LoadPosts());
            },
          ),
          BlocProvider(
            create: (context) {
              final repository = context.read<FolderRepository>();
              return FolderBloc(folderRepository: repository)
                ..add(LoadFolders());
            },
          ),
          BlocProvider(
            create: (context) {
              final repository = context.read<TagRepository>();
              return TagBloc(tagRepository: repository)..add(LoadTags());
            },
          ),
          BlocProvider(
            create: (context) {
              final repository = context.read<ReminderRepository>();
              return ReminderBloc(reminderRepository: repository)
                ..add(LoadReminders());
            },
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'LinkNest',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}


/// <iframe src="https://www.linkedin.com/embed/feed/update/urn:li:ugcPost:7370138266773258240" height="924" width="504" frameborder="0" allowfullscreen="" title="Embedded post"></iframe>