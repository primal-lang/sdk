import 'package:dry/compiler/file/file_analyzer.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/models/state.dart';
import 'package:dry/extensions/string_extensions.dart';
import 'package:dry/utils/list_iterator.dart';

class LexicalAnalyzer {
  final List<Character> characters;

  const LexicalAnalyzer({required this.characters});

  List<Token> analyze() {
    final List<Token> result = [];
    final ListIterator<Character> iterator = ListIterator(characters);
    State state = InitState.empty();

    while (iterator.hasNext) {
      state = state.process(iterator.next);

      if (state is ResultState) {
        result.addAll(state.accumulated);
        state = InitState.empty();
      }
    }

    return result;
  }
}

class InitState extends State<void, Character> {
  const InitState(super.accumulated);

  factory InitState.empty() => const InitState(null);

  @override
  State process(Character value) {
    if (value.isQuote) {
      return const StringState('');
    } else if (value.isDigit) {
      return NumberState(value.value);
    } else if (value.isLetter) {
      return SymbolState(value.value);
    } else if (value.isSeparator) {
      return ResultState([Token.separator(value.value)]);
    } else {
      return this;
    }
  }
}

class StringState extends State<String, Character> {
  const StringState(super.accumulated);

  @override
  State process(Character value) {
    if (value.isQuote) {
      return ResultState([Token.string(accumulated)]);
    } else {
      return StringState(accumulated + value.value);
    }
  }
}

class NumberState extends State<String, Character> {
  const NumberState(super.accumulated);

  @override
  State process(Character value) {
    if (value.isDigit || value.isDot) {
      return NumberState(accumulated + value.value);
    } else if (value.isDelimiter) {
      final List<Token> tokens = [];

      try {
        num.parse(accumulated);
        tokens.add(Token.number(accumulated));
      } catch (e) {
        throw Exception('Invalid number $accumulated at ${value.location}');
      }

      if (value.isSeparator) {
        tokens.add(Token.separator(value.value));
      }

      return ResultState(tokens);
    } else {
      throw Exception('Invalid character $value');
    }
  }
}

class SymbolState extends State<String, Character> {
  const SymbolState(super.accumulated);

  @override
  State process(Character value) {
    if (value.isLetter || value.isDigit) {
      return SymbolState(accumulated + value.value);
    } else if (value.isDelimiter) {
      final List<Token> tokens = [];

      if (accumulated.isBoolean) {
        tokens.add(Token.boolean(accumulated));
      } else {
        tokens.add(Token.symbol(accumulated));
      }

      if (value.isSeparator) {
        tokens.add(Token.separator(value.value));
      }

      return ResultState(tokens);
    } else {
      throw Exception('Invalid character $value');
    }
  }
}

class ResultState extends State<List<Token>, void> {
  const ResultState(super.accumulated);
}
