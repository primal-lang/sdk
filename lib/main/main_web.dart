import 'dart:js_interop';

import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/runtime_facade.dart';
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

@JS('disposeCode')
external set disposeCode(JSFunction v);

@JS('disposeExpression')
external set disposeExpression(JSFunction v);

final Map<int, IntermediateCode> _codeRegistry = {};
final Map<int, Expression> _expressionRegistry = {};
int _nextCodeId = 0;
int _nextExpressionId = 0;

int _storeCode(IntermediateCode code) {
  final int id = _nextCodeId++;
  _codeRegistry[id] = code;
  return id;
}

int _storeExpression(Expression expression) {
  final int id = _nextExpressionId++;
  _expressionRegistry[id] = expression;
  return id;
}

IntermediateCode _getCode(int id) {
  final IntermediateCode? code = _codeRegistry[id];
  if (code == null) {
    throw StateError('Invalid code ID: $id');
  }
  return code;
}

Expression _getExpression(int id) {
  final Expression? expression = _expressionRegistry[id];
  if (expression == null) {
    throw StateError('Invalid expression ID: $id');
  }
  return expression;
}

void main(List<String> args) {
  const Compiler compiler = Compiler();

  compileInput = (JSString source) {
    final IntermediateCode code = compiler.compile(source.toDart);
    return _storeCode(code).toJS;
  }.toJS;

  compileExpression = (JSString source) {
    final Expression expression = compiler.expression(source.toDart);
    return _storeExpression(expression).toJS;
  }.toJS;

  runtimeWarnings = (JSNumber codeId) {
    final IntermediateCode code = _getCode(codeId.toDartInt);
    final List<JSString> warnings = code.warnings
        .map((e) => e.toString().toJS)
        .toList();
    return warnings.toJS;
  }.toJS;

  runtimeHasMain = (JSNumber codeId) {
    final IntermediateCode code = _getCode(codeId.toDartInt);
    final RuntimeFacade runtime = RuntimeFacade(code);
    return runtime.hasMain.toJS;
  }.toJS;

  runtimeExecuteMain = (JSNumber codeId) {
    final IntermediateCode code = _getCode(codeId.toDartInt);
    final RuntimeFacade runtime = RuntimeFacade(code);
    return runtime.executeMain().toJS;
  }.toJS;

  runtimeReduce = (JSNumber codeId, JSNumber expressionId) {
    final IntermediateCode code = _getCode(codeId.toDartInt);
    final Expression expression = _getExpression(expressionId.toDartInt);
    final RuntimeFacade runtime = RuntimeFacade(code);
    return runtime.evaluate(expression).toJS;
  }.toJS;

  intermediateCodeEmpty = () {
    final IntermediateCode code = IntermediateCode.empty();
    return _storeCode(code).toJS;
  }.toJS;

  disposeCode = (JSNumber codeId) {
    _codeRegistry.remove(codeId.toDartInt);
  }.toJS;

  disposeExpression = (JSNumber expressionId) {
    _expressionRegistry.remove(expressionId.toDartInt);
  }.toJS;
}
