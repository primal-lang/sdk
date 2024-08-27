import 'package:primal/utils/list_iterator.dart';

class State<I, O> {
  final O output;
  final ListIterator<I> iterator;

  const State(this.iterator, this.output);

  State process(I input) => this;
}
