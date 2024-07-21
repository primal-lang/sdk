class Stack<E> {
  final List<E> _list;

  Stack([this._list = const []]);

  Stack<E> push(E value) => Stack([..._list, value]);

  E pop() => _list.removeLast();

  E get peek => _list.last;

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  int get length => _list.length;
}
