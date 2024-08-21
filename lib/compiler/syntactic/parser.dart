import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/utils/list_iterator.dart';

class Parser {
  final ListIterator<Token> iterator;

  Parser(this.iterator);

  ParseExpression expression() => equality();

  ParseExpression equality() {
    ParseExpression expression = comparison();

    while (match([NotEqualToken, EqualToken])) {
      final Token operator = previous;
      final ParseExpression right = comparison();
      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  ParseExpression comparison() {
    ParseExpression expression = logic();

    while (match([
      GreaterThanToken,
      GreaterEqualThanToken,
      LessThanToken,
      LessEqualThanToken,
    ])) {
      final Token operator = previous;
      final ParseExpression right = logic();
      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  ParseExpression logic() {
    ParseExpression expression = term();

    while (match([PipeToken, AmpersandToken])) {
      final Token operator = previous;
      final ParseExpression right = term();
      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  ParseExpression term() {
    ParseExpression expression = factor();

    while (match([MinusToken, PlusToken])) {
      final Token operator = previous;
      final ParseExpression right = factor();
      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  ParseExpression factor() {
    ParseExpression expression = unary();

    while (match([ForwardSlashToken, AsteriskToken, PercentToken])) {
      final Token operator = previous;
      final ParseExpression right = unary();
      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  ParseExpression unary() {
    if (match([BangToken, MinusToken])) {
      final Token operator = previous;
      final ParseExpression right = unary();
      return CallExpression.fromUnaryOperation(
        operator: operator,
        expression: right,
      );
    }

    return call();
  }

  ParseExpression call() {
    ParseExpression expression = primary();

    while (true) {
      if (match([OpenParenthesisToken])) {
        if ((expression is IdentifierExpression) ||
            (expression is CallExpression)) {
          expression = finishCall(expression);
        } else {
          throw InvalidTokenError(peek);
        }
      } else {
        break;
      }
    }

    return expression;
  }

  ParseExpression finishCall(ParseExpression callee) {
    final List<ParseExpression> arguments = [];

    if (!check(CloseParenthesisToken)) {
      do {
        arguments.add(expression());
      } while (match([CommaToken]));
    }

    consume(CloseParenthesisToken, ')');

    return CallExpression(callee, arguments);
  }

  ParseExpression primary() {
    if (match([BooleanToken])) {
      return BooleanLiteralExpression(previous);
    } else if (match([NumberToken])) {
      return NumberLiteralExpression(previous);
    } else if (match([StringToken])) {
      return StringLiteralExpression(previous);
    } else if (match([IdentifierToken])) {
      return IdentifierExpression(previous);
    }

    if (match([OpenParenthesisToken])) {
      final ParseExpression expr = expression();
      consume(CloseParenthesisToken, ')');
      return expr;
    }

    throw InvalidTokenError(peek);
  }

  bool match(List<Type> types) {
    for (final Type type in types) {
      if (check(type)) {
        advance();
        return true;
      }
    }

    return false;
  }

  bool check(Type type) {
    if (iterator.isAtEnd) {
      return false;
    } else {
      return peek.runtimeType == type;
    }
  }

  Token consume(Type type, String expected) {
    if (check(type)) {
      return advance();
    }

    throw ExpectedTokenError(peek, expected);
  }

  Token advance() {
    if (!iterator.isAtEnd) {
      iterator.advance();
    }

    return previous;
  }

  Token get peek => iterator.peek!;

  Token get previous => iterator.previous!;
}

abstract class ParseExpression extends Localized {
  const ParseExpression({required super.location});
}

abstract class LiteralExpression<T> extends ParseExpression {
  final T value;

  const LiteralExpression({
    required super.location,
    required this.value,
  });

  @override
  String toString() => value.toString();
}

class BooleanLiteralExpression extends LiteralExpression<bool> {
  BooleanLiteralExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );
}

class NumberLiteralExpression extends LiteralExpression<num> {
  NumberLiteralExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );
}

class StringLiteralExpression extends LiteralExpression<String> {
  StringLiteralExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  String toString() => '"$value"';
}

class IdentifierExpression extends ParseExpression {
  final String value;

  IdentifierExpression(Token token)
      : value = token.value,
        super(location: token.location);

  @override
  String toString() => value;
}

class CallExpression extends ParseExpression {
  final ParseExpression calle;
  final List<ParseExpression> arguments;

  CallExpression(this.calle, this.arguments) : super(location: calle.location);

  factory CallExpression.fromUnaryOperation({
    required Token operator,
    required ParseExpression expression,
  }) =>
      CallExpression(IdentifierExpression(operator), [expression]);

  factory CallExpression.fromBinaryOperation({
    required Token operator,
    required ParseExpression left,
    required ParseExpression right,
  }) =>
      CallExpression(IdentifierExpression(operator), [left, right]);

  @override
  String toString() => '$calle(${arguments.join(', ')})';
}
