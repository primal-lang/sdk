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

  /// Peeks at the element [offset] positions ahead without consuming.
  /// Returns null if the offset is beyond the end of the list.
  ///
  /// Unlike [peek] which only sees the current position, this method
  /// enables multi-token lookahead for disambiguation (e.g., lambda vs
  /// grouped expression).
  T? peekAt(int offset) {
    final int targetIndex = _index + offset;
    if (targetIndex < _list.length) {
      return _list[targetIndex];
    }
    return null;
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

  bool back() {
    if (_index > 0) {
      _index--;
      return true;
    }
    return false;
  }
}
