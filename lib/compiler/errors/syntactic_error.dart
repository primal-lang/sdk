import 'package:dry/compiler/errors/generic_error.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/syntactic/syntactic_analyzer.dart';

class SyntacticError extends GenericError {
  const SyntacticError(super.message);

  factory SyntacticError.invalidToken(Token token) =>
      SyntacticError('Invalid token $token');

  factory SyntacticError.invalidStackElement(StackElement element) =>
      SyntacticError('Expression malfored at ${element.location}');

  factory SyntacticError.unexpectedEndOfFile() =>
      const SyntacticError('Unexpected end of file');
}
