import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'blocs/folder_bloc.dart';
import 'blocs/post_bloc.dart';
import 'constants/app_theme.dart';
import 'models/folder.dart';
import 'models/saved_post.dart';
import 'repositories/folder_repository.dart';
import 'repositories/post_repository.dart';
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
    final appDocumentDirectory =
        await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDirectory.path);
  }

  // Register Hive adapters
  Hive.registerAdapter(SavedPostAdapter());
  Hive.registerAdapter(FolderAdapter());

  // Open Hive boxes
  await Hive.openBox<SavedPost>('saved_posts');
  await Hive.openBox<Folder>('folders');

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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PostBloc(
              postRepository: context.read<PostRepository>(),
            )..add(LoadPosts()),
          ),
          BlocProvider(
            create: (context) => FolderBloc(
              folderRepository: context.read<FolderRepository>(),
            )..add(LoadFolders()),
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
