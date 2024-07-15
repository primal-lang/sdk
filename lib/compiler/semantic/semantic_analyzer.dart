import 'package:dry/compiler/models/analyzer.dart';
import 'package:dry/compiler/semantic/bytecode.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';

class SemanticAnalyzer extends Analyzer<List<FunctionDefinition>, ByteCode> {
  const SemanticAnalyzer(super.input);

  @override
  ByteCode analyze() {
    return const ByteCode(functions: {});
  }
}
