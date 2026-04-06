import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/lexical/lexeme.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/analyzer.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/state.dart';
import 'package:primal/compiler/reader/character.dart';
import 'package:primal/extensions/string_extensions.dart';
import 'package:primal/utils/list_iterator.dart';

/// Creates a [Lexeme] from a [Character].
Lexeme _lexemeOf(Character character) => Lexeme(
  value: character.value,
  location: character.location,
);

Token _identifierOrKeywordToken(Lexeme lexeme) {
  if (lexeme.value.isBoolean) {
    return BooleanToken(lexeme);
  }
  if (lexeme.value.isIf) {
    return IfToken(lexeme);
  }
  if (lexeme.value.isElse) {
    return ElseToken(lexeme);
  }
  if (lexeme.value.isAnd) {
    // Use canonical operator name '&' for 'and' keyword
    return AmpersandToken(Lexeme(value: '&', location: lexeme.location));
  }
  if (lexeme.value.isOr) {
    // Use canonical operator name '|' for 'or' keyword
    return PipeToken(Lexeme(value: '|', location: lexeme.location));
  }
  return IdentifierToken(lexeme);
}

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
      if (state.lastWasUnderscore) {
        throw const LexicalError('Trailing underscore in number literal');
      }
      result.add(NumberToken(state.output));
    } else if (state is DecimalState) {
      if (state.lastWasUnderscore) {
        throw const LexicalError('Trailing underscore in number literal');
      }
      result.add(NumberToken(state.output));
    } else if (state is ExponentState) {
      if (state.lastWasUnderscore) {
        throw const LexicalError('Trailing underscore in number literal');
      }
      result.add(NumberToken(state.output));
    } else if (state is ExponentInitState || state is ExponentSignState) {
      throw const LexicalError('Incomplete exponent in number literal');
    } else if (state is IdentifierState) {
      result.add(_identifierOrKeywordToken(state.output));
    } else if (state is StringRelatedState) {
      throw UnterminatedStringError(state.stringStartLocation);
    } else if (state is StartMultiLineCommentState ||
        state is ClosingMultiLineCommentState) {
      throw const UnterminatedCommentError();
    }

    return result;
  }
}

abstract class StringRelatedState extends State<Character, Lexeme> {
  const StringRelatedState(super.iterator, super.output);

  Location get stringStartLocation;
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
      return IntegerState(iterator, _lexemeOf(input));
    } else if (input.value.isLetter) {
      return IdentifierState(iterator, _lexemeOf(input));
    } else if (input.value.isMinus) {
      return MinusState(iterator, _lexemeOf(input));
    } else if (input.value.isPlus) {
      return PlusState(iterator, _lexemeOf(input));
    } else if (input.value.isEquals) {
      return EqualsState(iterator, _lexemeOf(input));
    } else if (input.value.isGreater) {
      return GreaterState(iterator, _lexemeOf(input));
    } else if (input.value.isLess) {
      return LessState(iterator, _lexemeOf(input));
    } else if (input.value.isPipe) {
      return PipeState(iterator, _lexemeOf(input));
    } else if (input.value.isAmpersand) {
      return AmpersandState(iterator, _lexemeOf(input));
    } else if (input.value.isBang) {
      return BangState(iterator, _lexemeOf(input));
    } else if (input.value.isForwardSlash) {
      return ForwardSlashState(iterator, _lexemeOf(input));
    } else if (input.value.isAsterisk) {
      return AsteriskState(iterator, _lexemeOf(input));
    } else if (input.value.isPercent) {
      return PercentState(iterator, _lexemeOf(input));
    } else if (input.value.isAt) {
      return ResultState(iterator, AtToken(_lexemeOf(input)));
    } else if (input.value.isComma) {
      return ResultState(iterator, CommaToken(_lexemeOf(input)));
    } else if (input.value.isColon) {
      return ResultState(iterator, ColonToken(_lexemeOf(input)));
    } else if (input.value.isOpenParenthesis) {
      return ResultState(iterator, OpenParenthesisToken(_lexemeOf(input)));
    } else if (input.value.isCloseParenthesis) {
      return ResultState(iterator, CloseParenthesisToken(_lexemeOf(input)));
    } else if (input.value.isOpenBracket) {
      return ResultState(iterator, OpenBracketToken(_lexemeOf(input)));
    } else if (input.value.isCloseBracket) {
      return ResultState(iterator, CloseBracketToken(_lexemeOf(input)));
    } else if (input.value.isOpenBraces) {
      return ResultState(iterator, OpenBracesToken(_lexemeOf(input)));
    } else if (input.value.isCloseBraces) {
      return ResultState(iterator, CloseBracesToken(_lexemeOf(input)));
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class StringState extends StringRelatedState {
  final QuoteType quoteType;

  const StringState(super.iterator, super.output, this.quoteType);

  @override
  Location get stringStartLocation => output.location;

  @override
  State process(Character input) {
    if (quoteType.isTerminator(input.value)) {
      return ResultState(iterator, StringToken(output));
    } else if (input.value.isBackslash) {
      return StringEscapeState(iterator, output, quoteType);
    } else {
      return StringState(iterator, output.add(input.value), quoteType);
    }
  }
}

class StringEscapeState extends StringRelatedState {
  final QuoteType quoteType;

  const StringEscapeState(super.iterator, super.output, this.quoteType);

  @override
  Location get stringStartLocation => output.location;

  @override
  State process(Character input) {
    if (input.value == 'n') {
      return StringState(iterator, output.add('\n'), quoteType);
    } else if (input.value == 't') {
      return StringState(iterator, output.add('\t'), quoteType);
    } else if (input.value.isBackslash) {
      return StringState(iterator, output.add('\\'), quoteType);
    } else if (input.value.isDoubleQuote) {
      return StringState(iterator, output.add('"'), quoteType);
    } else if (input.value.isSingleQuote) {
      return StringState(iterator, output.add("'"), quoteType);
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

class StringHexEscapeState extends StringRelatedState {
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
  Location get stringStartLocation => output.location;

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
        output.add(String.fromCharCode(codePoint)),
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

class StringUnicodeEscapeState extends StringRelatedState {
  final QuoteType quoteType;
  final Location escapeStart;

  const StringUnicodeEscapeState(
    super.iterator,
    super.output,
    this.quoteType,
    this.escapeStart,
  );

  @override
  Location get stringStartLocation => output.location;

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

class StringBracedEscapeState extends StringRelatedState {
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
  Location get stringStartLocation => output.location;

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
        output.add(String.fromCharCode(codePoint)),
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
  final bool lastWasUnderscore;

  const IntegerState(
    super.iterator,
    super.output, {
    this.lastWasUnderscore = false,
  });

  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return IntegerState(
        iterator,
        output.add(input.value),
        lastWasUnderscore: false,
      );
    } else if (input.value.isUnderscore) {
      if (lastWasUnderscore) {
        throw InvalidCharacterError(input, 'digit');
      }
      return IntegerState(iterator, output, lastWasUnderscore: true);
    } else if (input.value.isDot) {
      if (lastWasUnderscore) {
        throw InvalidCharacterError(input, 'digit');
      }
      return DecimalInitState(iterator, output.add(input.value));
    } else if (input.value.isExponent) {
      if (lastWasUnderscore) {
        throw InvalidCharacterError(input, 'digit');
      }
      return ExponentInitState(iterator, output.add(input.value));
    } else if (input.value.isOperandDelimiter) {
      if (lastWasUnderscore) {
        throw InvalidCharacterError(input, 'digit');
      }
      iterator.back();
      return ResultState(iterator, NumberToken(output));
    } else {
      throw InvalidCharacterError(input, 'digit, underscore, or dot');
    }
  }
}

class DecimalInitState extends State<Character, Lexeme> {
  const DecimalInitState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return DecimalState(iterator, output.add(input.value));
    } else {
      throw InvalidCharacterError(input, 'digit');
    }
  }
}

class DecimalState extends State<Character, Lexeme> {
  final bool lastWasUnderscore;

  const DecimalState(
    super.iterator,
    super.output, {
    this.lastWasUnderscore = false,
  });

  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return DecimalState(
        iterator,
        output.add(input.value),
        lastWasUnderscore: false,
      );
    } else if (input.value.isUnderscore) {
      if (lastWasUnderscore) {
        throw InvalidCharacterError(input, 'digit');
      }
      return DecimalState(iterator, output, lastWasUnderscore: true);
    } else if (input.value.isExponent) {
      if (lastWasUnderscore) {
        throw InvalidCharacterError(input, 'digit');
      }
      return ExponentInitState(iterator, output.add(input.value));
    } else if (input.value.isOperandDelimiter) {
      if (lastWasUnderscore) {
        throw InvalidCharacterError(input, 'digit');
      }
      iterator.back();
      return ResultState(iterator, NumberToken(output));
    } else {
      throw InvalidCharacterError(input, 'digit or underscore');
    }
  }
}

class ExponentInitState extends State<Character, Lexeme> {
  const ExponentInitState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return ExponentState(iterator, output.add(input.value));
    } else if (input.value.isPlus || input.value.isMinus) {
      return ExponentSignState(iterator, output.add(input.value));
    } else {
      throw InvalidCharacterError(input, 'digit or sign');
    }
  }
}

class ExponentSignState extends State<Character, Lexeme> {
  const ExponentSignState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return ExponentState(iterator, output.add(input.value));
    } else {
      throw InvalidCharacterError(input, 'digit');
    }
  }
}

class ExponentState extends State<Character, Lexeme> {
  final bool lastWasUnderscore;

  const ExponentState(
    super.iterator,
    super.output, {
    this.lastWasUnderscore = false,
  });

  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return ExponentState(
        iterator,
        output.add(input.value),
        lastWasUnderscore: false,
      );
    } else if (input.value.isUnderscore) {
      if (lastWasUnderscore) {
        throw InvalidCharacterError(input, 'digit');
      }
      return ExponentState(iterator, output, lastWasUnderscore: true);
    } else if (input.value.isOperandDelimiter) {
      if (lastWasUnderscore) {
        throw InvalidCharacterError(input, 'digit');
      }
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
      return IdentifierState(iterator, output.add(input.value));
    } else if (input.value.isOperandDelimiter) {
      iterator.back();
      return ResultState(iterator, _identifierOrKeywordToken(output));
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
      return ResultState(iterator, EqualToken(output.add(input.value)));
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
      return ResultState(
        iterator,
        GreaterOrEqualToken(output.add(input.value)),
      );
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
      return ResultState(iterator, LessOrEqualToken(output.add(input.value)));
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
    if (input.value.isPipe) {
      // Consume the second '|' but keep the canonical operator name '|'
      return ResultState(iterator, PipeToken(output));
    } else if (input.value.isOperatorDelimiter) {
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
    if (input.value.isAmpersand) {
      // Consume the second '&' but keep the canonical operator name '&'
      return ResultState(iterator, AmpersandToken(output));
    } else if (input.value.isOperatorDelimiter) {
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
      return ResultState(iterator, NotEqualToken(output.add(input.value)));
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
    if (input.value.isForwardSlash) {
      return InitState(iterator);
    } else if (input.value.isAsterisk) {
      return this;
    } else {
      return StartMultiLineCommentState(iterator);
    }
  }
}

class ResultState extends State<void, Token> {
  const ResultState(super.iterator, super.output);
}
