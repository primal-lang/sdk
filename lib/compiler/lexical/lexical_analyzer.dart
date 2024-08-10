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
    if (input.isDoubleQuote) {
      return StringDoubleQuoteState(Lexeme(
        value: '',
        location: input.location,
      ));
    } else if (input.isSingleQuote) {
      return StringSingleQuoteState(Lexeme(
        value: '',
        location: input.location,
      ));
    } else if (input.isDash) {
      return NegativeNumberState(input.lexeme);
    } else if (input.isDigit) {
      return IntegerState(input.lexeme);
    } else if (input.isLetter) {
      return SymbolState(input.lexeme);
    } else if (input.isSlash) {
      return SlashState(input.lexeme);
    } else if (input.isSeparator) {
      return ResultState([input.separator]);
    } else {
      return this;
    }
  }
}

class SlashState extends State<Character, Lexeme> {
  const SlashState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.isSlash) {
      return const CommentState();
    } else {
      return ResultState([SlashToken(output)]);
    }
  }
}

class CommentState extends State<Character, void> {
  const CommentState([super.output]);

  @override
  State process(Character input, Character? next) {
    if (!input.isNewLine) {
      return const CommentState();
    } else {
      return const InitState();
    }
  }
}

class StringDoubleQuoteState extends State<Character, Lexeme> {
  const StringDoubleQuoteState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.isDoubleQuote) {
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
    if (input.isSingleQuote) {
      return ResultState([StringToken(output)]);
    } else {
      return StringSingleQuoteState(output.add(input));
    }
  }
}

class NegativeNumberState extends State<Character, Lexeme> {
  const NegativeNumberState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.isDigit) {
      return IntegerState(output.add(input));
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class IntegerState extends State<Character, Lexeme> {
  const IntegerState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.isDigit) {
      return IntegerState(output.add(input));
    } else if (input.isDot) {
      return DecimalState(output.add(input));
    } else if (input.isDelimiter) {
      final List<Token> tokens = [NumberToken(output)];

      if (input.isSeparator) {
        tokens.add(input.separator);
      }

      return ResultState(tokens);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class DecimalState extends State<Character, Lexeme> {
  const DecimalState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.isDigit) {
      return DecimalState(output.add(input));
    } else if (input.isDelimiter) {
      final List<Token> tokens = [NumberToken(output)];

      if (input.isSeparator) {
        tokens.add(input.separator);
      }

      return ResultState(tokens);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class SymbolState extends State<Character, Lexeme> {
  const SymbolState(super.output);

  @override
  State process(Character input, Character? next) {
    if (input.isLetter || input.isDigit || input.isUnderscore) {
      return SymbolState(output.add(input));
    } else if (input.isDelimiter) {
      final List<Token> tokens = [];

      if (output.value.isBoolean) {
        tokens.add(BooleanToken(output));
      } else {
        tokens.add(SymbolToken(output));
      }

      if (input.isSeparator) {
        tokens.add(input.separator);
      }

      return ResultState(tokens);
    } else {
      throw InvalidCharacterError(input);
    }
  }
}

class ResultState extends State<void, List<Token>> {
  const ResultState(super.output);
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
