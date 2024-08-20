import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';

class Parser {
  final List<Token> tokens;
  int current = 0;

  Parser(this.tokens);

  ParseExpression expression() => equality();

  ParseExpression equality() {
    ParseExpression expr = comparison();

    while (match([NotEqualToken, EqualToken])) {
      final Token operator = previous();
      final ParseExpression right = comparison();
      expr = BinaryExpression(expr, operator, right);
    }

    return expr;
  }

  ParseExpression comparison() {
    ParseExpression expr = logic();

    while (match([
      GreaterThanToken,
      GreaterEqualThanToken,
      LessThanToken,
      LessEqualThanToken,
    ])) {
      final Token operator = previous();
      final ParseExpression right = logic();
      expr = BinaryExpression(expr, operator, right);
    }

    return expr;
  }

  ParseExpression logic() {
    ParseExpression expr = term();

    while (match([PipeToken, AmpersandToken])) {
      final Token operator = previous();
      final ParseExpression right = term();
      expr = BinaryExpression(expr, operator, right);
    }

    return expr;
  }

  ParseExpression term() {
    ParseExpression expr = factor();

    while (match([MinusToken, PlusToken])) {
      final Token operator = previous();
      final ParseExpression right = factor();
      expr = BinaryExpression(expr, operator, right);
    }

    return expr;
  }

  ParseExpression factor() {
    ParseExpression expr = unary();

    while (match([ForwardSlashToken, AsteriskToken, PercentToken])) {
      final Token operator = previous();
      final ParseExpression right = unary();
      expr = BinaryExpression(expr, operator, right);
    }

    return expr;
  }

  ParseExpression unary() {
    if (match([BangToken, MinusToken])) {
      final Token operator = previous();
      final ParseExpression right = unary();
      return UnaryExpression(operator, right);
    }

    return call();
  }

  ParseExpression call() {
    ParseExpression expr = primary();

    while (true) {
      if (match([OpenParenthesisToken])) {
        expr = finishCall(expr);
      } else {
        break;
      }
    }

    return expr;
  }

  ParseExpression finishCall(ParseExpression callee) {
    final List<ParseExpression> arguments = [];

    if (!check(CloseParenthesisToken)) {
      do {
        arguments.add(expression());
      } while (match([CommaToken]));
    }

    consume(CloseParenthesisToken);

    return CallExpression(callee, arguments);
  }

  ParseExpression primary() {
    if (match([
      BooleanToken,
    ])) {
      return BooleanLiteralExpression(previous());
    } else if (match([NumberToken])) {
      return NumberLiteralExpression(previous());
    } else if (match([StringToken])) {
      return StringLiteralExpression(previous());
    } else if (match([IdentifierToken])) {
      return IdentifierExpression(previous());
    }

    if (match([OpenParenthesisToken])) {
      final ParseExpression expr = expression();
      consume(CloseParenthesisToken);
      return expr;
    }

    throw Exception();
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
    if (isAtEnd()) {
      return false;
    } else {
      return peek().runtimeType == type;
    }
  }

  Token advance() {
    if (!isAtEnd()) {
      current++;
    }

    return previous();
  }

  Token consume(Type type) {
    if (check(type)) {
      return advance();
    }

    throw Exception();
  }

  bool isAtEnd() => current == tokens.length;

  Token peek() => tokens[current];

  Token previous() => tokens[current - 1];
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

class UnaryExpression extends ParseExpression {
  final Token operator;
  final ParseExpression expression;

  UnaryExpression(this.operator, this.expression)
      : super(location: operator.location);

  @override
  String toString() => '(${operator.value}$expression)';
}

class BinaryExpression extends ParseExpression {
  final ParseExpression left;
  final Token operator;
  final ParseExpression right;

  BinaryExpression(this.left, this.operator, this.right)
      : super(location: operator.location);

  @override
  String toString() => '($left ${operator.value} $right)';
}

class CallExpression extends ParseExpression {
  final ParseExpression calle;
  final List<ParseExpression> arguments;

  CallExpression(this.calle, this.arguments) : super(location: calle.location);

  @override
  String toString() => '$calle(${arguments.join(', ')})';
}
