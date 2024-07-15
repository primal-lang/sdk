import 'dart:io';
import 'package:dry/compiler/input/input_analyzer.dart';
import 'package:dry/compiler/lexical/lexical_analyzer.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/semantic/bytecode.dart';
import 'package:dry/compiler/semantic/semantic_analyzer.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:dry/compiler/syntactic/syntactic_analyzer.dart';

class Compiler {
  final String source;

  const Compiler._(this.source);

  ByteCode compile() {
    final InputAnalyzer inputAnalyzer = InputAnalyzer(source: source);
    final List<Character> characters = inputAnalyzer.analyze();

    final LexicalAnalyzer lexicalAnalyzer =
        LexicalAnalyzer(characters: characters);
    final List<Token> tokens = lexicalAnalyzer.analyze();

    print('Tokens parsed:\n${tokens.join('\n')}');

    final SyntacticAnalyzer syntacticAnalyzer =
        SyntacticAnalyzer(tokens: tokens);
    final List<FunctionDefinition> functions = syntacticAnalyzer.analyze();

    final SemanticAnalyzer semanticAnalyzer =
        SemanticAnalyzer(functions: functions);
    return semanticAnalyzer.analyze();
  }

  factory Compiler.fromFile(String filePath) {
    final File file = File(filePath);
    final String content = file.readAsStringSync();

    return Compiler._(content);
  }
}
