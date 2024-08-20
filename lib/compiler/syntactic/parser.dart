import 'package:primal/compiler/lexical/token.dart';

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
      return BooleanLiteralExpression(previous().value);
    } else if (match([NumberToken])) {
      return NumberLiteralExpression(previous().value);
    } else if (match([StringToken])) {
      return StringLiteralExpression(previous().value);
    } else if (match([IdentifierToken])) {
      return IdentifierExpression(previous().value);
    }

    if (match([OpenParenthesisToken])) {
      final ParseExpression expr = expression();
      consume(CloseParenthesisToken);
      return GroupExpression(expr);
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

abstract class ParseExpression {
  const ParseExpression();

  String get text;
}

class BooleanLiteralExpression extends ParseExpression {
  final bool value;

  const BooleanLiteralExpression(this.value);

  @override
  String get text => value.toString();
}

class NumberLiteralExpression extends ParseExpression {
  final num value;

  const NumberLiteralExpression(this.value);

  @override
  String get text => value.toString();
}

class StringLiteralExpression extends ParseExpression {
  final String value;

  const StringLiteralExpression(this.value);

  @override
  String get text => '"$value"';
}

class IdentifierExpression extends ParseExpression {
  final String value;

  const IdentifierExpression(this.value);

  @override
  String get text => value;
}

class GroupExpression extends ParseExpression {
  final ParseExpression expression;

  const GroupExpression(this.expression);

  @override
  String get text => expression.text;
}

class UnaryExpression extends ParseExpression {
  final Token operator;
  final ParseExpression expression;

  const UnaryExpression(this.operator, this.expression);

  @override
  String get text => '(${operator.value}${expression.text})';
}

class BinaryExpression extends ParseExpression {
  final ParseExpression left;
  final Token operator;
  final ParseExpression right;

  const BinaryExpression(this.left, this.operator, this.right);

  @override
  String get text => '(${left.text} ${operator.value} ${right.text})';
}

class CallExpression extends ParseExpression {
  final ParseExpression calle;
  final List<ParseExpression> arguments;

  const CallExpression(this.calle, this.arguments);

  @override
  String get text =>
      '${calle.text}(${arguments.map((e) => e.text).join(', ')})';
}
