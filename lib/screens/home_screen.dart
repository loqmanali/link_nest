import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../blocs/post_bloc.dart';
import '../constants/app_theme.dart';
import '../models/saved_post.dart';
import '../widgets/empty_state.dart';
import '../widgets/post_card.dart';
import 'add_post_screen.dart';
import 'folders_screen.dart';
import 'post_details_screen.dart';

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
      searchController.addListener(() {
        searchQuery.value = searchController.text;
      });

      return () => searchController.dispose();
    }, [searchController]);

    // Define tab screens
    final screens = [
      _buildPostsScreen(context, searchController, searchQuery, selectedFilter),
      const FoldersScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'LinkNest',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.additem),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPostScreen(),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.folder_add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FoldersScreen(),
              ),
            ),
          ),
        ],
      ),
      body: screens[selectedTab.value],
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: selectedTab.value,
      //   onTap: (index) => selectedTab.value = index,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.link),
      //       label: 'Links',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.folder),
      //       label: 'Folders',
      //     ),
      //   ],
      // ),
      // floatingActionButton: FloatingActionButton(
      //   heroTag: 'home_fab',
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const AddPostScreen(),
      //       ),
      //     );
      //   },
      //   backgroundColor: AppTheme.primaryColor,
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Widget _buildPostsScreen(
    BuildContext context,
    TextEditingController searchController,
    ValueNotifier<String> searchQuery,
    ValueNotifier<String> selectedFilter,
  ) {
    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Iconsax.search_normal,
                  color: Colors.grey[400], size: 20),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Iconsax.close_circle,
                          color: Colors.grey[400], size: 20),
                      onPressed: () => searchController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),

        // Menubar filter system
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterMenu(context, selectedFilter),
                _buildPriorityMenu(context, selectedFilter),
                _buildTypeMenu(context, selectedFilter),
                _buildPlatformMenu(context, selectedFilter),
              ],
            ),
          ),
        ),

        // Active filter indicator
        if (selectedFilter.value != 'all')
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  _getFilterColor(selectedFilter.value).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _getFilterColor(selectedFilter.value)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter: ${_getFilterName(selectedFilter.value)}',
                  style: TextStyle(
                    color: _getFilterColor(selectedFilter.value),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    selectedFilter.value = 'all';
                    _handleFilter(context, 'all');
                  },
                  child: Icon(
                    Iconsax.close_circle,
                    size: 16,
                    color: _getFilterColor(selectedFilter.value),
                  ),
                ),
              ],
            ),
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

                // Filter by search query if needed
                final filteredPosts = searchQuery.value.isEmpty
                    ? posts
                    : posts
                        .where((post) =>
                            post.title
                                .toLowerCase()
                                .contains(searchQuery.value.toLowerCase()) ||
                            post.type
                                .toLowerCase()
                                .contains(searchQuery.value.toLowerCase()) ||
                            post.priority
                                .toLowerCase()
                                .contains(searchQuery.value.toLowerCase()))
                        .toList();

                if (filteredPosts.isEmpty) {
                  return const EmptyState(
                    icon: Iconsax.link_21,
                    message: 'No saved posts yet',
                    subMessage:
                        'Add your first LinkedIn post by clicking the + button below',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
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
      ],
    );
  }

  // Filter menu
  Widget _buildFilterMenu(
      BuildContext context, ValueNotifier<String> selectedFilter) {
    return PopupMenuButton<String>(
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4),
            Icon(Iconsax.arrow_down_2, size: 20),
          ],
        ),
      ),
      onSelected: (value) {
        selectedFilter.value = value;
        _handleFilter(context, value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'all',
          child: Row(
            children: [
              if (selectedFilter.value == 'all')
                const Icon(Iconsax.tick_circle,
                    size: 16, color: AppTheme.primaryColor),
              SizedBox(width: selectedFilter.value == 'all' ? 8 : 24),
              const Text('All Posts'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'sort_date',
          child: Row(
            children: [
              if (selectedFilter.value == 'sort_date')
                const Icon(Iconsax.tick_circle,
                    size: 16, color: AppTheme.primaryColor),
              SizedBox(width: selectedFilter.value == 'sort_date' ? 8 : 24),
              const Text('Sort by Date'),
            ],
          ),
        ),
      ],
    );
  }

  // Priority menu
  Widget _buildPriorityMenu(
      BuildContext context, ValueNotifier<String> selectedFilter) {
    final isPrioritySelected = selectedFilter.value == 'high_priority' ||
        selectedFilter.value == 'medium_priority' ||
        selectedFilter.value == 'low_priority';
    final textColor = isPrioritySelected
        ? _getFilterColor(selectedFilter.value)
        : Colors.black87;

    return PopupMenuButton<String>(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Priority',
              style: TextStyle(
                fontWeight:
                    isPrioritySelected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Iconsax.arrow_down_2, size: 20, color: textColor),
          ],
        ),
      ),
      onSelected: (value) {
        selectedFilter.value = value;
        _handleFilter(context, value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'high_priority',
          child: Row(
            children: [
              if (selectedFilter.value == 'high_priority')
                const Icon(Iconsax.tick_circle,
                    size: 12, color: AppTheme.highPriorityColor),
              SizedBox(width: selectedFilter.value == 'high_priority' ? 8 : 24),
              const Text('High Priority'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'medium_priority',
          child: Row(
            children: [
              if (selectedFilter.value == 'medium_priority')
                const Icon(Iconsax.tick_circle,
                    size: 12, color: AppTheme.mediumPriorityColor),
              SizedBox(
                  width: selectedFilter.value == 'medium_priority' ? 8 : 24),
              const Text('Medium Priority'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'low_priority',
          child: Row(
            children: [
              if (selectedFilter.value == 'low_priority')
                const Icon(Iconsax.tick_circle,
                    size: 12, color: AppTheme.lowPriorityColor),
              SizedBox(width: selectedFilter.value == 'low_priority' ? 8 : 24),
              const Text('Low Priority'),
            ],
          ),
        ),
      ],
    );
  }

  // Type menu
  Widget _buildTypeMenu(
      BuildContext context, ValueNotifier<String> selectedFilter) {
    final isTypeSelected = selectedFilter.value == 'job' ||
        selectedFilter.value == 'article' ||
        selectedFilter.value == 'tip' ||
        selectedFilter.value == 'opportunity' ||
        selectedFilter.value == 'other';
    final textColor =
        isTypeSelected ? _getFilterColor(selectedFilter.value) : Colors.black87;

    return PopupMenuButton<String>(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Type',
              style: TextStyle(
                fontWeight: isTypeSelected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Iconsax.arrow_down_2, size: 20, color: textColor),
          ],
        ),
      ),
      onSelected: (value) {
        selectedFilter.value = value;
        _handleFilter(context, value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'job',
          child: Row(
            children: [
              if (selectedFilter.value == 'job')
                const Icon(Iconsax.tick_circle,
                    size: 12, color: AppTheme.jobColor),
              SizedBox(width: selectedFilter.value == 'job' ? 8 : 24),
              const Text('Jobs'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'article',
          child: Row(
            children: [
              if (selectedFilter.value == 'article')
                const Icon(Iconsax.tick_circle,
                    size: 12, color: AppTheme.articleColor),
              SizedBox(width: selectedFilter.value == 'article' ? 8 : 24),
              const Text('Articles'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'tip',
          child: Row(
            children: [
              if (selectedFilter.value == 'tip')
                const Icon(Iconsax.tick_circle,
                    size: 12, color: AppTheme.tipColor),
              SizedBox(width: selectedFilter.value == 'tip' ? 8 : 24),
              const Text('Tips'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'opportunity',
          child: Row(
            children: [
              if (selectedFilter.value == 'opportunity')
                const Icon(Iconsax.tick_circle,
                    size: 12, color: AppTheme.opportunityColor),
              SizedBox(width: selectedFilter.value == 'opportunity' ? 8 : 24),
              const Text('Opportunities'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'other',
          child: Row(
            children: [
              if (selectedFilter.value == 'other')
                const Icon(Iconsax.tick_circle,
                    size: 12, color: AppTheme.otherColor),
              SizedBox(width: selectedFilter.value == 'other' ? 8 : 24),
              const Text('Other'),
            ],
          ),
        ),
      ],
    );
  }

  // Platform menu
  Widget _buildPlatformMenu(
      BuildContext context, ValueNotifier<String> selectedFilter) {
    final isPlatformSelected = selectedFilter.value == 'linkedin' ||
        selectedFilter.value == 'twitter' ||
        selectedFilter.value == 'facebook' ||
        selectedFilter.value == 'github' ||
        selectedFilter.value == 'medium' ||
        selectedFilter.value == 'youtube' ||
        selectedFilter.value == 'whatsapp' ||
        selectedFilter.value == 'telegram' ||
        selectedFilter.value == 'other_platform';
    final textColor = isPlatformSelected
        ? _getFilterColor(selectedFilter.value)
        : Colors.black87;

    return PopupMenuButton<String>(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Platform',
              style: TextStyle(
                fontWeight:
                    isPlatformSelected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Iconsax.arrow_down_2, size: 20, color: textColor),
          ],
        ),
      ),
      onSelected: (value) {
        selectedFilter.value = value;
        _handleFilter(context, value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'linkedin',
          child: Row(
            children: [
              if (selectedFilter.value == 'linkedin')
                const Icon(Iconsax.tick_circle, size: 16, color: Colors.blue),
              SizedBox(width: selectedFilter.value == 'linkedin' ? 8 : 24),
              const Text('LinkedIn'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'twitter',
          child: Row(
            children: [
              if (selectedFilter.value == 'twitter')
                const Icon(Iconsax.tick_circle,
                    size: 16, color: Colors.lightBlueAccent),
              SizedBox(width: selectedFilter.value == 'twitter' ? 8 : 24),
              const Text('Twitter'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'facebook',
          child: Row(
            children: [
              if (selectedFilter.value == 'facebook')
                const Icon(Iconsax.tick_circle, size: 16, color: Colors.indigo),
              SizedBox(width: selectedFilter.value == 'facebook' ? 8 : 24),
              const Text('Facebook'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'github',
          child: Row(
            children: [
              if (selectedFilter.value == 'github')
                const Icon(Iconsax.tick_circle,
                    size: 16, color: Colors.black87),
              SizedBox(width: selectedFilter.value == 'github' ? 8 : 24),
              const Text('GitHub'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'medium',
          child: Row(
            children: [
              if (selectedFilter.value == 'medium')
                const Icon(Iconsax.tick_circle, size: 16, color: Colors.green),
              SizedBox(width: selectedFilter.value == 'medium' ? 8 : 24),
              const Text('Medium'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'youtube',
          child: Row(
            children: [
              if (selectedFilter.value == 'youtube')
                const Icon(Iconsax.tick_circle, size: 16, color: Colors.red),
              SizedBox(width: selectedFilter.value == 'youtube' ? 8 : 24),
              const Text('YouTube'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'whatsapp',
          child: Row(
            children: [
              if (selectedFilter.value == 'whatsapp')
                const Icon(Iconsax.tick_circle, size: 16, color: Colors.green),
              SizedBox(width: selectedFilter.value == 'whatsapp' ? 8 : 24),
              const Text('WhatsApp'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'telegram',
          child: Row(
            children: [
              if (selectedFilter.value == 'telegram')
                const Icon(Iconsax.tick_circle,
                    size: 16, color: Colors.lightBlue),
              SizedBox(width: selectedFilter.value == 'telegram' ? 8 : 24),
              const Text('Telegram'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'other_platform',
          child: Row(
            children: [
              if (selectedFilter.value == 'other_platform')
                const Icon(Iconsax.tick_circle, size: 16, color: Colors.grey),
              SizedBox(
                  width: selectedFilter.value == 'other_platform' ? 8 : 24),
              const Text('Other'),
            ],
          ),
        ),
      ],
    );
  }

  // Get filter name for display
  String _getFilterName(String filter) {
    switch (filter) {
      case 'all':
        return 'All Posts';
      case 'sort_date':
        return 'Sort by Date';
      case 'high_priority':
        return 'High Priority';
      case 'medium_priority':
        return 'Medium Priority';
      case 'low_priority':
        return 'Low Priority';
      case 'job':
        return 'Jobs';
      case 'article':
        return 'Articles';
      case 'tip':
        return 'Tips';
      case 'opportunity':
        return 'Opportunities';
      case 'other':
        return 'Other';
      case 'linkedin':
        return 'LinkedIn';
      case 'twitter':
        return 'Twitter';
      case 'facebook':
        return 'Facebook';
      case 'github':
        return 'GitHub';
      case 'medium':
        return 'Medium';
      case 'youtube':
        return 'YouTube';
      case 'whatsapp':
        return 'WhatsApp';
      case 'telegram':
        return 'Telegram';
      case 'other_platform':
        return 'Other Platform';
      default:
        return 'Unknown';
    }
  }

  // Get color for filter
  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'high_priority':
        return AppTheme.highPriorityColor;
      case 'medium_priority':
        return AppTheme.mediumPriorityColor;
      case 'low_priority':
        return AppTheme.lowPriorityColor;
      case 'job':
        return AppTheme.jobColor;
      case 'article':
        return AppTheme.articleColor;
      case 'tip':
        return AppTheme.tipColor;
      case 'opportunity':
        return AppTheme.opportunityColor;
      case 'other':
        return AppTheme.otherColor;
      case 'linkedin':
        return Colors.blue;
      case 'twitter':
        return Colors.lightBlueAccent;
      case 'facebook':
        return Colors.indigo;
      case 'github':
        return Colors.black87;
      case 'medium':
        return Colors.green;
      case 'youtube':
        return Colors.red;
      case 'whatsapp':
        return Colors.green;
      case 'telegram':
        return Colors.lightBlue;
      case 'other_platform':
        return Colors.grey;
      default:
        return AppTheme.primaryColor;
    }
  }

  void _handleFilter(BuildContext context, String filter) {
    final bloc = context.read<PostBloc>();

    switch (filter) {
      case 'all':
        bloc.add(ClearFilters());
        break;
      case 'sort_date':
        bloc.add(SortPostsByDate());
        break;
      case 'high_priority':
        bloc.add(const FilterPostsByPriority(Priority.high));
        break;
      case 'medium_priority':
        bloc.add(const FilterPostsByPriority(Priority.medium));
        break;
      case 'low_priority':
        bloc.add(const FilterPostsByPriority(Priority.low));
        break;
      case 'job':
        bloc.add(const FilterPostsByType(PostType.job));
        break;
      case 'article':
        bloc.add(const FilterPostsByType(PostType.article));
        break;
      case 'tip':
        bloc.add(const FilterPostsByType(PostType.tip));
        break;
      case 'opportunity':
        bloc.add(const FilterPostsByType(PostType.opportunity));
        break;
      case 'other':
        bloc.add(const FilterPostsByType(PostType.other));
        break;
      case 'linkedin':
        _filterByPlatform(bloc, Platform.linkedin);
        break;
      case 'twitter':
        _filterByPlatform(bloc, Platform.twitter);
        break;
      case 'facebook':
        _filterByPlatform(bloc, Platform.facebook);
        break;
      case 'github':
        _filterByPlatform(bloc, Platform.github);
        break;
      case 'medium':
        _filterByPlatform(bloc, Platform.medium);
        break;
      case 'youtube':
        _filterByPlatform(bloc, Platform.youtube);
        break;
      case 'whatsapp':
        _filterByPlatform(bloc, Platform.whatsapp);
        break;
      case 'telegram':
        _filterByPlatform(bloc, Platform.telegram);
        break;
      case 'other_platform':
        _filterByPlatform(bloc, Platform.other);
        break;
    }
  }

  void _filterByPlatform(PostBloc bloc, String platform) {
    bloc.add(FilterPostsByPlatform(platform));
  }

  void _navigateToPostDetails(BuildContext context, SavedPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailsScreen(post: post)),
    );
  }
}
