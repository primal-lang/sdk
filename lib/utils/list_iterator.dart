class ListIterator<T> {
  int index = 0;
  final List<T> list;

  ListIterator(this.list);

  bool get hasNext => index < list.length;

  T get next => list[index++];
}
