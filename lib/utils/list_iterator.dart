import 'package:dry/compiler/errors/syntactic_error.dart';

class ListIterator<T> {
  int index = 0;
  final List<T> list;

  ListIterator(this.list);

  bool get hasNext => index < list.length;

  void consume() {
    if (index < list.length) {
      index++;
    } else {
      throw SyntacticError.unexpectedEndOfFile();
    }
  }

  T get peek {
    if (index < list.length) {
      return list[index];
    } else {
      throw SyntacticError.unexpectedEndOfFile();
    }
  }

  T get next {
    if (index < list.length) {
      return list[index++];
    } else {
      throw SyntacticError.unexpectedEndOfFile();
    }
  }
}
