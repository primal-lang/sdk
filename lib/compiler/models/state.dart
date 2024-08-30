import 'package:primal/utils/list_iterator.dart';

class State<I, O> {
  final O output;
  final ListIterator<I> iterator;

  const State(this.iterator, this.output);

  State get next => process(iterator.next);

  State process(I input) => this;
}
