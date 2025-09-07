import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/post_bloc.dart';
import '../constants/app_theme.dart';
import '../models/saved_post.dart';
import '../utils/post_filter_utils.dart';
import '../utils/tag_color_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/filters/active_filter_chip.dart';
import '../widgets/filters/filter_menu.dart';
// Use a distinct name to avoid collision with Flutter's PlatformMenu
import '../widgets/filters/post_platform_menu.dart';
import '../widgets/filters/priority_menu.dart';
import '../widgets/filters/status_menu.dart';
import '../widgets/filters/tags_menu.dart';
import '../widgets/filters/type_menu.dart';
import '../widgets/post_card.dart';
import 'add_post_screen.dart';
import 'folders_screen.dart';
import 'post_details_screen.dart';
import 'tags_screen.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final selectedFilter = useState('all');
    final selectedTab = useState(0);

    // Setup search text field listener
    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
        context.read<PostBloc>().add(SearchPosts(searchController.text));
      }

      searchController.addListener(listener);
      return () {
        searchController.removeListener(listener);
        searchController.dispose();
      };
    }, [searchController]);

    // Define tab screens
    final screens = [
      _buildPostsScreen(context, searchController, searchQuery, selectedFilter),
      const FoldersScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.cardColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'LinkNest',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.foregroundColor,
                letterSpacing: -0.025,
              ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(AppTheme.spacing2),
          child: Material(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPostScreen(),
                ),
              ),
              child: const Icon(
                Iconsax.add,
                color: AppTheme.accentForeground,
                size: 20,
              ),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(AppTheme.spacing2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TagsScreen(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacing2),
                  child: const Icon(
                    Iconsax.tag,
                    color: AppTheme.mutedForeground,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(AppTheme.spacing2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoldersScreen(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacing2),
                  child: const Icon(
                    Iconsax.folder,
                    color: AppTheme.mutedForeground,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: screens[selectedTab.value],
    );
  }

  Widget _buildPostsScreen(
    BuildContext context,
    TextEditingController searchController,
    ValueNotifier<String> searchQuery,
    ValueNotifier<String> selectedFilter,
  ) {
    // Persistent, multi-select filters
    final selectedTags = useState<List<String>>(<String>[]);
    final selectedStatuses = useState<List<String>>(<String>[]);

    // Subtle entrance animations for search and filter bars
    final filterController = useAnimationController(
      duration: const Duration(milliseconds: 450),
    );
    final filterAnimation = CurvedAnimation(
      parent: filterController,
      curve: Curves.easeOutCubic,
    );

    useEffect(() {
      filterController.forward();
      return null;
    }, const []);

    // Load persisted selections once
    useEffect(() {
      Future<void> loadPrefs() async {
        final prefs = await SharedPreferences.getInstance();
        final tags = prefs.getStringList('ui.selected_tags') ?? <String>[];
        final statuses =
            prefs.getStringList('ui.selected_statuses') ?? <String>[];
        if (tags.isNotEmpty) {
          selectedTags.value = List<String>.from(tags);
          context.read<PostBloc>().add(FilterPostsByTags(tags));
        }
        if (statuses.isNotEmpty) {
          selectedStatuses.value = List<String>.from(statuses);
          context.read<PostBloc>().add(FilterPostsByStatuses(statuses));
        }
      }

      loadPrefs();
      return null;
    }, const []);

    // Persist changes
    useEffect(() {
      Future.microtask(() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('ui.selected_tags', selectedTags.value);
      });
      return null;
    }, [selectedTags.value]);

    useEffect(() {
      Future.microtask(() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
            'ui.selected_statuses', selectedStatuses.value);
      });
      return null;
    }, [selectedStatuses.value]);

    return Column(
      children: [
        // Modern search field
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacing4,
            AppTheme.spacing4,
            AppTheme.spacing4,
            AppTheme.spacing2,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.foregroundColor,
                  ),
              decoration: InputDecoration(
                hintText: 'Search posts...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedForeground,
                    ),
                prefixIcon: const Icon(
                  Iconsax.search_normal,
                  color: AppTheme.mutedForeground,
                  size: 18,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Iconsax.close_circle,
                          color: AppTheme.mutedForeground,
                          size: 18,
                        ),
                        onPressed: () => searchController.clear(),
                        splashRadius: 16,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing3,
                  vertical: AppTheme.spacing3,
                ),
              ),
            ),
          ),
        ),

        // Modern filter system with animated entrance
        FadeTransition(
          opacity: filterAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.05),
              end: Offset.zero,
            ).animate(filterAnimation),
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing2,
              ),
              padding: const EdgeInsets.all(AppTheme.spacing1),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.spacing2),
                child: Row(
                  children: [
                    FilterMenu(
                      currentFilter: selectedFilter.value,
                      onSelected: (value) {
                        selectedFilter.value = value;
                        PostFilterUtils.handleFilter(
                          context.read<PostBloc>(),
                          value,
                        );
                      },
                    ),
                    const SizedBox(width: AppTheme.spacing1),
                    PriorityMenu(
                      currentFilter: selectedFilter.value,
                      onSelected: (value) {
                        selectedFilter.value = value;
                        PostFilterUtils.handleFilter(
                          context.read<PostBloc>(),
                          value,
                        );
                      },
                    ),
                    const SizedBox(width: AppTheme.spacing1),
                    TypeMenu(
                      currentFilter: selectedFilter.value,
                      onSelected: (value) {
                        selectedFilter.value = value;
                        PostFilterUtils.handleFilter(
                          context.read<PostBloc>(),
                          value,
                        );
                      },
                    ),
                    const SizedBox(width: AppTheme.spacing1),
                    PostPlatformMenu(
                      currentFilter: selectedFilter.value,
                      onSelected: (value) {
                        selectedFilter.value = value;
                        PostFilterUtils.handleFilter(
                          context.read<PostBloc>(),
                          value,
                        );
                      },
                    ),
                    const SizedBox(width: AppTheme.spacing1),
                    StatusMenu(
                      selectedStatuses: selectedStatuses.value,
                      onApply: (result) {
                        selectedStatuses.value = result;
                        if (result.isEmpty) {
                          context.read<PostBloc>().add(
                              const ApplyMultipleFilters(clearStatus: true));
                        } else {
                          context
                              .read<PostBloc>()
                              .add(FilterPostsByStatuses(result));
                        }
                      },
                    ),
                    const SizedBox(width: AppTheme.spacing1),
                    TagsMenu(
                      selectedTags: selectedTags.value,
                      currentFilter: selectedFilter.value,
                      onApply: (result) {
                        selectedTags.value = result;
                        if (result.isEmpty) {
                          context
                              .read<PostBloc>()
                              .add(const ApplyMultipleFilters(clearTags: true));
                        } else {
                          context
                              .read<PostBloc>()
                              .add(FilterPostsByTags(result));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Modern active filter indicators
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: (selectedFilter.value != 'all' ||
                  selectedTags.value.isNotEmpty ||
                  selectedStatuses.value.isNotEmpty)
              ? Container(
                  key: const ValueKey('active_filter_chips'),
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                    vertical: AppTheme.spacing1,
                  ),
                  child: Wrap(
                    spacing: AppTheme.spacing2,
                    runSpacing: AppTheme.spacing1,
                    children: [
                      if (selectedFilter.value != 'all')
                        ActiveFilterChip(
                          icon: Iconsax.filter,
                          color: PostFilterUtils.getFilterColor(
                              selectedFilter.value),
                          label: PostFilterUtils.getFilterName(
                              selectedFilter.value),
                          onClear: () {
                            selectedFilter.value = 'all';
                            PostFilterUtils.handleFilter(
                              context.read<PostBloc>(),
                              'all',
                            );
                          },
                        ),
                      if (selectedTags.value.isNotEmpty)
                        ActiveFilterChip(
                          icon: Iconsax.tag,
                          color: TagColorUtils.getTagActiveColor(
                              context, selectedTags.value),
                          label: selectedTags.value.length == 1
                              ? selectedTags.value.first
                              : 'Tags (${selectedTags.value.length})',
                          onClear: () {
                            selectedTags.value = <String>[];
                            context.read<PostBloc>().add(
                                const ApplyMultipleFilters(clearTags: true));
                          },
                        ),
                      if (selectedStatuses.value.isNotEmpty)
                        ActiveFilterChip(
                          icon: Iconsax.tick_circle,
                          color: AppTheme.primaryColor,
                          label: selectedStatuses.value.length == 1
                              ? selectedStatuses.value.first
                              : 'Status (${selectedStatuses.value.length})',
                          onClear: () {
                            selectedStatuses.value = <String>[];
                            context.read<PostBloc>().add(
                                  const ApplyMultipleFilters(clearStatus: true),
                                );
                          },
                        ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Posts list
        Expanded(
          child: BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              if (state is PostLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                );
              } else if (state is PostLoaded) {
                final posts = state.posts;

                if (posts.isEmpty) {
                  return const EmptyState(
                    icon: Iconsax.link_21,
                    message: 'No saved posts yet',
                    subMessage:
                        'Add your first post by clicking the + button above',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(
                      post: post,
                      onTap: () => _navigateToPostDetails(context, post),
                    );
                  },
                );
              } else if (state is PostError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.info_circle,
                        size: 48,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
      ],
    );
  }

  void _navigateToPostDetails(BuildContext context, SavedPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailsScreen(post: post)),
    );
  }
}
