import 'dart:io';
import 'package:dry/compiler/lexical_analyzer.dart';
import 'package:dry/compiler/semantic_analyzer.dart';
import 'package:dry/compiler/syntactic_analyzer.dart';
import 'package:dry/models/bytecode.dart';
import 'package:dry/models/function_definition.dart';
import 'package:dry/models/token.dart';

class Compiler {
  final String source;

  const Compiler._(this.source);

  ByteCode compile() {
    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(source: source);
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
