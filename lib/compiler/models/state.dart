class State<I, O> {
  final O output;

  const State(this.output);

  State process(I input) => this;
}
