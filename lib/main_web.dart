import 'package:js/js.dart';
import 'package:purified/compiler/compiler.dart';
import 'package:purified/compiler/runtime/runtime.dart';
import 'package:purified/compiler/semantic/intermediate_code.dart';
import 'package:purified/compiler/syntactic/expression.dart';

@JS('compileInput')
external set compileInput(Function v);

@JS('compileExpression')
external set compileExpression(Function v);

@JS('runtimeWarnings')
external set runtimeWarnings(Function v);

@JS('runtimeHasMain')
external set runtimeHasMain(Function v);

@JS('runtimeExecuteMain')
external set runtimeExecuteMain(Function v);

@JS('runtimeReduce')
external set runtimeReduce(Function v);

@JS('intermediateCodeEmpty')
external set intermediateCodeEmpty(Function v);

void main(List<String> args) {
  const Compiler compiler = Compiler();
  compileInput = allowInterop(compiler.compile);
  compileExpression = allowInterop(compiler.expression);

  runtimeWarnings = allowInterop(runtimeWarningsHelper);
  runtimeHasMain = allowInterop(runtimeHasMainHelper);
  runtimeExecuteMain = allowInterop(runtimeExecuteMainHelper);
  runtimeReduce = allowInterop(runtimeReduceHelper);

  intermediateCodeEmpty = allowInterop(IntermediateCode.empty);
}

List<String> runtimeWarningsHelper(IntermediateCode code) {
  return code.warnings.map((e) => e.message).toList();
}

bool runtimeHasMainHelper(IntermediateCode code) {
  final Runtime runtime = Runtime(code);

  return runtime.hasMain;
}

String runtimeExecuteMainHelper(IntermediateCode code) {
  final Runtime runtime = Runtime(code);

  return runtime.executeMain();
}

String runtimeReduceHelper(IntermediateCode code, Expression expression) {
  final Runtime runtime = Runtime(code);

  return runtime.reduce(expression);
}
