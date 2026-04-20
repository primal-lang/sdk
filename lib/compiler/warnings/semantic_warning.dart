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

class UnusedLambdaParameterWarning extends SemanticWarning {
  const UnusedLambdaParameterWarning({
    required String parameter,
    String? inFunction,
  }) : super(
         inFunction != null
             ? 'Unused lambda parameter "$parameter" in function "$inFunction"'
             : 'Unused lambda parameter "$parameter"',
       );
}
