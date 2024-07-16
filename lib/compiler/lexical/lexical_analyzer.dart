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
    if (input.isQuote) {
      return StringState(Lexeme(
          value: '',
          location: Location(
            row: input.location.row,
            column: input.location.column + 1,
          )));
    } else if (input.isDigit) {
      return NumberState(Lexeme.fromCharacter(input));
    } else if (input.isLetter) {
      return SymbolState(Lexeme.fromCharacter(input));
    } else if (input.isSeparator) {
      return ResultState([Token.separator(Lexeme.fromCharacter(input))]);
    } else {
      return this;
    }
  }
}

class StringState extends State<Character, Lexeme> {
  const StringState(super.output);

  @override
  State process(Character input) {
    if (input.isQuote) {
      return ResultState([Token.string(output)]);
    } else {
      return StringState(output.add(input));
    }
  }
}

class NumberState extends State<Character, Lexeme> {
  const NumberState(super.output);

  @override
  State process(Character input) {
    if (input.isDigit || input.isDot) {
      return NumberState(output.add(input));
    } else if (input.isDelimiter) {
      final List<Token> tokens = [];

      try {
        num.parse(output.value);
        tokens.add(Token.number(output));
      } catch (e) {
        throw Exception('Invalid number $output at ${input.location}');
      }

      if (input.isSeparator) {
        tokens.add(Token.separator(Lexeme.fromCharacter(input)));
      }

      return ResultState(tokens);
    } else {
      throw Exception('Invalid character $input');
    }
  }
}

class SymbolState extends State<Character, Lexeme> {
  const SymbolState(super.output);

  @override
  State process(Character input) {
    if (input.isLetter || input.isDigit) {
      return SymbolState(output.add(input));
    } else if (input.isDelimiter) {
      final List<Token> tokens = [];

      if (output.value.isBoolean) {
        tokens.add(Token.boolean(output));
      } else {
        tokens.add(Token.symbol(output));
      }

      if (input.isSeparator) {
        tokens.add(Token.separator(Lexeme.fromCharacter(input)));
      }

      return ResultState(tokens);
    } else {
      throw Exception('Invalid character $input');
    }
  }
}

class ResultState extends State<void, List<Token>> {
  const ResultState(super.output);
}

class Lexeme {
  final String value;
  final Location location;

  const Lexeme({
    required this.value,
    required this.location,
  });

  factory Lexeme.fromCharacter(Character character) => Lexeme(
        value: character.value,
        location: character.location,
      );

  Lexeme add(Character character) => Lexeme(
        value: value + character.value,
        location: location,
      );
}
