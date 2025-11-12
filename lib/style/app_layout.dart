import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Platform-aware spacing and sizing constants
/// Follows Material Design guidelines for Android and iOS Human Interface Guidelines
class AppLayout {
  AppLayout._();

  // Platform-specific button heights
  static const double materialButtonHeight = kMinInteractiveDimension; // 48.0
  static const double cupertinoButtonHeight =
      kMinInteractiveDimensionCupertino; // 44.0

  /// Get the standard button height for the current platform
  static double buttonHeight(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? cupertinoButtonHeight
        : materialButtonHeight;
  }

  // Material Design spacing scale (8dp grid)
  static const double materialSpacingSmall = 8.0;
  static const double materialSpacingMedium = 16.0;
  static const double materialSpacingLarge = 24.0;
  static const double materialSpacingXLarge = 32.0;

  // iOS spacing scale (8pt grid)
  static const double iosSpacingSmall = 8.0;
  static const double iosSpacingMedium = 16.0;
  static const double iosSpacingLarge = 20.0;
  static const double iosSpacingXLarge = 32.0;

  /// Get platform-appropriate small spacing
  static double spacingSmall(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? iosSpacingSmall
        : materialSpacingSmall;
  }

  /// Get platform-appropriate medium spacing
  static double spacingMedium(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? iosSpacingMedium
        : materialSpacingMedium;
  }

  /// Get platform-appropriate large spacing
  static double spacingLarge(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? iosSpacingLarge
        : materialSpacingLarge;
  }

  /// Get platform-appropriate extra large spacing
  static double spacingXLarge(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? iosSpacingXLarge
        : materialSpacingXLarge;
  }

  /// Get vertical padding based on orientation and platform
  static double verticalPadding(BuildContext context, bool isLandscape) {
    if (isLandscape) {
      return spacingMedium(context);
    } else {
      return spacingXLarge(context);
    }
  }

  /// Get horizontal padding based on orientation and platform
  static double horizontalPadding(BuildContext context, bool isLandscape) {
    if (isLandscape) {
      // Larger screens in landscape get more horizontal padding
      return Theme.of(context).platform == TargetPlatform.iOS ? 48.0 : 48.0;
    } else {
      return spacingXLarge(context);
    }
  }

  /// Get responsive padding that scales with text size for accessibility
  static double accessiblePadding(BuildContext context, double baseSize) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    // Clamp to reasonable limits so UI doesn't break with extreme text sizes
    return baseSize * textScaleFactor.clamp(1.0, 1.5);
  }

  /// Standard content padding (respects safe area)
  static EdgeInsets contentPadding(BuildContext context) {
    return EdgeInsets.all(spacingMedium(context));
  }

  /// Card padding
  static EdgeInsets cardPadding(BuildContext context) {
    return EdgeInsets.all(spacingMedium(context));
  }

  /// List item padding
  static EdgeInsets listItemPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: spacingMedium(context),
      vertical: spacingSmall(context),
    );
  }
}
