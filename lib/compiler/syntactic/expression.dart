// string
// number
// boolean
// symbol
// function_call
class Expression<T> {
  final T value;

  const Expression({
    required this.value,
  });

  static Expression<String> string(String value) => Expression(
        value: value,
      );
}
