import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/runtime_input.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/lowerer.dart';

class RuntimeInputBuilder {
  const RuntimeInputBuilder();

  RuntimeInput build(IntermediateCode code) {
    const Lowerer lowerer = Lowerer();
    final Map<String, FunctionNode> functions = {...code.standardLibrary};

    for (final function in code.customFunctions.values) {
      functions[function.name] = lowerer.lowerFunction(function);
    }

    return RuntimeInput(functions);
  }
}
