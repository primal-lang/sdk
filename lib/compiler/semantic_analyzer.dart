import 'package:dry/models/bytecode.dart';
import 'package:dry/models/function_definition.dart';

class SemanticAnalyzer {
  final List<FunctionDefinition> functions;

  const SemanticAnalyzer({required this.functions});

  ByteCode analyze() {
    return const ByteCode(functions: {});
  }
}
