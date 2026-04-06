import 'package:primal/compiler/lexical/lexical_analyzer.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/reader/character.dart';
import 'package:primal/compiler/reader/source_reader.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/semantic/semantic_analyzer.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/expression_parser.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/compiler/syntactic/syntactic_analyzer.dart';
import 'package:primal/utils/list_iterator.dart';

class Compiler {
  const Compiler();

  IntermediateRepresentation compile(String input) {
    final SourceReader reader = SourceReader(input);
    final List<Character> characters = reader.analyze();

    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);
    final List<Token> tokens = lexicalAnalyzer.analyze();

    final SyntacticAnalyzer syntacticAnalyzer = SyntacticAnalyzer(tokens);
    final List<FunctionDefinition> functions = syntacticAnalyzer.analyze();

    final SemanticAnalyzer semanticAnalyzer = SemanticAnalyzer(functions);

    return semanticAnalyzer.analyze();
  }

  Expression expression(String input) {
    final SourceReader reader = SourceReader(input);
    final List<Character> characters = reader.analyze();

    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);
    final List<Token> tokens = lexicalAnalyzer.analyze();

    final ExpressionParser expressionParser = ExpressionParser(
      ListIterator(tokens),
    );

    return expressionParser.expression();
  }

  /// Tries to parse the input as a single function definition.
  ///
  /// Returns the [FunctionDefinition] if successful, or null if the input
  /// is not a valid function definition (e.g., it's an expression).
  FunctionDefinition? functionDefinition(String input) {
    try {
      final SourceReader reader = SourceReader(input);
      final List<Character> characters = reader.analyze();

      final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);
      final List<Token> tokens = lexicalAnalyzer.analyze();

      final SyntacticAnalyzer syntacticAnalyzer = SyntacticAnalyzer(tokens);
      final List<FunctionDefinition> functions = syntacticAnalyzer.analyze();

      // Must be exactly one function definition
      if (functions.length == 1) {
        return functions.first;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
