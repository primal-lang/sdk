class State<A, V> {
  final A accumulated;

  const State(this.accumulated);

  State process(V value) => this;
}
