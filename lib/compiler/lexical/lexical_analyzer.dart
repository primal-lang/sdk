import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/analyzer.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/state.dart';
import 'package:primal/compiler/scanner/character.dart';
import 'package:primal/extensions/string_extensions.dart';
import 'package:primal/utils/list_iterator.dart';

class LexicalAnalyzer extends Analyzer<List<Character>, List<Token>> {
  const LexicalAnalyzer(super.input);

  @override
  List<Token> analyze() {
    final List<Token> result = [];
    final ListIterator<Character> iterator = ListIterator(input);
    State state = InitState(iterator);

    while (iterator.hasNext) {
      state = state.next;

      if (state is ResultState) {
        result.addAll(state.output);
        state = InitState(iterator);
      }
    }

    return result;
  }
}

class InitState extends State<Character, void> {
  const InitState(super.iterator, [super.output]);

  @override
  State process(Character input) {
    if (input.value.isWhitespace) {
      return this;
    } else if (input.value.isDoubleQuote) {
      return StringDoubleQuoteState(
        iterator,
        Lexeme(
          value: '',
          location: input.location,
        ),
      );
    } else if (input.value.isSingleQuote) {
      return StringSingleQuoteState(
        iterator,
        Lexeme(
          value: '',
          location: input.location,
        ),
      );
    } else if (input.value.isDigit) {
      return IntegerState(iterator, input.lexeme);
    } else if (input.value.isLetter) {
      return IdentifierState(iterator, input.lexeme);
    } else if (input.value.isMinus) {
      return MinusState(iterator, input.lexeme);
    } else if (input.value.isPlus) {
      return PlusState(iterator, input.lexeme);
    } else if (input.value.isEquals) {
      return EqualsState(iterator, input.lexeme);
    } else if (input.value.isGreater) {
      return GreaterState(iterator, input.lexeme);
    } else if (input.value.isLess) {
      return LessState(iterator, input.lexeme);
    } else if (input.value.isPipe) {
      return PipeState(iterator, input.lexeme);
    } else if (input.value.isAmpersand) {
      return AmpersandState(iterator, input.lexeme);
    } else if (input.value.isBang) {
      return BangState(iterator, input.lexeme);
    } else if (input.value.isForwardSlash) {
      return ForwardSlashState(iterator, input.lexeme);
    } else if (input.value.isAsterisk) {
      return AsteriskState(iterator, input.lexeme);
    } else if (input.value.isPercent) {
      return PercentState(iterator, input.lexeme);
    } else if (input.value.isComma) {
      return CommaState(iterator, input.lexeme);
    } else if (input.value.isOpenParenthesis) {
      return OpenParenthesisState(iterator, input.lexeme);
    } else if (input.value.isCloseParenthesis) {
      return CloseParenthesisState(iterator, input.lexeme);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class StringDoubleQuoteState extends State<Character, Lexeme> {
  const StringDoubleQuoteState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isDoubleQuote) {
      return ResultState(iterator, [StringToken(output)]);
    } else {
      return StringDoubleQuoteState(iterator, output.add(input));
    }
  }
}

class StringSingleQuoteState extends State<Character, Lexeme> {
  const StringSingleQuoteState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isSingleQuote) {
      return ResultState(iterator, [StringToken(output)]);
    } else {
      return StringSingleQuoteState(iterator, output.add(input));
    }
  }
}

class IntegerState extends State<Character, Lexeme> {
  const IntegerState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return IntegerState(iterator, output.add(input));
    } else if (input.value.isDot) {
      return DecimalInitState(iterator, output.add(input));
    } else if (input.value.isOperandDelimiter) {
      iterator.back();
      return ResultState(iterator, [NumberToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class DecimalInitState extends State<Character, Lexeme> {
  const DecimalInitState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return DecimalState(iterator, output.add(input));
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class DecimalState extends State<Character, Lexeme> {
  const DecimalState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return DecimalState(iterator, output.add(input));
    } else if (input.value.isOperandDelimiter) {
      iterator.back();
      return ResultState(iterator, [NumberToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class IdentifierState extends State<Character, Lexeme> {
  const IdentifierState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isIdentifier) {
      return IdentifierState(iterator, output.add(input));
    } else if (input.value.isOperandDelimiter) {
      iterator.back();

      if (output.value.isBoolean) {
        return ResultState(iterator, [BooleanToken(output)]);
      } else if (output.value.isIf) {
        return ResultState(iterator, [IfToken(output)]);
      } else if (output.value.isElse) {
        return ResultState(iterator, [ElseToken(output)]);
      } else {
        return ResultState(iterator, [IdentifierToken(output)]);
      }
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class MinusState extends State<Character, Lexeme> {
  const MinusState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, [MinusToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class PlusState extends State<Character, Lexeme> {
  const PlusState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, [PlusToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class EqualsState extends State<Character, Lexeme> {
  const EqualsState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isEquals) {
      return ResultState(iterator, [EqualToken(output.add(input))]);
    } else if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, [AssignToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class GreaterState extends State<Character, Lexeme> {
  const GreaterState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isEquals) {
      return ResultState(iterator, [GreaterEqualThanToken(output.add(input))]);
    } else if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, [GreaterThanToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class LessState extends State<Character, Lexeme> {
  const LessState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isEquals) {
      return ResultState(iterator, [LessEqualThanToken(output.add(input))]);
    } else if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, [LessThanToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class PipeState extends State<Character, Lexeme> {
  const PipeState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, [PipeToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class AmpersandState extends State<Character, Lexeme> {
  const AmpersandState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, [AmpersandToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class BangState extends State<Character, Lexeme> {
  const BangState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isEquals) {
      return ResultState(iterator, [NotEqualToken(output.add(input))]);
    } else if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, [BangToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class ForwardSlashState extends State<Character, Lexeme> {
  const ForwardSlashState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isOperatorDelimiter) {
      return ResultState(iterator, [ForwardSlashToken(output)]);
    } else if (input.value.isForwardSlash) {
      return SingleLineCommentState(iterator);
    } else if (input.value.isAsterisk) {
      return StartMultiLineCommentState(iterator);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class AsteriskState extends State<Character, Lexeme> {
  const AsteriskState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, [AsteriskToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class PercentState extends State<Character, Lexeme> {
  const PercentState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, [PercentToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class SingleLineCommentState extends State<Character, void> {
  const SingleLineCommentState(super.iterator, [super.output]);

  @override
  State process(Character input) {
    if (!input.value.isNewLine) {
      return SingleLineCommentState(iterator);
    } else {
      return InitState(iterator);
    }
  }
}

class StartMultiLineCommentState extends State<Character, void> {
  const StartMultiLineCommentState(super.iterator, [super.output]);

  @override
  State process(Character input) {
    if (!input.value.isAsterisk) {
      return StartMultiLineCommentState(iterator);
    } else {
      return ClosingMultiLineCommentState(iterator);
    }
  }
}

class ClosingMultiLineCommentState extends State<Character, void> {
  const ClosingMultiLineCommentState(super.iterator, [super.output]);

  @override
  State process(Character input) {
    if (!input.value.isForwardSlash) {
      return StartMultiLineCommentState(iterator);
    } else {
      return InitState(iterator);
    }
  }
}

class CommaState extends State<Character, Lexeme> {
  const CommaState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isCommaDelimiter) {
      iterator.back();
      return ResultState(iterator, [CommaToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class OpenParenthesisState extends State<Character, Lexeme> {
  const OpenParenthesisState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isOpenParenthesisDelimiter) {
      iterator.back();
      return ResultState(iterator, [OpenParenthesisToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class CloseParenthesisState extends State<Character, Lexeme> {
  const CloseParenthesisState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isCloseParenthesisDelimiter) {
      iterator.back();
      return ResultState(iterator, [CloseParenthesisToken(output)]);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class ResultState extends State<void, List<Token>> {
  const ResultState(super.iterator, super.output);
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
