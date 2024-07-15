abstract class Analyzer<I, O> {
  final I input;

  const Analyzer(this.input);

  O analyze();
}
