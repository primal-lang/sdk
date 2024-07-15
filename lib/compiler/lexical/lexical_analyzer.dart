import 'package:dry/compiler/analyzer.dart';
import 'package:dry/compiler/input/character.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/models/state.dart';
import 'package:dry/extensions/string_extensions.dart';
import 'package:dry/utils/list_iterator.dart';

class LexicalAnalyzer extends Analyzer<List<Character>, List<Token>> {
  const LexicalAnalyzer(super.input);

  @override
  List<Token> analyze() {
    final List<Token> result = [];
    final ListIterator<Character> iterator = ListIterator(input);
    State state = InitState.empty();

    while (iterator.hasNext) {
      state = state.process(iterator.next);

      if (state is ResultState) {
        result.addAll(state.output);
        state = InitState.empty();
      }
    }

    return result;
  }
}

class InitState extends State<void, Character> {
  const InitState(super.output);

  factory InitState.empty() => const InitState(null);

  @override
  State process(Character input) {
    if (input.isQuote) {
      return const StringState('');
    } else if (input.isDigit) {
      return NumberState(input.value);
    } else if (input.isLetter) {
      return SymbolState(input.value);
    } else if (input.isSeparator) {
      return ResultState([Token.separator(input.value)]);
    } else {
      return this;
    }
  }
}

class StringState extends State<String, Character> {
  const StringState(super.output);

  @override
  State process(Character input) {
    if (input.isQuote) {
      return ResultState([Token.string(output)]);
    } else {
      return StringState(output + input.value);
    }
  }
}

class NumberState extends State<String, Character> {
  const NumberState(super.output);

  @override
  State process(Character input) {
    if (input.isDigit || input.isDot) {
      return NumberState(output + input.value);
    } else if (input.isDelimiter) {
      final List<Token> tokens = [];

      try {
        num.parse(output);
        tokens.add(Token.number(output));
      } catch (e) {
        throw Exception('Invalid number $output at ${input.location}');
      }

      if (input.isSeparator) {
        tokens.add(Token.separator(input.value));
      }

      return ResultState(tokens);
    } else {
      throw Exception('Invalid character $input');
    }
  }
}

class SymbolState extends State<String, Character> {
  const SymbolState(super.output);

  @override
  State process(Character input) {
    if (input.isLetter || input.isDigit) {
      return SymbolState(output + input.value);
    } else if (input.isDelimiter) {
      final List<Token> tokens = [];

      if (output.isBoolean) {
        tokens.add(Token.boolean(output));
      } else {
        tokens.add(Token.symbol(output));
      }

      if (input.isSeparator) {
        tokens.add(Token.separator(input.value));
      }

      return ResultState(tokens);
    } else {
      throw Exception('Invalid character $input');
    }
  }
}

class ResultState extends State<List<Token>, void> {
  const ResultState(super.output);
}
