import 'dart:js_interop';
import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/syntactic/expression.dart';

@JS('compileInput')
external set compileInput(JSFunction v);

@JS('compileExpression')
external set compileExpression(JSFunction v);

@JS('runtimeWarnings')
external set runtimeWarnings(JSFunction v);

@JS('runtimeHasMain')
external set runtimeHasMain(JSFunction v);

@JS('runtimeExecuteMain')
external set runtimeExecuteMain(JSFunction v);

@JS('runtimeReduce')
external set runtimeReduce(JSFunction v);

@JS('intermediateCodeEmpty')
external set intermediateCodeEmpty(JSFunction v);

void main(List<String> args) {
  const Compiler compiler = Compiler();
  compileInput = compiler.compile.toJS;
  compileExpression = compiler.expression.toJS;

  runtimeWarnings = runtimeWarningsHelper.toJS;
  runtimeHasMain = runtimeHasMainHelper.toJS;
  runtimeExecuteMain = runtimeExecuteMainHelper.toJS;
  runtimeReduce = runtimeReduceHelper.toJS;

  intermediateCodeEmpty = IntermediateCode.empty.toJS;
}

List<String> runtimeWarningsHelper(IntermediateCode code) {
  return code.warnings.map((e) => e.toString()).toList();
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

  return runtime.evaluate(expression);
}
