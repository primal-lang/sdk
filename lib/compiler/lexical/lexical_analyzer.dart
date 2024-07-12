import 'package:characters/characters.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/models/state.dart';
import 'package:dry/extensions/string_extensions.dart';
import 'package:dry/utils/list_iterator.dart';

class LexicalAnalyzer {
  final String source;

  LexicalAnalyzer({required this.source});

  List<Token> analyze() {
    final List<Token> result = [];
    final ListIterator<String> iterator = ListIterator(
      [...source.characters.toList(), '\n'],
    );
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

class InitState extends State<void, String> {
  const InitState(super.accumulated);

  factory InitState.empty() => const InitState(null);

  @override
  State process(String value) {
    if (value.isQuote) {
      return const StringState('');
    } else if (value.isDigit) {
      return NumberState(value);
    } else if (value.isLetter) {
      return SymbolState(value);
    } else if (value.isSeparator) {
      return ResultState([Token.separator(value)]);
    } else {
      return this;
    }
  }
}

class StringState extends State<String, String> {
  const StringState(super.accumulated);

  @override
  State process(String value) {
    if (value.isQuote) {
      return ResultState([Token.string(accumulated)]);
    } else {
      return StringState(accumulated + value);
    }
  }
}

class NumberState extends State<String, String> {
  const NumberState(super.accumulated);

  @override
  State process(String value) {
    if (value.isDigit || value.isDot) {
      return NumberState(accumulated + value);
    } else if (value.isDelimiter) {
      final List<Token> tokens = [];

      try {
        num.parse(accumulated);
        tokens.add(Token.number(accumulated));
      } catch (e) {
        throw Exception(
            'Invalid number format $accumulated in state NumberState');
      }

      if (value.isSeparator) {
        tokens.add(Token.separator(value));
      }

      return ResultState(tokens);
    } else {
      throw Exception('Unknown character $value for state NumberState');
    }
  }
}

class SymbolState extends State<String, String> {
  const SymbolState(super.accumulated);

  @override
  State process(String value) {
    if (value.isLetter || value.isDigit) {
      return SymbolState(accumulated + value);
    } else if (value.isDelimiter) {
      final List<Token> tokens = [];

      if (accumulated.isBoolean) {
        tokens.add(Token.boolean(accumulated));
      } else {
        tokens.add(Token.symbol(accumulated));
      }

      if (value.isSeparator) {
        tokens.add(Token.separator(value));
      }

      return ResultState(tokens);
    } else {
      throw Exception('Unknown character $value for state SymbolState');
    }
  }
}

class ResultState extends State<List<Token>, void> {
  const ResultState(super.accumulated);
}
