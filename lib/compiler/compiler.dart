import 'package:primal/compiler/input/character.dart';
import 'package:primal/compiler/input/input_analyzer.dart';
import 'package:primal/compiler/lexical/lexical_analyzer.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/semantic_analyzer.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/compiler/syntactic/syntactic_analyzer.dart';

class Compiler {
  const Compiler();

  IntermediateCode compile(String input) {
    final InputAnalyzer inputAnalyzer = InputAnalyzer(input);
    final List<Character> characters = inputAnalyzer.analyze();

    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);
    final List<Token> tokens = lexicalAnalyzer.analyze();

    final SyntacticAnalyzer syntacticAnalyzer = SyntacticAnalyzer(tokens);
    final List<FunctionDefinition> functions = syntacticAnalyzer.analyze();

    final SemanticAnalyzer semanticAnalyzer = SemanticAnalyzer(functions);

    return semanticAnalyzer.analyze();
  }

  Expression expression(String input) {
    final InputAnalyzer inputAnalyzer = InputAnalyzer(input);
    final List<Character> characters = inputAnalyzer.analyze();

    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);
    final List<Token> tokens = lexicalAnalyzer.analyze();

    final SyntacticAnalyzer syntacticAnalyzer = SyntacticAnalyzer(tokens);

    return syntacticAnalyzer.expression;
  }
}
