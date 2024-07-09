import 'package:characters/characters.dart';
import 'package:dry/models/token.dart';

class LexicalAnalyzer {
  final String source;

  const LexicalAnalyzer({required this.source});

  List<Token> analyze() {
    final CharList charList = CharList(list: source.characters.toList());

    while (charList.hasNext) {
      print(charList.next);
    }

    return [];
  }
}

class CharList {
  int index = 0;
  final List<String> list;

  CharList({required this.list});

  bool get hasNext => index < list.length;

  String get next => list[index++];
}
