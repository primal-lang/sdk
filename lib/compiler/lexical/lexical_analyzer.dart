import 'package:dry/compiler/errors/lexical_error.dart';
import 'package:dry/compiler/input/character.dart';
import 'package:dry/compiler/input/location.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/models/analyzer.dart';
import 'package:dry/compiler/models/state.dart';
import 'package:dry/extensions/string_extensions.dart';
import 'package:dry/utils/list_iterator.dart';

class LexicalAnalyzer extends Analyzer<List<Character>, List<Token>> {
  const LexicalAnalyzer(super.input);

  @override
  List<Token> analyze() {
    final List<Token> result = [];
    final ListIterator<Character> iterator = ListIterator(input);
    State state = const InitState();

    while (iterator.hasNext) {
      state = state.process(iterator.next);

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
  State process(Character input) {
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
    } else if (input.isHashtag) {
      return const CommentState();
    } else if (input.isSeparator) {
      return ResultState([input.separator]);
    } else {
      return this;
    }
  }
}

class CommentState extends State<Character, void> {
  const CommentState([super.output]);

  @override
  State process(Character input) {
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
  State process(Character input) {
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
  State process(Character input) {
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
  State process(Character input) {
    if (input.isDigit) {
      return IntegerState(output.add(input));
    } else {
      throw LexicalError.invalidCharacter(input);
    }
  }
}

class IntegerState extends State<Character, Lexeme> {
  const IntegerState(super.output);

  @override
  State process(Character input) {
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
      throw LexicalError.invalidCharacter(input);
    }
  }
}

class DecimalState extends State<Character, Lexeme> {
  const DecimalState(super.output);

  @override
  State process(Character input) {
    if (input.isDigit) {
      return DecimalState(output.add(input));
    } else if (input.isDelimiter) {
      final List<Token> tokens = [NumberToken(output)];

      if (input.isSeparator) {
        tokens.add(input.separator);
      }

      return ResultState(tokens);
    } else {
      throw LexicalError.invalidCharacter(input);
    }
  }
}

class SymbolState extends State<Character, Lexeme> {
  const SymbolState(super.output);

  @override
  State process(Character input) {
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
      throw LexicalError.invalidCharacter(input);
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
  String toString() => '$value at $location';
}
