import 'package:primal/compiler/lexical/lexical_analyzer.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/scanner/character.dart';
import 'package:primal/compiler/scanner/scanner.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/semantic_analyzer.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/expression_parser.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/compiler/syntactic/syntactic_analyzer.dart';
import 'package:primal/utils/list_iterator.dart';

class Compiler {
  const Compiler();

  IntermediateCode compile(String input) {
    final Scanner scanner = Scanner(input);
    final List<Character> characters = scanner.analyze();

    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);
    final List<Token> tokens = lexicalAnalyzer.analyze();

    final SyntacticAnalyzer syntacticAnalyzer = SyntacticAnalyzer(tokens);
    final List<FunctionDefinition> functions = syntacticAnalyzer.analyze();

    final SemanticAnalyzer semanticAnalyzer = SemanticAnalyzer(functions);

    return semanticAnalyzer.analyze();
  }

  Expression expression(String input) {
    final Scanner scanner = Scanner(input);
    final List<Character> characters = scanner.analyze();

    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);
    final List<Token> tokens = lexicalAnalyzer.analyze();

    final ExpressionParser expressionParser =
        ExpressionParser(ListIterator(tokens));

    return expressionParser.expression();
  }
}
