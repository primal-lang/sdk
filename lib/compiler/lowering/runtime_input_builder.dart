import 'package:primal/compiler/library/standard_library.dart';
import 'package:primal/compiler/lowering/lowerer.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/runtime_input.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/utils/mapper.dart';

class RuntimeInputBuilder {
  const RuntimeInputBuilder();

  RuntimeInput build(IntermediateCode code) {
    // Fetch runtime FunctionNodes from StandardLibrary
    final Map<String, FunctionNode> functions = Mapper.toMap(
      StandardLibrary.get(),
    );

    // Create lowerer with access to all functions (standard library already present,
    // custom functions will be added as they are lowered)
    final Lowerer lowerer = Lowerer(functions);

    // Lower custom functions from semantic IR to runtime nodes
    for (final function in code.customFunctions.values) {
      functions[function.name] = lowerer.lowerFunction(function);
    }

    return RuntimeInput(functions);
  }
}
