import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/lexical/lexeme.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/utils/list_iterator.dart';

class ExpressionParser {
  final ListIterator<Token> iterator;

  const ExpressionParser(this.iterator);

  // Static predicates - allocated once
  static bool _isIf(Token t) => t is IfToken;
  static bool _isElse(Token t) => t is ElseToken;
  static bool _isNotEqual(Token t) => t is NotEqualToken;
  static bool _isEqual(Token t) => t is EqualToken;
  static bool _isPipe(Token t) => t is PipeToken;
  static bool _isAmpersand(Token t) => t is AmpersandToken;
  static bool _isGreaterThan(Token t) => t is GreaterThanToken;
  static bool _isGreaterEqualThan(Token t) => t is GreaterEqualThanToken;
  static bool _isLessThan(Token t) => t is LessThanToken;
  static bool _isLessEqualThan(Token t) => t is LessEqualThanToken;
  static bool _isMinus(Token t) => t is MinusToken;
  static bool _isPlus(Token t) => t is PlusToken;
  static bool _isForwardSlash(Token t) => t is ForwardSlashToken;
  static bool _isAsterisk(Token t) => t is AsteriskToken;
  static bool _isPercent(Token t) => t is PercentToken;
  static bool _isAt(Token t) => t is AtToken;
  static bool _isBang(Token t) => t is BangToken;
  static bool _isOpenParen(Token t) => t is OpenParenthesisToken;
  static bool _isCloseParen(Token t) => t is CloseParenthesisToken;
  static bool _isOpenBracket(Token t) => t is OpenBracketToken;
  static bool _isCloseBracket(Token t) => t is CloseBracketToken;
  static bool _isOpenBraces(Token t) => t is OpenBracesToken;
  static bool _isCloseBraces(Token t) => t is CloseBracesToken;
  static bool _isComma(Token t) => t is CommaToken;
  static bool _isColon(Token t) => t is ColonToken;
  static bool _isBoolean(Token t) => t is BooleanToken;
  static bool _isNumber(Token t) => t is NumberToken;
  static bool _isString(Token t) => t is StringToken;
  static bool _isIdentifier(Token t) => t is IdentifierToken;

  // Static predicate lists - allocated once (multi-element only)
  static final List<bool Function(Token)> _equalityPredicates = [
    _isNotEqual,
    _isEqual,
  ];
  static final List<bool Function(Token)> _comparisonPredicates = [
    _isGreaterThan,
    _isGreaterEqualThan,
    _isLessThan,
    _isLessEqualThan,
  ];
  static final List<bool Function(Token)> _termPredicates = [_isMinus, _isPlus];
  static final List<bool Function(Token)> _factorPredicates = [
    _isForwardSlash,
    _isAsterisk,
    _isPercent,
  ];
  static final List<bool Function(Token)> _unaryPredicates = [
    _isBang,
    _isMinus,
  ];

  Expression expression() => ifExpression();

  Expression ifExpression() {
    if (matchSingle(_isIf)) {
      final Token operator = previous;
      consume(_isOpenParen, '(');
      final Expression condition = expression();
      consume(_isCloseParen, ')');
      final Expression ifTrue = expression();
      consume(_isElse, 'else');
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

    while (match(_equalityPredicates)) {
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

    while (matchSingle(_isPipe)) {
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

    while (matchSingle(_isAmpersand)) {
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

    while (match(_comparisonPredicates)) {
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

    while (match(_termPredicates)) {
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

    while (match(_factorPredicates)) {
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

    while (matchSingle(_isAt)) {
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
    if (match(_unaryPredicates)) {
      final Token operator = previous;
      final Expression right = unary();

      if (operator.value == '-') {
        // Unary negation `-x` is desugared to binary subtraction `-(0, x)`.
        // The synthetic zero uses the operator's location since it logically
        // originates from the negation syntax at that position.
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
      if (matchSingle(_isOpenParen)) {
        exp = finishCall(exp);
      } else if (matchSingle(_isOpenBracket)) {
        final Token operator = AtToken(
          Lexeme(
            value: '@',
            location: previous.location,
          ),
        );
        final Expression idx = expression();
        consume(_isCloseBracket, ']');
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

    if (!check(_isCloseParen)) {
      do {
        arguments.add(expression());
      } while (matchSingle(_isComma));
    }

    consume(_isCloseParen, ')');

    return CallExpression(callee: callee, arguments: arguments);
  }

  Expression primary() {
    if (matchSingle(_isBoolean)) {
      return BooleanExpression(previous);
    } else if (matchSingle(_isNumber)) {
      return NumberExpression(previous);
    } else if (matchSingle(_isString)) {
      return StringExpression(previous);
    } else if (matchSingle(_isIdentifier)) {
      return IdentifierExpression(previous);
    } else if (matchSingle(_isOpenParen)) {
      final Expression expr = expression();
      consume(_isCloseParen, ')');
      return expr;
    } else if (matchSingle(_isOpenBracket)) {
      return list(previous);
    } else if (matchSingle(_isOpenBraces)) {
      return map(previous);
    }

    throw InvalidTokenError(peek);
  }

  Expression list(Token token) {
    final List<Expression> elements = [];

    if (!check(_isCloseBracket)) {
      do {
        elements.add(expression());
      } while (matchSingle(_isComma));
    }

    consume(_isCloseBracket, ']');

    return ListExpression(
      location: token.location,
      value: elements,
    );
  }

  Expression map(Token token) {
    final List<MapEntryExpression> pairs = [];

    if (!check(_isCloseBraces)) {
      do {
        final Expression key = expression();
        consume(_isColon, ':');
        final Expression value = expression();
        pairs.add(
          MapEntryExpression(location: key.location, key: key, value: value),
        );
      } while (matchSingle(_isComma));
    }

    consume(_isCloseBraces, '}');

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

  bool matchSingle(bool Function(Token) predicate) {
    if (check(predicate)) {
      advance();
      return true;
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
