class State<O, I> {
  final O output;

  const State(this.output);

  State process(I input) => this;
}
