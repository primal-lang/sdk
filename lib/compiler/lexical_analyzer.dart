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
    if (state == State.init) {
      if (character.isDigit) {
        accumulated += character;
        state = State.number;
      } else if (character.isLetter) {
        accumulated += character;
        state = State.symbol;
      } else if (character.isSeparator) {
        result.add(Token(value: character));
      }
    } else if (state == State.number) {
      if (character.isDigit) {
        accumulated += character;
      } else if (character.isDelimiter) {
        _setToken(character);
      }
    } else if (state == State.symbol) {
      if (character.isLetter || character.isDigit) {
        accumulated += character;
      } else if (character.isDelimiter) {
        _setToken(character);
      }
    }
  }

  void _setToken(String character) {
    result.add(Token(value: accumulated));
    accumulated = '';

    if (character.isSeparator) {
      result.add(Token(value: character));
    }
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
  comma,
  open_parenthesis,
  close_parenthesis,
  equals,
}
