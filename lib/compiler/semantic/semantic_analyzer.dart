import 'package:dry/compiler/models/analyzer.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';

// unused parameter
// undecleared symbol
// mismatch types
// repeated parameter
class SemanticAnalyzer
    extends Analyzer<List<FunctionDefinition>, IntermediateCode> {
  const SemanticAnalyzer(super.input);

  @override
  IntermediateCode analyze() {
    return const IntermediateCode(functions: {});
  }
}
