import 'dart:math';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class UuidV4 extends NativeFunctionTerm {
  const UuidV4()
    : super(
        name: 'uuid.v4',
        parameters: const <Parameter>[],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class TermWithArguments extends NativeFunctionTermWithArguments {
  const TermWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    final Random random = Random.secure();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // Set version to 4 (0100 in binary)
    bytes[6] = (bytes[6] & 0x0f) | 0x40;

    // Set variant to RFC 4122 (10xx in binary)
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final String hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    final String uuid =
        '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';

    return StringTerm(uuid);
  }
}
