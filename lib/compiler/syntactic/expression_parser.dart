import 'package:dry/compiler/errors/syntactic_error.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/utils/list_iterator.dart';

class ExpressionParser {
  final ListIterator<Token> iterator;

  const ExpressionParser(this.iterator);

  Expression get expression => getExpression(iterator);

  Expression getExpression(ListIterator<Token> iterator) {
    final Token input = iterator.next;

    if (input.type.isString) {
      return LiteralExpression.string(input);
    } else if (input.type.isNumber) {
      return LiteralExpression.number(input);
    } else if (input.type.isBoolean) {
      return LiteralExpression.boolean(input);
    } else if (input.type.isSymbol) {
      final Token next = iterator.peek;

      if (next.type.isOpenParenthesis) {
        iterator.consume();

        return FunctionCallExpression(
          name: input.asString,
          arguments: getFunctionArguments(iterator),
          location: input.location,
        );
      } else {
        return LiteralExpression.symbol(input);
      }
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }

  List<Expression> getFunctionArguments(ListIterator<Token> iterator) {
    final List<Expression> result = [getExpression(iterator)];

    while (!iterator.peek.type.isCloseParenthesis) {
      final Token next = iterator.next;

      if (!next.type.isComma) {
        throw SyntacticError.invalidToken(next);
      }

      result.add(getExpression(iterator));
    }

    final Token next = iterator.next;

    if (!next.type.isCloseParenthesis) {
      throw SyntacticError.invalidToken(next);
    }

    return result;
  }
}
