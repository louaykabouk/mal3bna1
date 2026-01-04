import 'sport_type.dart';

/// Model representing a sport with its display information.
class SportItem {
  final SportType type;
  final String title;
  final String iconPath;

  const SportItem({
    required this.type,
    required this.title,
    required this.iconPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportItem &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}

