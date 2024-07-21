import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/syntactic/syntactic_analyzer.dart';

class SyntacticError implements Exception {
  final String message;

  const SyntacticError(this.message);

  factory SyntacticError.invalidToken(Token token) =>
      SyntacticError('Invalid token $token');

  factory SyntacticError.invalidStackElement(StackElement element) =>
      SyntacticError('Expression malfored at ${element.location}');

  factory SyntacticError.unexpectedEndOfFile() =>
      const SyntacticError('Unexpected end of file');

  @override
  String toString() => message;
}
