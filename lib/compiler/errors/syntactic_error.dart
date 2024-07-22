import 'package:dry/compiler/errors/generic_error.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/syntactic/syntactic_analyzer.dart';

class SyntacticError extends GenericError {
  const SyntacticError(super.message);
}

class InvalidTokenError extends GenericError {
  const InvalidTokenError(Token token) : super('Invalid token $token');
}

class InvalidStackElementError extends GenericError {
  InvalidStackElementError(StackElement element)
      : super('Expression malfored at ${element.location}');
}

class UnexpectedEndOfFileError extends GenericError {
  const UnexpectedEndOfFileError() : super('Unexpected end of file');
}
