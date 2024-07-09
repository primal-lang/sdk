import 'dart:io';
import 'package:dry/compiler/lexical_analyzer.dart';
import 'package:dry/compiler/semantic_analyzer.dart';
import 'package:dry/compiler/syntax_analyzer.dart';
import 'package:dry/models/abstract_syntax_tree.dart';
import 'package:dry/models/bytecode.dart';
import 'package:dry/models/token.dart';

class Compiler {
  final String source;

  const Compiler._(this.source);

  ByteCode compile() {
    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(source: source);
    final List<Token> tokens = lexicalAnalyzer.analyze();

    final SyntaxAnalyzer syntaxAnalyzer = SyntaxAnalyzer(tokens: tokens);
    final AbstractSyntaxTree ast = syntaxAnalyzer.analyze();

    final SemanticAnalyzer semanticAnalyzer = SemanticAnalyzer(ast: ast);
    return semanticAnalyzer.analyze();
  }

  factory Compiler.fromFile(String filePath) {
    final File file = File(filePath);
    final String content = file.readAsStringSync();

    return Compiler._(content);
  }
}
