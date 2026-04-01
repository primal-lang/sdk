import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/lexical/lexeme.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/analyzer.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/state.dart';
import 'package:primal/compiler/scanner/character.dart';
import 'package:primal/extensions/string_extensions.dart';
import 'package:primal/utils/list_iterator.dart';

enum QuoteType { single, double }

extension QuoteTypeExtension on QuoteType {
  bool isTerminator(String char) => switch (this) {
    QuoteType.single => char.isSingleQuote,
    QuoteType.double => char.isDoubleQuote,
  };
}

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
        result.add(state.output);
        state = InitState(iterator);
      }
    }

    if (state is IntegerState) {
      result.add(NumberToken(state.output));
    } else if (state is DecimalState) {
      result.add(NumberToken(state.output));
    } else if (state is IdentifierState) {
      final Lexeme lexeme = state.output;
      if (lexeme.value.isBoolean) {
        result.add(BooleanToken(lexeme));
      } else if (lexeme.value.isIf) {
        result.add(IfToken(lexeme));
      } else if (lexeme.value.isElse) {
        result.add(ElseToken(lexeme));
      } else {
        result.add(IdentifierToken(lexeme));
      }
    } else if (state is StringState) {
      throw UnterminatedStringError(state.output.location);
    } else if (state is StringEscapeState) {
      throw UnterminatedStringError(state.output.location);
    } else if (state is StringHexEscapeState) {
      throw UnterminatedStringError(state.output.location);
    } else if (state is StringUnicodeEscapeState) {
      throw UnterminatedStringError(state.output.location);
    } else if (state is StringBracedEscapeState) {
      throw UnterminatedStringError(state.output.location);
    } else if (state is StartMultiLineCommentState ||
        state is ClosingMultiLineCommentState) {
      throw const UnterminatedCommentError();
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
      return StringState(
        iterator,
        Lexeme(value: '', location: input.location),
        QuoteType.double,
      );
    } else if (input.value.isSingleQuote) {
      return StringState(
        iterator,
        Lexeme(value: '', location: input.location),
        QuoteType.single,
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
      return ResultState(iterator, CommaToken(input.lexeme));
    } else if (input.value.isColon) {
      return ResultState(iterator, ColonToken(input.lexeme));
    } else if (input.value.isOpenParenthesis) {
      return ResultState(iterator, OpenParenthesisToken(input.lexeme));
    } else if (input.value.isCloseParenthesis) {
      return ResultState(iterator, CloseParenthesisToken(input.lexeme));
    } else if (input.value.isOpenBracket) {
      return ResultState(iterator, OpenBracketToken(input.lexeme));
    } else if (input.value.isCloseBracket) {
      return ResultState(iterator, CloseBracketToken(input.lexeme));
    } else if (input.value.isOpenBraces) {
      return ResultState(iterator, OpenBracesToken(input.lexeme));
    } else if (input.value.isCloseBraces) {
      return ResultState(iterator, CloseBracesToken(input.lexeme));
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class StringState extends State<Character, Lexeme> {
  final QuoteType quoteType;

  const StringState(super.iterator, super.output, this.quoteType);

  @override
  State process(Character input) {
    if (quoteType.isTerminator(input.value)) {
      return ResultState(iterator, StringToken(output));
    } else if (input.value.isBackslash) {
      return StringEscapeState(iterator, output, quoteType);
    } else {
      return StringState(iterator, output.add(input), quoteType);
    }
  }
}

class StringEscapeState extends State<Character, Lexeme> {
  final QuoteType quoteType;

  const StringEscapeState(super.iterator, super.output, this.quoteType);

  @override
  State process(Character input) {
    if (input.value == 'n') {
      return StringState(iterator, output.addValue('\n'), quoteType);
    } else if (input.value == 't') {
      return StringState(iterator, output.addValue('\t'), quoteType);
    } else if (input.value.isBackslash) {
      return StringState(iterator, output.addValue('\\'), quoteType);
    } else if (input.value.isDoubleQuote) {
      return StringState(iterator, output.addValue('"'), quoteType);
    } else if (input.value.isSingleQuote) {
      return StringState(iterator, output.addValue("'"), quoteType);
    } else if (input.value == 'x') {
      return StringHexEscapeState(
        iterator,
        output,
        quoteType,
        2,
        '',
        input.location,
      );
    } else if (input.value == 'u') {
      return StringUnicodeEscapeState(
        iterator,
        output,
        quoteType,
        input.location,
      );
    } else {
      throw InvalidEscapeSequenceError(input);
    }
  }
}

class StringHexEscapeState extends State<Character, Lexeme> {
  final QuoteType quoteType;
  final int requiredDigits;
  final String hexAccum;
  final Location escapeStart;

  const StringHexEscapeState(
    super.iterator,
    super.output,
    this.quoteType,
    this.requiredDigits,
    this.hexAccum,
    this.escapeStart,
  );

  @override
  State process(Character input) {
    if (!input.value.isHexDigit) {
      throw InvalidHexEscapeError(
        input,
        requiredDigits == 2 ? 'x' : 'u',
        requiredDigits,
      );
    }

    final String newHex = hexAccum + input.value;

    if (newHex.length == requiredDigits) {
      final int codePoint = int.parse(newHex, radix: 16);
      return StringState(
        iterator,
        output.addValue(String.fromCharCode(codePoint)),
        quoteType,
      );
    }

    return StringHexEscapeState(
      iterator,
      output,
      quoteType,
      requiredDigits,
      newHex,
      escapeStart,
    );
  }
}

class StringUnicodeEscapeState extends State<Character, Lexeme> {
  final QuoteType quoteType;
  final Location escapeStart;

  const StringUnicodeEscapeState(
    super.iterator,
    super.output,
    this.quoteType,
    this.escapeStart,
  );

  @override
  State process(Character input) {
    if (input.value == '{') {
      return StringBracedEscapeState(
        iterator,
        output,
        quoteType,
        '',
        escapeStart,
      );
    } else if (input.value.isHexDigit) {
      return StringHexEscapeState(
        iterator,
        output,
        quoteType,
        4,
        input.value,
        escapeStart,
      );
    } else {
      throw InvalidHexEscapeError(input, 'u', 4);
    }
  }
}

class StringBracedEscapeState extends State<Character, Lexeme> {
  final QuoteType quoteType;
  final String hexAccum;
  final Location escapeStart;

  const StringBracedEscapeState(
    super.iterator,
    super.output,
    this.quoteType,
    this.hexAccum,
    this.escapeStart,
  );

  @override
  State process(Character input) {
    if (input.value == '}') {
      if (hexAccum.isEmpty) {
        throw InvalidBracedEscapeError('Empty \\u{} escape', escapeStart);
      }
      final int codePoint = int.parse(hexAccum, radix: 16);
      if (codePoint > 0x10FFFF) {
        throw InvalidCodePointError(codePoint, escapeStart);
      }
      return StringState(
        iterator,
        output.addValue(String.fromCharCode(codePoint)),
        quoteType,
      );
    } else if (input.value.isHexDigit) {
      if (hexAccum.length >= 6) {
        throw InvalidBracedEscapeError(
          'Too many digits in \\u{} escape (max 6)',
          escapeStart,
        );
      }
      return StringBracedEscapeState(
        iterator,
        output,
        quoteType,
        hexAccum + input.value,
        escapeStart,
      );
    } else {
      throw InvalidBracedEscapeError(
        "Invalid character '${input.value}' in \\u{} escape",
        escapeStart,
      );
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
      return ResultState(iterator, NumberToken(output));
    } else {
      throw InvalidCharacterError(input, 'digit or dot');
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
      throw InvalidCharacterError(input, 'digit');
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
      return ResultState(iterator, NumberToken(output));
    } else {
      throw InvalidCharacterError(input, 'digit');
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
        return ResultState(iterator, BooleanToken(output));
      } else if (output.value.isIf) {
        return ResultState(iterator, IfToken(output));
      } else if (output.value.isElse) {
        return ResultState(iterator, ElseToken(output));
      } else {
        return ResultState(iterator, IdentifierToken(output));
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
      return ResultState(iterator, MinusToken(output));
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
      return ResultState(iterator, PlusToken(output));
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
      return ResultState(iterator, EqualToken(output.add(input)));
    } else if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, AssignToken(output));
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
      return ResultState(iterator, GreaterEqualThanToken(output.add(input)));
    } else if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, GreaterThanToken(output));
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
      return ResultState(iterator, LessEqualThanToken(output.add(input)));
    } else if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, LessThanToken(output));
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
      return ResultState(iterator, PipeToken(output));
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
      return ResultState(iterator, AmpersandToken(output));
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
      return ResultState(iterator, NotEqualToken(output.add(input)));
    } else if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, BangToken(output));
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
      iterator.back();
      return ResultState(iterator, ForwardSlashToken(output));
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
      return ResultState(iterator, AsteriskToken(output));
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
      return ResultState(iterator, PercentToken(output));
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

class ResultState extends State<void, Token> {
  const ResultState(super.iterator, super.output);
}
