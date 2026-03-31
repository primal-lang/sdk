class Location {
  final int row;
  final int column;

  const Location({
    required this.row,
    required this.column,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location && row == other.row && column == other.column;

  @override
  int get hashCode => Object.hash(row, column);

  @override
  String toString() => '[$row, $column]';
}

class Localized {
  final Location location;

  const Localized({required this.location});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Localized && location == other.location;

  @override
  int get hashCode => location.hashCode;
}
