import 'package:primal/compiler/warnings/generic_warning.dart';

class SemanticWarning extends GenericWarning {
  const SemanticWarning(super.message);
}

class UnusedParameterWarning extends SemanticWarning {
  const UnusedParameterWarning({
    required String function,
    required String parameter,
  }) : super('Unused parameter "$parameter" in function "$function"');
}
