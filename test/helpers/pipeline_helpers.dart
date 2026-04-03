import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/lexical/lexical_analyzer.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/reader/character.dart';
import 'package:primal/compiler/reader/source_reader.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/runtime_facade.dart';
import 'package:primal/compiler/semantic/semantic_analyzer.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/compiler/syntactic/syntactic_analyzer.dart';

List<Token> getTokens(String source) {
  final SourceReader reader = SourceReader(source);
  final List<Character> characters = reader.analyze();
  final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);

  return lexicalAnalyzer.analyze();
}

List<Token> getTokensDirect(String source) {
  final List<Character> characters = [];
  for (int i = 0; i < source.length; i++) {
    characters.add(
      Character(
        value: source[i],
        location: Location(row: 1, column: i + 1),
      ),
    );
  }
  final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);

  return lexicalAnalyzer.analyze();
}

List<FunctionDefinition> getFunctions(String source) {
  final List<Token> tokens = getTokens(source);
  final SyntacticAnalyzer syntacticAnalyzer = SyntacticAnalyzer(tokens);

  return syntacticAnalyzer.analyze();
}

IntermediateCode getIntermediateCode(String source) {
  final List<FunctionDefinition> functions = getFunctions(source);
  final SemanticAnalyzer semanticAnalyzer = SemanticAnalyzer(functions);

  return semanticAnalyzer.analyze();
}

RuntimeFacade getRuntime(String source) {
  final IntermediateCode intermediateCode = getIntermediateCode(source);

  return RuntimeFacade(intermediateCode);
}

Expression getExpression(String source) {
  const Compiler compiler = Compiler();

  return compiler.expression(source);
}
