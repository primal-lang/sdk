import 'package:characters/characters.dart';
import 'package:dry/extensions/string_extensions.dart';
import 'package:dry/models/token.dart';

class LexicalAnalyzer {
  final String source;
  State state = State.init;

  LexicalAnalyzer({required this.source});

  List<Token> analyze() {
    final CharList charList = CharList(
      list: [...source.characters.toList(), '\n'],
    );
    final LexicalStateMachine stateMachine = LexicalStateMachine();

    while (charList.hasNext) {
      stateMachine.process(charList.next);
    }

    return stateMachine.result;
  }
}

class LexicalStateMachine {
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
      result.add(Token.create(character));
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
    if (state == State.number) {
      num.parse(accumulated);
    } else if (state == State.string) {
      accumulated = accumulated.substring(1, accumulated.length - 1);
    }

    result.add(Token.create(accumulated));

    if (character.isSeparator) {
      result.add(Token.create(character));
    }

    accumulated = '';
    state = State.init;
  }
}

class CharList {
  int index = 0;
  final List<String> list;

  CharList({required this.list});

  bool get hasNext => index < list.length;

  String get next => list[index++];
}

enum State {
  init,
  string,
  number,
  symbol,
}
