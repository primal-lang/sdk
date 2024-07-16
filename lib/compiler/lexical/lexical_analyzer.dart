import 'package:dry/compiler/input/lexeme.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/models/analyzer.dart';
import 'package:dry/compiler/models/state.dart';
import 'package:dry/extensions/string_extensions.dart';
import 'package:dry/utils/list_iterator.dart';

class LexicalAnalyzer extends Analyzer<List<Lexeme>, List<Token>> {
  const LexicalAnalyzer(super.input);

  @override
  List<Token> analyze() {
    final List<Token> result = [];
    final ListIterator<Lexeme> iterator = ListIterator(input);
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

class InitState extends State<Lexeme, void> {
  const InitState([super.output]);

  @override
  State process(Lexeme input) {
    if (input.isQuote) {
      return const StringState();
    } else if (input.isDigit) {
      return NumberState(LexemeList([input]));
    } else if (input.isLetter) {
      return SymbolState(LexemeList([input]));
    } else if (input.isSeparator) {
      return ResultState([Token.separator(input.value)]);
    } else {
      return this;
    }
  }
}

class StringState extends State<Lexeme, LexemeList> {
  const StringState([super.output = const LexemeList([])]);

  @override
  State process(Lexeme input) {
    if (input.isQuote) {
      return ResultState([Token.string(output.string)]);
    } else {
      return StringState(output.add(input));
    }
  }
}

class NumberState extends State<Lexeme, LexemeList> {
  const NumberState(super.output);

  @override
  State process(Lexeme input) {
    if (input.isDigit || input.isDot) {
      return NumberState(output.add(input));
    } else if (input.isDelimiter) {
      final List<Token> tokens = [];

      try {
        final String value = output.string;
        num.parse(value);
        tokens.add(Token.number(value));
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

class SymbolState extends State<Lexeme, LexemeList> {
  const SymbolState(super.output);

  @override
  State process(Lexeme input) {
    if (input.isLetter || input.isDigit) {
      return SymbolState(output.add(input));
    } else if (input.isDelimiter) {
      final List<Token> tokens = [];
      final String value = output.string;

      if (value.isBoolean) {
        tokens.add(Token.boolean(value));
      } else {
        tokens.add(Token.symbol(value));
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

class ResultState extends State<void, List<Token>> {
  const ResultState(super.output);
}

class LexemeList {
  final List<Lexeme> list;

  const LexemeList([this.list = const []]);

  String get string => list.map((e) => e.value).toList().join();

  LexemeList add(Lexeme lexeme) => LexemeList([...list, lexeme]);
}
