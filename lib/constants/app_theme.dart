import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF0077B5); // LinkedIn blue
  static const Color accentColor = Color(0xFF00A0DC);
  static const Color secondaryColor = Color(0xFF283E4A);
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF3F6F8);
  static const Color errorColor = Color(0xFFE51937);

  // Text colors
  static const Color primaryTextColor = Color(0xFF333333);
  static const Color secondaryTextColor = Color(0xFF666666);
  static const Color lightTextColor = Color(0xFF999999);

  // Priority colors
  static const Color highPriorityColor = Color(0xFFE51937); // Red
  static const Color mediumPriorityColor = Color(0xFFF5A623); // Orange
  static const Color lowPriorityColor = Color(0xFF7BBC65); // Green

  // Post type colors
  static const Color jobColor = Color(0xFF0077B5); // LinkedIn blue
  static const Color articleColor = Color(0xFF00A0DC); // Light blue
  static const Color tipColor = Color(0xFF7BBC65); // Green
  static const Color opportunityColor = Color(0xFFF5A623); // Orange
  static const Color otherColor = Color(0xFF9E9E9E); // Gray

  // Platform colors
  static const Color twitterColor = Color(0xFF1DA1F2); // Twitter blue
  static const Color linkedinColor = Color(0xFF0077B5); // LinkedIn blue
  static const Color facebookColor = Color(0xFF1877F2); // Facebook blue
  static const Color instagramColor = Color(0xFFE4405F); // Instagram pink/red
  static const Color youtubeColor = Color(0xFFFF0000); // YouTube red
  static const Color githubColor = Color(0xFF333333); // GitHub dark
  static const Color mediumColor = Color(0xFF00AB6C); // Medium green
  static const Color redditColor = Color(0xFFFF4500); // Reddit orange
  static const Color whatsappColor = Color(0xFF25D366); // WhatsApp green
  static const Color telegramColor = Color(0xFF0088CC); // Telegram blue
  static const Color defaultPlatformColor = Color(0xFF9E9E9E); // Default gray

  // Padding
  static const double smallPadding = 8.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;

  // Border radius
  static const double borderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: primaryTextColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: primaryTextColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: primaryTextColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: secondaryTextColor,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: lightTextColor,
        fontSize: 12,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: smallPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: secondaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: secondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.all(defaultPadding),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    useMaterial3: true,
  );

  // Get color for priority
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return highPriorityColor;
      case 'Medium':
        return mediumPriorityColor;
      case 'Low':
        return lowPriorityColor;
      default:
        return primaryColor;
    }
  }

  // Get color for post type
  static Color getPostTypeColor(String type) {
    switch (type) {
      case 'Job':
        return jobColor;
      case 'Article':
        return articleColor;
      case 'Tip':
        return tipColor;
      case 'Opportunity':
        return opportunityColor;
      case 'Other':
        return otherColor;
      default:
        return primaryColor;
    }
  }

  // Get color for platform
  static Color getPlatformColor(String platform) {
    if (platform.isEmpty) {
      return defaultPlatformColor;
    }

    switch (platform.toLowerCase()) {
      case 'twitter':
      case 'x':
        return twitterColor;
      case 'linkedin':
        return linkedinColor;
      case 'facebook':
        return facebookColor;
      case 'instagram':
        return instagramColor;
      case 'youtube':
        return youtubeColor;
      case 'github':
        return githubColor;
      case 'medium':
        return mediumColor;
      case 'reddit':
        return redditColor;
      case 'whatsapp':
        return whatsappColor;
      case 'telegram':
        return telegramColor;
      default:
        return defaultPlatformColor;
    }
  }
}
