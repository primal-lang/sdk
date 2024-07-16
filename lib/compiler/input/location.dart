class Location {
  final int row;
  final int column;

  const Location({
    required this.row,
    required this.column,
  });

  @override
  String toString() => '[$row, $column]';
}
