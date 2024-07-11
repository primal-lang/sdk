import 'package:dry/compiler/semantic/bytecode.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';

class SemanticAnalyzer {
  final List<FunctionDefinition> functions;

  const SemanticAnalyzer({required this.functions});

  ByteCode analyze() {
    return const ByteCode(functions: {});
  }
}
