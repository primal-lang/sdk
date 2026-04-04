class Stack<E> {
  final List<E> _list;

  Stack([this._list = const []]);

  Stack<E> push(E value) => Stack([..._list, value]);

  (E, Stack<E>) pop() =>
      (_list.last, Stack(_list.sublist(0, _list.length - 1)));

  E get peek => _list.last;

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  int get length => _list.length;
}
