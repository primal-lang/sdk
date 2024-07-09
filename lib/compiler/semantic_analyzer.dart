import 'package:dry/models/abstract_syntax_tree.dart';
import 'package:dry/models/bytecode.dart';

class SemanticAnalyzer {
  final AbstractSyntaxTree ast;

  const SemanticAnalyzer({required this.ast});

  ByteCode analyze() {
    return const ByteCode(functions: {});
  }
}
