import 'package:primal/compiler/lexical/lexical_analyzer.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/scanner/character.dart';
import 'package:primal/compiler/scanner/scanner_analyzer.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/semantic_analyzer.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/compiler/syntactic/syntactic_analyzer.dart';

List<Token> getTokens(String source) {
  final Scanner scanner = Scanner(source);
  final List<Character> characters = scanner.analyze();
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

Runtime getRuntime(String source) {
  final IntermediateCode intermediateCode = getIntermediateCode(source);

  return Runtime(intermediateCode);
}
