import 'package:primal/compiler/lexical/token.dart';

class Parser {
  final List<Token> tokens;

  const Parser(this.tokens);

  /*ParseExpression analyze() => equality();

  ParseExpression equality() {
    ParseExpression expr = comparison();

    while (match(BANG_EQUAL, EQUAL_EQUAL)) {
      Token operator = previous();
      ParseExpression right = comparison();
      expr = BinaryExpression(expr, operator, right);
    }

    return expr;
  }

  ParseExpression comparison() {
    ParseExpression expr = term();

    while (match(GREATER, GREATER_EQUAL, LESS, LESS_EQUAL)) {
      Token operator = previous();
      Expr right = term();
      expr = new Expr.Binary(expr, operator, right);
    }

    return expr;
  }

  ParseExpression term() {
    ParseExpression expr = factor();

    while (match(MINUS, PLUS)) {
      Token operator = previous();
      Expr right = factor();
      expr = new Expr.Binary(expr, operator, right);
    }

    return expr;
  }

  ParseExpression factor() {
    ParseExpression expr = unary();

    while (match(SLASH, STAR)) {
      Token operator = previous();
      Expr right = unary();
      expr = new Expr.Binary(expr, operator, right);
    }

    return expr;
  }

  ParseExpression unary() {
    if (match(BANG, MINUS)) {
      Token operator = previous();
      Expr right = unary();
      return new Expr.Unary(operator, right);
    }

    return primary();
  }

  ParseExpression primary() {
    if (match(FALSE)) return new Expr.Literal(false);
    if (match(TRUE)) return new Expr.Literal(true);
    if (match(NIL)) return new Expr.Literal(null);

    if (match(NUMBER, STRING)) {
      return new Expr.Literal(previous().literal);
    }

    if (match(LEFT_PAREN)) {
      Expr expr = expression();
      consume(RIGHT_PAREN, "Expect ')' after expression.");
      return new Expr.Grouping(expr);
    }
  }

  bool match(List<TokenType> types) {
    for (TokenType type in types) {
      if (check(type)) {
        advance();
        return true;
      }
    }

    return false;
  }

  bool check(TokenType type) {
    if (isAtEnd()) {
      return false;
    } else {
      return peek().type == type;
    }
  }

  Token advance() {
    if (!isAtEnd()) {
      current++;
    } else {
      return previous();
    }
  }

  bool isAtEnd() => peek().type == EOF;

  Token peek() => tokens.get(current);

  Token previous() => tokens.get(current - 1);*/
}

class ParseExpression {
  const ParseExpression();
}

class BinaryExpression extends ParseExpression {
  final ParseExpression left;
  final Operator operator;
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
