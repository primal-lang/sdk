import 'package:dry/models/abstract_syntax_tree.dart';
import 'package:dry/models/token.dart';

class SyntaxAnalyzer {
  final List<Token> tokens;

  const SyntaxAnalyzer({required this.tokens});

  AbstractSyntaxTree analyze() {
    return AbstractSyntaxTree();
  }
}
