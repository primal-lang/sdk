import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/analyzer.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/state.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/utils/list_iterator.dart';
import 'package:primal/utils/stack.dart';

class SyntacticAnalyzer
    extends Analyzer<List<Token>, List<FunctionDefinition>> {
  const SyntacticAnalyzer(super.tokens);

  @override
  List<FunctionDefinition> analyze() {
    final List<FunctionDefinition> result = [];
    final ListIterator<Token> iterator = ListIterator(input);
    State state = const InitState();

    while (iterator.hasNext) {
      final Token input = iterator.next;
      state = state.process(input, iterator.peek);

      if (state is ResultState) {
        result.add(state.output);
        state = const InitState();
      }
    }

    if (!(state is InitState)) {
      throw const UnexpectedEndOfFileError();
    }

    return result;
  }

  Expression get expression {
    final List<FunctionDefinition> result = [];
    final ListIterator<Token> iterator = ListIterator(input);
    State state = FunctionBodyInitState(
      const FunctionDefinition(name: ''),
      Stack(),
    );

    while (iterator.hasNext) {
      final Token input = iterator.next;
      state = state.process(input, iterator.peek);

      if (state is ResultState) {
        result.add(state.output);
        state = const InitState();
      }
    }

    if (!(state is InitState)) {
      throw const UnexpectedEndOfFileError();
    }

    return result[0].expression;
  }
}

class InitState extends State<Token, void> {
  const InitState([super.output]);

  @override
  State process(Token input, Token? next) {
    if (input is SymbolToken) {
      return FunctionNameState(FunctionDefinition(name: input.value));
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class FunctionNameState extends State<Token, FunctionDefinition> {
  const FunctionNameState(super.output);

  @override
  State process(Token input, Token? next) {
    if (input is AssignToken) {
      return FunctionBodyInitState(output, Stack());
    } else if (input is OpenParenthesisToken) {
      return FunctionWithParametersState(output);
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class FunctionWithParametersState extends State<Token, FunctionDefinition> {
  const FunctionWithParametersState(super.output);

  @override
  State process(Token input, Token? next) {
    if (input is SymbolToken) {
      return FunctionWithNewParametersState(output.withParameter(input.value));
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class FunctionWithNewParametersState extends State<Token, FunctionDefinition> {
  const FunctionWithNewParametersState(super.output);

  @override
  State process(Token input, Token? next) {
    if (input is CommaToken) {
      return FunctionWithNextParametersState(output);
    } else if (input is CloseParenthesisToken) {
      return FunctionParametrizedState(output);
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class FunctionWithNextParametersState extends State<Token, FunctionDefinition> {
  const FunctionWithNextParametersState(super.output);

  @override
  State process(Token input, Token? next) {
    if (input is SymbolToken) {
      return FunctionWithNewParametersState(output.withParameter(input.value));
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class FunctionParametrizedState extends State<Token, FunctionDefinition> {
  const FunctionParametrizedState(super.output);

  @override
  State process(Token input, Token? next) {
    if (input is AssignToken) {
      return FunctionBodyInitState(output, Stack());
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class FunctionBodyInitState extends State<Token, FunctionDefinition> {
  final Stack<StackElement> stack;

  const FunctionBodyInitState(super.output, this.stack);

  @override
  State process(Token input, Token? next) {
    if (input is StringToken) {
      return ResultState(output.withExpression(StringExpression(input)));
    } else if (input is NumberToken) {
      return ResultState(output.withExpression(NumberExpression(input)));
    } else if (input is BooleanToken) {
      return ResultState(output.withExpression(BooleanExpression(input)));
    } else if (input is SymbolToken) {
      if (next is OpenParenthesisToken) {
        return FunctionBodyExpressionState(
          output,
          stack.push(StackSymbol(SymbolExpression(input))),
        );
      } else {
        return ResultState(output.withExpression(SymbolExpression(input)));
      }
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class FunctionBodyExpressionState extends State<Token, FunctionDefinition> {
  final Stack<StackElement> stack;

  const FunctionBodyExpressionState(super.output, this.stack);

  @override
  State process(Token input, Token? next) {
    if (input is StringToken) {
      if (topIsNot([StackOpenParenthesis, StackComma])) {
        throw InvalidTokenError(input);
      }

      return FunctionBodyExpressionState(
        output,
        stack.push(StackLiteral(StringExpression(input))),
      );
    } else if (input is NumberToken) {
      if (topIsNot([StackOpenParenthesis, StackComma])) {
        throw InvalidTokenError(input);
      }

      return FunctionBodyExpressionState(
        output,
        stack.push(StackLiteral(NumberExpression(input))),
      );
    } else if (input is BooleanToken) {
      if (topIsNot([StackOpenParenthesis, StackComma])) {
        throw InvalidTokenError(input);
      }

      return FunctionBodyExpressionState(
        output,
        stack.push(StackLiteral(BooleanExpression(input))),
      );
    } else if (input is SymbolToken) {
      if (topIsNot([StackOpenParenthesis, StackComma])) {
        throw InvalidTokenError(input);
      }

      return FunctionBodyExpressionState(
        output,
        stack.push(StackSymbol(SymbolExpression(input))),
      );
    } else if (input is OpenParenthesisToken) {
      if (topIsNot([StackSymbol])) {
        throw InvalidTokenError(input);
      }

      return FunctionBodyExpressionState(
        output,
        stack.push(StackOpenParenthesis(input)),
      );
    } else if (input is CommaToken) {
      if (topIsNot([StackLiteral, StackSymbol, StackFunctionCall])) {
        throw InvalidTokenError(input);
      }

      return FunctionBodyExpressionState(
        output,
        stack.push(StackComma(input)),
      );
    } else if (input is CloseParenthesisToken) {
      final StackElement lastArgumentElement = stack.pop();

      if (!(lastArgumentElement is StackExpression)) {
        throw InvalidStackElementError(lastArgumentElement);
      }

      final List<Expression> arguments = [lastArgumentElement.expression];

      while (stack.isNotEmpty && topIsNot([StackOpenParenthesis])) {
        final StackElement commaElement = stack.pop();

        if (!(commaElement is StackComma)) {
          throw InvalidStackElementError(commaElement);
        }

        final StackElement expressionElement = stack.pop();

        if (!(expressionElement is StackExpression)) {
          throw InvalidStackElementError(expressionElement);
        }

        arguments.insert(0, expressionElement.expression);
      }

      if (stack.isEmpty) {
        throw InvalidTokenError(input);
      }

      final StackElement openParanthesisElement = stack.pop();

      if (!(openParanthesisElement is StackOpenParenthesis)) {
        throw InvalidStackElementError(openParanthesisElement);
      }

      final StackElement symbolElement = stack.pop();

      if (!(symbolElement is StackSymbol)) {
        throw InvalidStackElementError(symbolElement);
      }

      final FunctionCallExpression functionCall = FunctionCallExpression(
        location: symbolElement.expression.location,
        name: symbolElement.expression.value,
        arguments: arguments,
      );

      if (stack.isEmpty) {
        return ResultState(output.withExpression(functionCall));
      } else {
        return FunctionBodyExpressionState(
          output,
          stack.push(StackFunctionCall(functionCall)),
        );
      }
    } else {
      throw InvalidTokenError(input);
    }
  }

  bool topIs(Type type) => stack.peek.runtimeType == type;

  bool topIsNot(List<Type> types) => types.every((type) => !topIs(type));
}

class ResultState extends State<void, FunctionDefinition> {
  const ResultState(super.output);
}

class StackElement extends Localized {
  const StackElement({required super.location});
}

class StackExpression<T extends Expression> extends StackElement {
  final T expression;

  StackExpression(this.expression) : super(location: expression.location);
}

class StackLiteral extends StackExpression<LiteralExpression> {
  StackLiteral(super.expression);
}

class StackSymbol extends StackExpression<SymbolExpression> {
  StackSymbol(super.expression);
}

class StackFunctionCall extends StackExpression<FunctionCallExpression> {
  StackFunctionCall(super.expression);
}

class StackOpenParenthesis extends StackElement {
  final Token token;

  StackOpenParenthesis(this.token) : super(location: token.location);
}

class StackComma extends StackElement {
  final Token token;

  StackComma(this.token) : super(location: token.location);
}
