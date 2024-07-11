import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/syntactic/type.dart';

class FunctionDefinition {
  final String name;
  final List<FunctionParameter> parameters;
  final Expression body;

  const FunctionDefinition({
    required this.name,
    required this.parameters,
    required this.body,
  });
}

class FunctionParameter {
  final Type type;
  final String name;

  const FunctionParameter({
    required this.type,
    required this.name,
  });
}
