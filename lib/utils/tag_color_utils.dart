import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/tag_bloc.dart';
import '../constants/app_theme.dart';
import '../models/tag.dart';

class TagColorUtils {
  // Computes active color for tag pill (single tag uses its stored color), otherwise primary
  static Color getTagActiveColor(BuildContext context, List<String> tags) {
    if (tags.length == 1) {
      final state = context.read<TagBloc>().state;
      if (state is TagLoaded) {
        final tag = state.tags.firstWhere(
          (t) => t.name == tags.first,
          orElse: () => Tag(id: '', name: tags.first, color: null),
        );
        if (tag.color != null) {
          return Color(int.parse(tag.color!.replaceFirst('#', '0xff')));
        }
      }
    }
    return AppTheme.primaryColor;
  }
}
