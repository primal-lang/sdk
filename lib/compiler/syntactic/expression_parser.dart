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
      return LiteralExpression.string(input.asString);
    } else if (input.type.isNumber) {
      return LiteralExpression.number(input.asNumber);
    } else if (input.type.isBoolean) {
      return LiteralExpression.boolean(input.asBoolean);
    } else if (input.type.isSymbol) {
      final Token next = iterator.peek;

      if (next.type.isOpenParenthesis) {
        return FunctionCallExpression(
          name: input.asString,
          arguments: getFunctionArguments(iterator),
        );
      } else {
        return LiteralExpression.symbol(input.asString);
      }
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }

  List<Expression> getFunctionArguments(ListIterator<Token> iterator) {
    final Token input = iterator.next;

    /*if (input.type.isNewLine) {
      return LiteralExpression.symbol(symbol);
    } else if (input.type.isOpenParenthesis) {
      return getFunctionArguments(
        functionName: symbol,
        iterator: iterator,
      );
    } else {*/
    throw SyntacticError.invalidToken(input);
    //}
  }
}
