import 'package:dry/compiler/errors/syntactic_error.dart';

class ListIterator<T> {
  int _index = 0;
  final List<T> _list;

  ListIterator(this._list);

  bool get hasNext => _index < _list.length;

  void consume() {
    if (_index < _list.length) {
      _index++;
    } else {
      throw SyntacticError.unexpectedEndOfFile();
    }
  }

  T get peek {
    if (_index < _list.length) {
      return _list[_index];
    } else {
      throw SyntacticError.unexpectedEndOfFile();
    }
  }

  T get next {
    if (_index < _list.length) {
      return _list[_index++];
    } else {
      throw SyntacticError.unexpectedEndOfFile();
    }
  }
}
