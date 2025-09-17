// Widget size enumeration for iOS home screen widgets.
// Defines available widget sizes with their dimensions.

enum WidgetSize {
  small(width: 2, height: 2),
  medium(width: 4, height: 2),
  large(width: 4, height: 4),
  extraLarge(width: 8, height: 4);

  const WidgetSize({
    required this.width,
    required this.height,
  });

  final int width;
  final int height;

  bool get isSmall => this == WidgetSize.small;
  bool get isMedium => this == WidgetSize.medium;
  bool get isLarge => this == WidgetSize.large;
  bool get isExtraLarge => this == WidgetSize.extraLarge;

  /// Returns true if this size can display detailed information
  bool get canShowDetails => width >= 4;

  /// Returns true if this size can display streak information
  bool get canShowStreak => this != WidgetSize.small;
}
