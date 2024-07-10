import 'package:characters/characters.dart';
import 'package:dry/extensions/string_extensions.dart';
import 'package:dry/models/token.dart';
import 'package:dry/utils/list_iterator.dart';

class LexicalAnalyzer {
  final String source;
  State state = State.init;

  LexicalAnalyzer({required this.source});

  List<Token> analyze() {
    final ListIterator<String> iterator = ListIterator(
      [...source.characters.toList(), '\n'],
    );
    final StateMachine stateMachine = StateMachine();

    while (iterator.hasNext) {
      stateMachine.process(iterator.next);
    }

    return stateMachine.result;
  }
}

class StateMachine {
  String accumulated = '';
  State state = State.init;
  final List<Token> result = [];

  void process(String character) {
    switch (state) {
      case State.init:
        _processInit(character);
        break;
      case State.string:
        _processString(character);
        break;
      case State.number:
        _processNumber(character);
        break;
      case State.symbol:
        _processSymbol(character);
        break;
    }
  }

  void _processInit(String character) {
    if (character.isQuote) {
      accumulated += character;
      state = State.string;
    } else if (character.isDigit) {
      accumulated += character;
      state = State.number;
    } else if (character.isLetter) {
      accumulated += character;
      state = State.symbol;
    } else if (character.isSeparator) {
      result.add(Token.separator(character));
    }
  }

  void _processString(String character) {
    if (character.isQuote) {
      accumulated += character;
      _setToken(character);
    } else {
      accumulated += character;
    }
  }

  void _processNumber(String character) {
    if (character.isDigit || character.isDot) {
      accumulated += character;
    } else if (character.isDelimiter) {
      _setToken(character);
    }
  }

  void _processSymbol(String character) {
    if (character.isLetter || character.isDigit) {
      accumulated += character;
    } else if (character.isDelimiter) {
      _setToken(character);
    }
  }

  void _setToken(String character) {
    switch (state) {
      case State.string:
        final String value = accumulated.substring(1, accumulated.length - 1);
        result.add(Token.string(value));
        break;
      case State.number:
        num.parse(accumulated);
        result.add(Token.number(accumulated));
        break;
      case State.symbol:
        if (accumulated.isBoolean) {
          result.add(Token.boolean(accumulated));
        } else {
          result.add(Token.symbol(accumulated));
        }
        break;
      case State.init:
        break;
    }

    if (character.isSeparator) {
      result.add(Token.separator(character));
    }

    accumulated = '';
    state = State.init;
  }
}

enum State {
  init,
  string,
  number,
  symbol,
}
