import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/input/character.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/analyzer.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/state.dart';
import 'package:primal/extensions/string_extensions.dart';
import 'package:primal/utils/list_iterator.dart';

class LexicalAnalyzer extends Analyzer<List<Character>, List<Token>> {
  const LexicalAnalyzer(super.input);

  @override
  List<Token> analyze() {
    final List<Token> result = [];
    final ListIterator<Character> iterator = ListIterator(input);
    State state = const InitState();

    while (iterator.hasNext) {
      final Character input = iterator.next;
      state = state.process(input, iterator.peek);

      if (state is ResultState) {
        if (state.goBack) {
          iterator.back();
        }

        result.addAll(state.output);
        state = const InitState();
      }
    }

    return result;
  }
}

class InitState extends State<Character, void> {
  const InitState([super.output]);

  @override
  State process(Character input, Character? next) {
    if (input.value.isWhitespace) {
      return this;
    } else if (input.value.isDoubleQuote) {
      return StringDoubleQuoteState(Lexeme(
        value: '',
        location: input.location,
      ));
    } else if (input.value.isSingleQuote) {
      return StringSingleQuoteState(Lexeme(
        value: '',
        location: input.location,
      ));
    } else if (input.value.isDigit) {
      return IntegerState(input.lexeme);
    } else if (input.value.isLetter) {
      return SymbolState(input.lexeme);
    } else if (input.value.isMinus) {
      return MinusState(input.lexeme);
    } else if (input.value.isPlus) {
      return PlusState(input.lexeme);
    } else if (input.value.isEquals) {
      return EqualsState(input.lexeme);
    } else if (input.value.isGreater) {
      return GreaterState(input.lexeme);
    } else if (input.value.isLess) {
      return LessState(input.lexeme);
    } else if (input.value.isPipe) {
      return PipeState(input.lexeme);
    } else if (input.value.isAmpersand) {
      return AmpersandState(input.lexeme);
    } else if (input.value.isBang) {
      return BangState(input.lexeme);
    } else if (input.value.isForewardSlash) {
      return ForwardSlashState(input.lexeme);
    } else if (input.value.isComma) {
      return CommaState(input.lexeme);
    } else if (input.value.isOpenParenthesis) {
      return OpenParenthesisState(input.lexeme);
    } else if (input.value.isCloseParenthesis) {
      return CloseParenthesisState(input.lexeme);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class StringDoubleQuoteState extends State<Character, Lexeme> {
  const StringDoubleQuoteState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isDoubleQuote) {
      return ResultState([StringToken(output)]);
    } else {
      return StringDoubleQuoteState(output.add(input));
    }
  }
}

class StringSingleQuoteState extends State<Character, Lexeme> {
  const StringSingleQuoteState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isSingleQuote) {
      return ResultState([StringToken(output)]);
    } else {
      return StringSingleQuoteState(output.add(input));
    }
  }
}

class IntegerState extends State<Character, Lexeme> {
  const IntegerState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isDigit) {
      return IntegerState(output.add(input));
    } else if (input.value.isDot) {
      return DecimalState(output.add(input));
    } else if (input.value.isOperandDelimiter) {
      return ResultState([NumberToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class DecimalState extends State<Character, Lexeme> {
  const DecimalState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isDigit) {
      return DecimalState(output.add(input));
    } else if (input.value.isOperandDelimiter) {
      return ResultState([NumberToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class SymbolState extends State<Character, Lexeme> {
  const SymbolState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isLetter ||
        input.value.isDigit ||
        input.value.isDot ||
        input.value.isUnderscore) {
      return SymbolState(output.add(input));
    } else if (input.value.isOperandDelimiter) {
      final List<Token> tokens = [
        if (output.value.isBoolean)
          BooleanToken(output)
        else
          SymbolToken(output)
      ];

      return ResultState(tokens, true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class MinusState extends State<Character, Lexeme> {
  const MinusState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isOperatorDelimiter) {
      return ResultState([MinusToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class PlusState extends State<Character, Lexeme> {
  const PlusState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isOperatorDelimiter) {
      return ResultState([PlusToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class EqualsState extends State<Character, Lexeme> {
  const EqualsState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isEquals) {
      return ResultState([EqualToken(output.add(input))]);
    } else if (input.value.isOperatorDelimiter) {
      return ResultState([AssignToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class GreaterState extends State<Character, Lexeme> {
  const GreaterState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isEquals) {
      return ResultState([GreaterEqualThanToken(output.add(input))]);
    } else if (input.value.isOperatorDelimiter) {
      return ResultState([GreaterThanToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class LessState extends State<Character, Lexeme> {
  const LessState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isEquals) {
      return ResultState([LessEqualThanToken(output.add(input))]);
    } else if (input.value.isOperatorDelimiter) {
      return ResultState([LessThanToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class PipeState extends State<Character, Lexeme> {
  const PipeState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isOperatorDelimiter) {
      return ResultState([PipeToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class AmpersandState extends State<Character, Lexeme> {
  const AmpersandState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isOperatorDelimiter) {
      return ResultState([AmpersandToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class BangState extends State<Character, Lexeme> {
  const BangState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isEquals) {
      return ResultState([NotEqualToken(output.add(input))]);
    } else if (input.value.isOperatorDelimiter) {
      return ResultState([BangToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class ForwardSlashState extends State<Character, Lexeme> {
  const ForwardSlashState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isForewardSlash) {
      return const SingleLineCommentState();
    } else if (input.value.isAsterisk) {
      return const StartMultiLineCommentState();
    } else {
      return ResultState([ForwardSlashToken(output)]);
    }
  }
}

class SingleLineCommentState extends State<Character, void> {
  const SingleLineCommentState([super.output]);

  @override
  State process(Character input, Character? next) {
    if (!input.value.isNewLine) {
      return const SingleLineCommentState();
    } else {
      return const InitState();
    }
  }
}

class StartMultiLineCommentState extends State<Character, void> {
  const StartMultiLineCommentState([super.output]);

  @override
  State process(Character input, Character? next) {
    if (!input.value.isAsterisk) {
      return const StartMultiLineCommentState();
    } else {
      return const ClosingMultiLineCommentState();
    }
  }
}

class ClosingMultiLineCommentState extends State<Character, void> {
  const ClosingMultiLineCommentState([super.output]);

  @override
  State process(Character input, Character? next) {
    if (!input.value.isForewardSlash) {
      return const StartMultiLineCommentState();
    } else {
      return const InitState();
    }
  }
}

class CommaState extends State<Character, Lexeme> {
  const CommaState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isOperatorDelimiter) {
      return ResultState([CommaToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class OpenParenthesisState extends State<Character, Lexeme> {
  const OpenParenthesisState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isOperatorDelimiter) {
      return ResultState([OpenParenthesisToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class CloseParenthesisState extends State<Character, Lexeme> {
  const CloseParenthesisState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.value.isSeparatorDelimiter) {
      return ResultState([CloseParenthesisToken(output)], true);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class ResultState extends State<void, List<Token>> {
  final bool goBack;

  const ResultState(super.output, [this.goBack = false]);
}

class Lexeme extends Localized {
  final String value;

  const Lexeme({
    required this.value,
    required super.location,
  });

  Lexeme add(Character character) => Lexeme(
        value: value + character.value,
        location: location,
      );

  @override
  String toString() => '"$value" at $location';
}
