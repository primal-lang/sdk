abstract class State<T> {
  const State();

  State process(T value);
}