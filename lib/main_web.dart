import 'package:dry/compiler/compiler.dart';
import 'package:dry/compiler/runtime/runtime.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:js/js.dart';

@JS('compileInput')
external set compileInput(Function v);

@JS('compileExpression')
external set compileExpression(Function v);

@JS('runtimeReduce')
external set runtimeHasMain(Function v);

@JS('runtimeReduce')
external set runtimeExecuteMain(Function v);

@JS('runtimeReduce')
external set runtimeReduce(Function v);

void main(List<String> args) {
  const Compiler compiler = Compiler();
  compileInput = allowInterop(compiler.compile);
  compileExpression = allowInterop(compiler.expression);

  runtimeHasMain = allowInterop(runtimeHasMainHelper);
  runtimeExecuteMain = allowInterop(runtimeExecuteMainHelper);
  runtimeReduce = allowInterop(runtimeReduceHelper);
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
