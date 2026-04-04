import 'package:primal/compiler/models/located.dart';

class Character extends Located {
  final String value;

  const Character({
    required this.value,
    required super.location,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Character && value == other.value && location == other.location;

  @override
  int get hashCode => Object.hash(value, location);

  @override
  String toString() => '"$value" at $location';
}
