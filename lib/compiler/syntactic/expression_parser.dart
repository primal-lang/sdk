import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/lexical/lexeme.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/utils/list_iterator.dart';

class ExpressionParser {
  final ListIterator<Token> iterator;

  const ExpressionParser(this.iterator);

  Expression expression() => ifExpression();

  Expression ifExpression() {
    if (match([(t) => t is IfToken])) {
      final Token operator = previous;
      consume((t) => t is OpenParenthesisToken, '(');
      final Expression condition = expression();
      consume((t) => t is CloseParenthesisToken, ')');
      final Expression ifTrue = expression();
      consume((t) => t is ElseToken, 'else');
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
    Expression expression = logicOr();

    while (match([(t) => t is NotEqualToken, (t) => t is EqualToken])) {
      final Token operator = previous;
      final Expression right = logicOr();

      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  Expression logicOr() {
    Expression expression = logicAnd();

    while (match([(t) => t is PipeToken])) {
      final Token operator = previous;
      final Expression right = logicAnd();

      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  Expression logicAnd() {
    Expression expression = comparison();

    while (match([(t) => t is AmpersandToken])) {
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
    Expression expression = term();

    while (match([
      (t) => t is GreaterThanToken,
      (t) => t is GreaterEqualThanToken,
      (t) => t is LessThanToken,
      (t) => t is LessEqualThanToken,
    ])) {
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

    while (match([(t) => t is MinusToken, (t) => t is PlusToken])) {
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
    Expression expression = index();

    while (match([
      (t) => t is ForwardSlashToken,
      (t) => t is AsteriskToken,
      (t) => t is PercentToken,
    ])) {
      final Token operator = previous;
      final Expression right = index();

      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  Expression index() {
    Expression expression = unary();

    while (match([(t) => t is AtToken])) {
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
    if (match([(t) => t is BangToken, (t) => t is MinusToken])) {
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

    while (true) {
      if (match([(t) => t is OpenParenthesisToken])) {
        exp = finishCall(exp);
      } else if (match([(t) => t is OpenBracketToken])) {
        final Token operator = AtToken(
          Lexeme(
            value: '@',
            location: previous.location,
          ),
        );
        final Expression idx = expression();
        consume((t) => t is CloseBracketToken, ']');
        exp = CallExpression.fromBinaryOperation(
          operator: operator,
          left: exp,
          right: idx,
        );
      } else {
        break;
      }
    }

    return exp;
  }

  Expression finishCall(Expression callee) {
    final List<Expression> arguments = [];

    if (!check((t) => t is CloseParenthesisToken)) {
      do {
        arguments.add(expression());
      } while (match([(t) => t is CommaToken]));
    }

    consume((t) => t is CloseParenthesisToken, ')');

    return CallExpression(callee: callee, arguments: arguments);
  }

  Expression primary() {
    if (match([(t) => t is BooleanToken])) {
      return BooleanExpression(previous);
    } else if (match([(t) => t is NumberToken])) {
      return NumberExpression(previous);
    } else if (match([(t) => t is StringToken])) {
      return StringExpression(previous);
    } else if (match([(t) => t is IdentifierToken])) {
      return IdentifierExpression(previous);
    } else if (match([(t) => t is OpenParenthesisToken])) {
      final Expression expr = expression();
      consume((t) => t is CloseParenthesisToken, ')');
      return expr;
    } else if (match([(t) => t is OpenBracketToken])) {
      return list(previous);
    } else if (match([(t) => t is OpenBracesToken])) {
      return map(previous);
    }

    throw InvalidTokenError(peek);
  }

  Expression list(Token token) {
    final List<Expression> elements = [];

    if (!check((t) => t is CloseBracketToken)) {
      do {
        elements.add(expression());
      } while (match([(t) => t is CommaToken]));
    }

    consume((t) => t is CloseBracketToken, ']');

    return ListExpression(
      location: token.location,
      value: elements,
    );
  }

  Expression map(Token token) {
    final List<MapEntryExpression> pairs = [];

    if (!check((t) => t is CloseBracesToken)) {
      do {
        final Expression key = expression();
        consume((t) => t is ColonToken, ':');
        final Expression value = expression();
        pairs.add(MapEntryExpression(key: key, value: value));
      } while (match([(t) => t is CommaToken]));
    }

    consume((t) => t is CloseBracesToken, '}');

    return MapExpression(
      location: token.location,
      value: pairs,
    );
  }

  bool match(List<bool Function(Token)> predicates) {
    for (final predicate in predicates) {
      if (check(predicate)) {
        advance();
        return true;
      }
    }

    return false;
  }

  bool check(bool Function(Token) predicate) {
    if (iterator.isAtEnd) {
      return false;
    }

    return predicate(peek);
  }

  Token consume(bool Function(Token) predicate, String expected) {
    if (check(predicate)) {
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

  Token get peek {
    final Token? token = iterator.peek;

    if (token != null) {
      return token;
    } else {
      throw const UnexpectedEndOfFileError();
    }
  }

  Token get previous {
    final Token? token = iterator.previous;
    if (token == null) {
      throw StateError(
        'Attempted to access previous token before any tokens were consumed. '
        'This indicates a bug in the parser.',
      );
    }
    return token;
  }
}
