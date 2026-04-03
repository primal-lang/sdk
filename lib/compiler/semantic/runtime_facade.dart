import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/runtime/runtime_input.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/lowerer.dart';
import 'package:primal/compiler/semantic/runtime_input_builder.dart';
import 'package:primal/compiler/semantic/semantic_analyzer.dart';
import 'package:primal/compiler/syntactic/expression.dart';

class RuntimeFacade {
  final IntermediateCode intermediateCode;
  final RuntimeInput _runtimeInput;
  final Runtime _runtime;

  RuntimeFacade._internal(this.intermediateCode, this._runtimeInput)
    : _runtime = Runtime(_runtimeInput);

  factory RuntimeFacade(IntermediateCode code) {
    final RuntimeInput input = const RuntimeInputBuilder().build(code);
    return RuntimeFacade._internal(code, input);
  }

  bool get hasMain => intermediateCode.containsFunction('main');

  Expression mainExpression(List<String> arguments) {
    const Compiler compiler = Compiler();

    final FunctionNode? main = _runtimeInput.getFunction('main');

    if ((main != null) && main.parameters.isNotEmpty) {
      return compiler.expression(
        'main(${arguments.map((e) => '"$e"').join(', ')})',
      );
    } else {
      return compiler.expression('main()');
    }
  }

  String executeMain([List<String>? arguments]) {
    final Expression expression = mainExpression(arguments ?? []);

    return evaluate(expression);
  }

  String evaluate(Expression expression) {
    final Node lowered = const Lowerer().lowerExpression(expression);
    final Node validated = SemanticAnalyzer.validateExpression(
      lowered,
      _runtimeInput.functions,
    );
    final Node result = validated.evaluate();

    return _runtime.format(result.native()).toString();
  }

  dynamic format(dynamic value) => _runtime.format(value);
}
