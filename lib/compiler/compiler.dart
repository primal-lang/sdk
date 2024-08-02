import 'package:purified/compiler/input/character.dart';
import 'package:purified/compiler/input/input_analyzer.dart';
import 'package:purified/compiler/lexical/lexical_analyzer.dart';
import 'package:purified/compiler/lexical/token.dart';
import 'package:purified/compiler/semantic/intermediate_code.dart';
import 'package:purified/compiler/semantic/semantic_analyzer.dart';
import 'package:purified/compiler/syntactic/expression.dart';
import 'package:purified/compiler/syntactic/function_definition.dart';
import 'package:purified/compiler/syntactic/syntactic_analyzer.dart';

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
