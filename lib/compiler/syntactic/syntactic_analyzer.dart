import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/analyzer.dart';
import 'package:primal/compiler/models/state.dart';
import 'package:primal/compiler/syntactic/expression_parser.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/utils/list_iterator.dart';

class SyntacticAnalyzer
    extends Analyzer<List<Token>, List<FunctionDefinition>> {
  const SyntacticAnalyzer(super.tokens);

  @override
  List<FunctionDefinition> analyze() {
    final List<FunctionDefinition> result = [];
    final ListIterator<Token> iterator = ListIterator(input);
    State state = InitState(iterator);

    while (iterator.hasNext) {
      state = state.next;

      if (state is ResultState) {
        result.add(state.output);
        state = InitState(iterator);
      }
    }

    if (!(state is InitState)) {
      throw const UnexpectedEndOfFileError();
    }

    return result;
  }
}

class InitState extends State<Token, void> {
  const InitState(super.iterator, [super.output]);

  @override
  State process(Token input) {
    if (input is IdentifierToken) {
      return FunctionNameState(iterator, FunctionDefinition(name: input.value));
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class FunctionNameState extends State<Token, FunctionDefinition> {
  const FunctionNameState(super.iterator, super.output);

  @override
  State process(Token input) {
    if (input is AssignToken) {
      final ExpressionParser expressionParser = ExpressionParser(iterator);
      return ResultState(
        iterator,
        output.withExpression(expressionParser.expression()),
      );
    } else if (input is OpenParenthesisToken) {
      return FunctionWithParametersState(iterator, output);
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class FunctionWithParametersState extends State<Token, FunctionDefinition> {
  const FunctionWithParametersState(super.iterator, super.output);

  @override
  State process(Token input) {
    if (input is IdentifierToken) {
      return FunctionWithNewParametersState(
        iterator,
        output.withParameter(input.value),
      );
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class FunctionWithNewParametersState extends State<Token, FunctionDefinition> {
  const FunctionWithNewParametersState(super.iterator, super.output);

  @override
  State process(Token input) {
    if (input is CommaToken) {
      return FunctionWithNextParametersState(iterator, output);
    } else if (input is CloseParenthesisToken) {
      return FunctionParametrizedState(iterator, output);
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class FunctionWithNextParametersState extends State<Token, FunctionDefinition> {
  const FunctionWithNextParametersState(super.iterator, super.output);

  @override
  State process(Token input) {
    if (input is IdentifierToken) {
      return FunctionWithNewParametersState(
        iterator,
        output.withParameter(input.value),
      );
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class FunctionParametrizedState extends State<Token, FunctionDefinition> {
  const FunctionParametrizedState(super.iterator, super.output);

  @override
  State process(Token input) {
    if (input is AssignToken) {
      final ExpressionParser expressionParser = ExpressionParser(iterator);
      return ResultState(
        iterator,
        output.withExpression(expressionParser.expression()),
      );
    } else {
      throw InvalidTokenError(input);
    }
  }
}

class ResultState extends State<void, FunctionDefinition> {
  const ResultState(super.iterator, super.output);
}
