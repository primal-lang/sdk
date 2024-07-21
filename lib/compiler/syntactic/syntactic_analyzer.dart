import 'package:dry/compiler/errors/syntactic_error.dart';
import 'package:dry/compiler/input/location.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/models/analyzer.dart';
import 'package:dry/compiler/models/state.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:dry/utils/list_iterator.dart';
import 'package:dry/utils/stack.dart';

class SyntacticAnalyzer
    extends Analyzer<List<Token>, List<FunctionDefinition>> {
  const SyntacticAnalyzer(super.tokens);

  @override
  List<FunctionDefinition> analyze() {
    final List<FunctionDefinition> result = [];
    final ListIterator<Token> iterator = ListIterator(input);
    State state = InitState.empty();

    while (iterator.hasNext) {
      state = state.process(iterator.next);

      if (state is ResultState) {
        result.add(state.output);
        state = InitState.empty();
      }
    }

    if (!(state is InitState)) {
      throw SyntacticError.unexpectedEndOfFile();
    }

    return result;
  }
}

class InitState extends State<Token, void> {
  const InitState(super.output);

  factory InitState.empty() => const InitState(null);

  @override
  State process(Token input) {
    if (input.type.isSymbol) {
      return FunctionNameState(FunctionDefinition.withName(input.asString));
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }
}

class FunctionNameState extends State<Token, FunctionDefinition> {
  const FunctionNameState(super.output);

  @override
  State process(Token input) {
    if (input.type.isEquals) {
      return FunctionBodyInitState(output, Stack());
    } else if (input.type.isOpenParenthesis) {
      return FunctionWithParametersState(output);
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }
}

class FunctionWithParametersState extends State<Token, FunctionDefinition> {
  const FunctionWithParametersState(super.output);

  @override
  State process(Token input) {
    if (input.type.isSymbol) {
      return FunctionWithMoreParametersState(
          output.withParameter(input.asString));
    } else if (input.type.isCloseParenthesis) {
      if (output.parameters.isEmpty) {
        throw SyntacticError.invalidToken(input);
      }

      return FunctionParametrizedState(output);
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }
}

class FunctionWithMoreParametersState extends State<Token, FunctionDefinition> {
  const FunctionWithMoreParametersState(super.output);

  @override
  State process(Token input) {
    if (input.type.isComma) {
      return FunctionWithParametersState(output);
    } else if (input.type.isCloseParenthesis) {
      return FunctionParametrizedState(output);
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }
}

class FunctionParametrizedState extends State<Token, FunctionDefinition> {
  const FunctionParametrizedState(super.output);

  @override
  State process(Token input) {
    if (input.type.isEquals) {
      return FunctionBodyInitState(output, Stack());
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }
}

class FunctionBodyInitState extends State<Token, FunctionDefinition> {
  final Stack<StackElement> stack;

  const FunctionBodyInitState(super.output, this.stack);

  @override
  State process(Token input) {
    if (input.type.isString) {
      return ResultState(
          output.withExpression(LiteralExpression.string(input)));
    } else if (input.type.isNumber) {
      return ResultState(
          output.withExpression(LiteralExpression.number(input)));
    } else if (input.type.isBoolean) {
      return ResultState(
          output.withExpression(LiteralExpression.boolean(input)));
    } else if (input.type.isSymbol) {
      return FunctionBodyExpressionState(
        output,
        stack.push(StackSymbol(SymbolExpression.fromToken(input))),
      );
    } else {
      throw SyntacticError.invalidToken(input);
    }
  }
}

class FunctionBodyExpressionState extends State<Token, FunctionDefinition> {
  final Stack<StackElement> stack;

  const FunctionBodyExpressionState(super.output, this.stack);

  @override
  State process(Token input) {
    if (input.type.isString) {
      return FunctionBodyExpressionState(
        output,
        stack.push(StackLiteral(LiteralExpression.string(input))),
      );
    } else if (input.type.isNumber) {
      return FunctionBodyExpressionState(
        output,
        stack.push(StackLiteral(LiteralExpression.number(input))),
      );
    } else if (input.type.isBoolean) {
      return FunctionBodyExpressionState(
        output,
        stack.push(StackLiteral(LiteralExpression.boolean(input))),
      );
    } else if (input.type.isSymbol) {
      return FunctionBodyExpressionState(
        output,
        stack.push(StackSymbol(SymbolExpression.fromToken(input))),
      );
    } else if (input.type.isOpenParenthesis) {
      return FunctionBodyExpressionState(
        output,
        stack.push(StackOpenParenthesis(input)),
      );
    } else if (input.type.isComma) {
      return FunctionBodyExpressionState(
        output,
        stack.push(StackComma(input)),
      );
    } else if (input.type.isCloseParenthesis) {
      final StackElement firstParameter = stack.pop();

      if (!(firstParameter is StackExpression)) {
        throw SyntacticError.invalidStackElement(firstParameter);
      }

      final List<Expression> arguments = [firstParameter.expression];

      while (stack.isNotEmpty && !(stack.peek is StackOpenParenthesis)) {
        final StackElement commaElement = stack.pop();

        if (!(commaElement is StackComma)) {
          throw SyntacticError.invalidStackElement(commaElement);
        }

        final StackElement expressionElement = stack.pop();

        if (!(expressionElement is StackExpression)) {
          throw SyntacticError.invalidStackElement(expressionElement);
        }

        arguments.insert(0, expressionElement.expression);
      }

      if (stack.isEmpty) {
        throw SyntacticError.invalidToken(input);
      }

      final StackElement paranthesisElement = stack.pop();

      if (!(paranthesisElement is StackOpenParenthesis)) {
        throw SyntacticError.invalidStackElement(paranthesisElement);
      }

      final StackElement symbolElement = stack.pop();

      if (!(symbolElement is StackSymbol)) {
        throw SyntacticError.invalidStackElement(symbolElement);
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
      throw SyntacticError.invalidToken(input);
    }
  }
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
