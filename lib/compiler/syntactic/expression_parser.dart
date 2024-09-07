import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/lexical/lexical_analyzer.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/utils/list_iterator.dart';

class ExpressionParser {
  final ListIterator<Token> iterator;

  const ExpressionParser(this.iterator);

  Expression expression() => ifExpression();

  Expression ifExpression() {
    if (match([IfToken])) {
      final Token operator = previous;
      consume(OpenParenthesisToken, '(');
      final Expression condition = expression();
      consume(CloseParenthesisToken, ')');
      final Expression ifTrue = expression();
      consume(ElseToken, 'else');
      final Expression ifFalse = expression();

      return CallExpression.fromIf(
        operator: operator,
        condition: condition,
        ifTrue: ifTrue,
        ifFalse: ifFalse,
      );
    } else {
      return equality();
    }
  }

  Expression equality() {
    Expression expression = comparison();

    while (match([NotEqualToken, EqualToken])) {
      final Token operator = previous;
      final Expression right = comparison();

      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  Expression comparison() {
    Expression expression = logic();

    while (match([
      GreaterThanToken,
      GreaterEqualThanToken,
      LessThanToken,
      LessEqualThanToken,
    ])) {
      final Token operator = previous;
      final Expression right = logic();

      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  Expression logic() {
    Expression expression = term();

    while (match([PipeToken, AmpersandToken])) {
      final Token operator = previous;
      final Expression right = term();

      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  Expression term() {
    Expression expression = factor();

    while (match([MinusToken, PlusToken])) {
      final Token operator = previous;
      final Expression right = factor();

      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  Expression factor() {
    Expression expression = unary();

    while (match([ForwardSlashToken, AsteriskToken, PercentToken])) {
      final Token operator = previous;
      final Expression right = unary();

      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  Expression unary() {
    if (match([BangToken, MinusToken])) {
      final Token operator = previous;
      final Expression right = unary();

      if (operator.value == '-') {
        return CallExpression.fromBinaryOperation(
          operator: operator,
          left: NumberExpression(
            NumberToken(Lexeme(value: '0', location: operator.location)),
          ),
          right: right,
        );
      } else {
        return CallExpression.fromUnaryOperation(
          operator: operator,
          expression: right,
        );
      }
    } else {
      return call();
    }
  }

  Expression call() {
    Expression exp = primary();

    if (check(OpenParenthesisToken)) {
      while (match([OpenParenthesisToken])) {
        if ((exp is IdentifierExpression) || (exp is CallExpression)) {
          exp = finishCall(exp);
        } else {
          throw InvalidTokenError(peek);
        }
      }
    } else if (match([OpenBracketToken])) {
      if ((exp is IdentifierExpression) ||
          (exp is CallExpression) ||
          (exp is StringExpression) ||
          (exp is ListExpression) ||
          (exp is MapExpression)) {
        final Token operator = IdentifierToken(Lexeme(
          value: 'element.at',
          location: previous.location,
        ));
        final Expression index = expression();
        consume(CloseBracketToken, ']');
        exp = CallExpression.fromBinaryOperation(
          operator: operator,
          left: exp,
          right: index,
        );
      } else {
        throw InvalidTokenError(peek);
      }
    }

    return exp;
  }

  Expression finishCall(Expression callee) {
    final List<Expression> arguments = [];

    if (!check(CloseParenthesisToken)) {
      do {
        arguments.add(expression());
      } while (match([CommaToken]));
    }

    consume(CloseParenthesisToken, ')');

    return CallExpression(callee: callee, arguments: arguments);
  }

  Expression primary() {
    if (match([BooleanToken])) {
      return BooleanExpression(previous);
    } else if (match([NumberToken])) {
      return NumberExpression(previous);
    } else if (match([StringToken])) {
      return StringExpression(previous);
    } else if (match([IdentifierToken])) {
      return IdentifierExpression(previous);
    } else if (match([OpenParenthesisToken])) {
      final Expression expr = expression();
      consume(CloseParenthesisToken, ')');
      return expr;
    } else if (match([OpenBracketToken])) {
      return list(previous);
    } else if (match([OpenBracesToken])) {
      return map(previous);
    }

    throw InvalidTokenError(peek);
  }

  Expression list(Token token) {
    final List<Expression> elements = [];

    if (!check(CloseBracketToken)) {
      do {
        elements.add(expression());
      } while (match([CommaToken]));
    }

    consume(CloseBracketToken, ']');

    return ListExpression(
      location: token.location,
      value: elements,
    );
  }

  Expression map(Token token) {
    final Map<Expression, Expression> pairs = {};

    if (!check(CloseBracesToken)) {
      do {
        final Expression key = expression();
        consume(ColonToken, ':');
        final Expression value = expression();
        pairs[key] = value;
      } while (match([CommaToken]));
    }

    consume(CloseBracesToken, '}');

    return MapExpression(
      location: token.location,
      value: pairs,
    );
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
