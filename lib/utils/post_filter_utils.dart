import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../blocs/post_bloc.dart';
import '../models/saved_post.dart';

class PostFilterUtils {
  static String getFilterName(String filter) {
    if (filter.startsWith('tag:')) {
      return filter.substring(4);
    }
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

  static Color getFilterColor(String filter) {
    if (filter.startsWith('tag:')) {
      return AppTheme.primaryColor;
    }
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

  static void handleFilter(PostBloc bloc, String filter) {
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

  static void _filterByPlatform(PostBloc bloc, String platform) {
    bloc.add(FilterPostsByPlatform(platform));
  }
}
