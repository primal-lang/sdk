import 'package:primal/compiler/errors/syntactic_error.dart';

class ListIterator<T> {
  int _index = 0;
  final List<T> _list;

  ListIterator(this._list);

  bool get hasNext => _index < _list.length;

  bool get isAtEnd => _index == _list.length;

  T? get peek {
    if (hasNext) {
      return _list[_index];
    } else {
      return null;
    }
  }

  T? get previous {
    if (_index > 0) {
      return _list[_index - 1];
    } else {
      return null;
    }
  }

  T get next {
    if (hasNext) {
      return _list[_index++];
    } else {
      throw const UnexpectedEndOfFileError();
    }
  }

  T get last {
    if (_list.isEmpty) {
      throw const UnexpectedEndOfFileError();
    }
    return _list.last;
  }

  void advance() {
    if (hasNext) {
      _index++;
    }
  }

  void back() {
    if (_index > 0) {
      _index--;
    }
  }
}
