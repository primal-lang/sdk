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
    ParseExpression expr = term();

    while (match([
      GreaterThanToken,
      GreaterEqualThanToken,
      LessThanToken,
      LessEqualThanToken,
    ])) {
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

    while (match([ForwardSlashToken, AsteriskToken])) {
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

    return primary();
  }

  ParseExpression primary() {
    if (match([BooleanToken, NumberToken, StringToken])) {
      return LiteralExpression(previous().value);
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
      return peek().runtimeType == type.runtimeType;
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

  bool isAtEnd() => current == tokens.length - 1;

  Token peek() => tokens[current];

  Token previous() => tokens[current - 1];
}

class ParseExpression {
  const ParseExpression();
}

class LiteralExpression extends ParseExpression {
  final String value;

  const LiteralExpression(this.value);
}

class GroupExpression extends ParseExpression {
  final ParseExpression expression;

  const GroupExpression(this.expression);
}

class UnaryExpression extends ParseExpression {
  final Token operator;
  final ParseExpression expression;

  const UnaryExpression(this.operator, this.expression);
}

class BinaryExpression extends ParseExpression {
  final ParseExpression left;
  final Token operator;
  final ParseExpression right;

  const BinaryExpression(this.left, this.operator, this.right);
}

enum Operator {
  addition,
  substraction,
  division,
  multiplication,
  equality,
  non_equality;

  static Operator fromToken(Token token) {
    if (token is AssignToken) {
      return equality;
    }

    throw Exception('Invalid operator');
  }
}
