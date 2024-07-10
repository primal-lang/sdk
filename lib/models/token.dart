class Token {
  final String value;

  const Token._({required this.value});

  factory Token.create(String value) => Token._(value: value);
}
