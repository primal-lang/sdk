import 'package:characters/characters.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/models/state.dart';
import 'package:dry/extensions/string_extensions.dart';
import 'package:dry/utils/list_iterator.dart';

class LexicalAnalyzer {
  final String source;

  const LexicalAnalyzer({required this.source});

  List<Token> analyze() {
    final List<Token> result = [];
    final ListIterator<Character> iterator = _iterator(source);
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

  ListIterator<Character> _iterator(String source) {
    final List<Character> characters = [];
    final List<String> rows = source.split('\n');

    for (int i = 0; i < rows.length; i++) {
      final List<String> columns = rows[i].characters.toList();

      for (int j = 0; j < columns.length; j++) {
        characters.add(Character(
          value: columns[j],
          row: i + 1,
          column: j + 1,
        ));
      }
    }

    characters.add(Character(
      value: '\n',
      row: rows.length + 1,
      column: 0,
    ));

    return ListIterator(characters);
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
        throw Exception(
            'Invalid number format $accumulated in state NumberState');
      }

      if (value.isSeparator) {
        tokens.add(Token.separator(value.value));
      }

      return ResultState(tokens);
    } else {
      throw Exception('Unknown character $value for state NumberState');
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
      throw Exception('Unknown character $value for state SymbolState');
    }
  }
}

class ResultState extends State<List<Token>, void> {
  const ResultState(super.accumulated);
}

class Character {
  final String value;
  final int row;
  final int column;

  const Character({
    required this.value,
    required this.row,
    required this.column,
  });

  bool get isDigit => value.isDigit;

  bool get isLetter => value.isLetter;

  bool get isWhitespace => value.isWhitespace;

  bool get isQuote => value.isQuote;

  bool get isDot => value.isDot;

  bool get isComma => value.isComma;

  bool get isEquals => value.isEquals;

  bool get isBoolean => value.isBoolean;

  bool get isSeparator => value.isSeparator;

  bool get isDelimiter => value.isDelimiter;
}
