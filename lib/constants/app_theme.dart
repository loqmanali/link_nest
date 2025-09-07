import 'package:flutter/material.dart';

class AppTheme {
  // Shadcn UI inspired colors with LinkedIn primary
  static const Color primaryColor = Color(0xFF0077B5); // LinkedIn Blue
  static const Color primaryForeground = Color(0xFFFFFFFF); // white
  static const Color secondaryColor = Color(0xFF0A66C2); // LinkedIn secondary
  static const Color secondaryForeground = Color(0xFFFFFFFF); // white
  static const Color accentColor = Color(0xFF22C55E); // emerald-500
  static const Color accentForeground = Color(0xFFFFFFFF); // white
  static const Color mutedColor = Color(0xFFF3F4F6); // gray-100
  static const Color mutedForeground = Color(0xFF6B7280); // gray-500
  static const Color cardColor = Color(0xFFFFFFFF); // white
  static const Color cardForeground = Color(0xFF0F172A); // slate-900
  static const Color popoverColor = Color(0xFFFFFFFF); // white
  static const Color popoverForeground = Color(0xFF0F172A); // slate-900
  static const Color borderColor = Color(0xFFE5E7EB); // gray-200
  static const Color inputColor = Color(0xFFE5E7EB); // gray-200
  static const Color ringColor = Color(0xFF0077B5); // LinkedIn Blue
  static const Color backgroundColor = Color(0xFFF8FAFC); // slate-50
  static const Color foregroundColor = Color(0xFF0F172A); // slate-900
  static const Color destructiveColor = Color(0xFFEF4444); // red-500
  static const Color destructiveForeground = Color(0xFFFEF2F2); // red-50

  // LinkedIn brand color for special cases
  static const Color linkedinColor = Color(0xFF0077B5);

  // Shadcn UI shadows
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // Surface colors
  static const Color surfaceColor = Color(0xFFF8FAFC); // slate-50
  static const Color surfaceVariant = Color(0xFFF1F5F9); // slate-100
  static const Color errorColor = Color(0xFFEF4444); // red-500

  // Text colors following Shadcn principles
  static const Color primaryTextColor = Color(0xFF0F172A); // slate-900
  static const Color secondaryTextColor = Color(0xFF475569); // slate-600
  static const Color lightTextColor = Color(0xFF64748B); // slate-500

  // Priority colors
  static const Color highPriorityColor = Color(0xFFE51937); // Red
  static const Color mediumPriorityColor = Color(0xFFF5A623); // Orange
  static const Color lowPriorityColor = Color(0xFF7BBC65); // Green

  // Post type colors - updated with modern palette
  static const Color jobColor = Color(0xFF0EA5E9); // sky-500
  static const Color articleColor = Color(0xFF06B6D4); // cyan-500
  static const Color tipColor = Color(0xFF10B981); // emerald-500
  static const Color opportunityColor = Color(0xFFF59E0B); // amber-500
  static const Color otherColor = Color(0xFF6B7280); // gray-500

  // Platform colors
  static const Color twitterColor = Color(0xFF1DA1F2); // Twitter blue
  static const Color facebookColor = Color(0xFF1877F2); // Facebook blue
  static const Color instagramColor = Color(0xFFE4405F); // Instagram pink/red
  static const Color youtubeColor = Color(0xFFFF0000); // YouTube red
  static const Color githubColor = Color(0xFF333333); // GitHub dark
  static const Color mediumColor = Color(0xFF00AB6C); // Medium green
  static const Color redditColor = Color(0xFFFF4500); // Reddit orange
  static const Color whatsappColor = Color(0xFF25D366); // WhatsApp green
  static const Color telegramColor = Color(0xFF0088CC); // Telegram blue
  static const Color defaultPlatformColor = Color(0xFF9E9E9E); // Default gray

  // Spacing following Shadcn principles
  static const double spacing1 = 4.0; // 0.25rem
  static const double spacing2 = 8.0; // 0.5rem
  static const double spacing3 = 12.0; // 0.75rem
  static const double spacing4 = 16.0; // 1rem
  static const double spacing5 = 20.0; // 1.25rem
  static const double spacing6 = 24.0; // 1.5rem
  static const double spacing8 = 32.0; // 2rem
  static const double spacing10 = 40.0; // 2.5rem
  static const double spacing12 = 48.0; // 3rem

  // Legacy padding (keeping for compatibility)
  static const double smallPadding = spacing2;
  static const double defaultPadding = spacing4;
  static const double largePadding = spacing6;

  // Border radius following Shadcn principles
  static const double radiusXs = 2.0; // 0.125rem
  static const double radiusSm = 4.0; // 0.25rem
  static const double radiusMd = 6.0; // 0.375rem
  static const double radiusLg = 8.0; // 0.5rem
  static const double radiusXl = 12.0; // 0.75rem
  static const double radius2xl = 16.0; // 1rem
  static const double radius3xl = 24.0; // 1.5rem

  // Legacy border radius (keeping for compatibility)
  static const double borderRadius = radiusLg;
  static const double largeBorderRadius = radius2xl;

  // Light theme following Shadcn UI principles
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: accentColor,
      onPrimary: accentForeground,
      secondary: secondaryColor,
      onSecondary: secondaryForeground,
      surface: cardColor,
      onSurface: cardForeground,
      error: destructiveColor,
      onError: destructiveForeground,
      outline: borderColor,
    ),
    scaffoldBackgroundColor: surfaceColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: cardColor,
      foregroundColor: cardForeground,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black12,
      titleTextStyle: TextStyle(
        color: cardForeground,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.025,
      ),
    ),
    textTheme: const TextTheme(
      // Display styles
      displayLarge: TextStyle(
        color: foregroundColor,
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.025,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        color: foregroundColor,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.025,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        color: foregroundColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.025,
        height: 1.2,
      ),
      // Headline styles
      headlineLarge: TextStyle(
        color: foregroundColor,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.025,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        color: foregroundColor,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.025,
        height: 1.25,
      ),
      headlineSmall: TextStyle(
        color: foregroundColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.025,
        height: 1.25,
      ),
      // Title styles
      titleLarge: TextStyle(
        color: foregroundColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.025,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        color: foregroundColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.025,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        color: foregroundColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.025,
        height: 1.4,
      ),
      // Body styles
      bodyLarge: TextStyle(
        color: foregroundColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: mutedForeground,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: mutedForeground,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      // Label styles
      labelLarge: TextStyle(
        color: foregroundColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        color: mutedForeground,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.3,
      ),
      labelSmall: TextStyle(
        color: mutedForeground,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.3,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: accentForeground,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing4,
          vertical: spacing3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.025,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: accentForeground,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing4,
          vertical: spacing3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: const BorderSide(color: borderColor),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing4,
          vertical: spacing3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: ringColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: destructiveColor),
      ),
      contentPadding: const EdgeInsets.all(spacing3),
      hintStyle: const TextStyle(color: mutedForeground),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
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
