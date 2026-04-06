import 'package:primal/compiler/models/location.dart';

class Located {
  final Location location;

  const Located({required this.location});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Located && location == other.location;

  @override
  int get hashCode => location.hashCode;
}
