import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/syntactic/expression_parser.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:dry/utils/list_iterator.dart';

class FunctionDeclaration {
  final String name;
  final List<String> parameters;
  final List<Token> body;

  const FunctionDeclaration({
    required this.name,
    required this.parameters,
    required this.body,
  });

  FunctionDefinition get definition {
    final ListIterator<Token> iterator = ListIterator(body);
    final ExpressionParser parser = ExpressionParser(iterator);

    return FunctionDefinition(
      name: name,
      parameters: parameters,
      expression: parser.expression,
    );
  }

  FunctionDeclaration withParameter(String parameter) => FunctionDeclaration(
        name: name,
        parameters: [...parameters, parameter],
        body: body,
      );

  FunctionDeclaration withBody(Token token) => FunctionDeclaration(
        name: name,
        parameters: parameters,
        body: [...body, token],
      );

  factory FunctionDeclaration.withName(String name) => FunctionDeclaration(
        name: name,
        parameters: [],
        body: [],
      );
}
