import 'package:primal/compiler/lowering/lowerer.dart';
import 'package:primal/compiler/lowering/runtime_input_builder.dart';
import 'package:primal/compiler/models/function_signature.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/runtime/runtime_input.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/semantic/semantic_analyzer.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/semantic/semantic_node.dart';
import 'package:primal/compiler/syntactic/expression.dart';

/// Parses a string into an [Expression].
typedef ExpressionParser = Expression Function(String input);

class RuntimeFacade {
  final IntermediateRepresentation intermediateRepresentation;
  final ExpressionParser _parseExpression;
  final RuntimeInput _runtimeInput;
  final Runtime _runtime;
  final Map<String, FunctionSignature> _allSignatures;

  RuntimeFacade._internal(
    this.intermediateRepresentation,
    this._parseExpression,
    this._runtimeInput,
    this._allSignatures,
  ) : _runtime = Runtime(_runtimeInput);

  factory RuntimeFacade(
    IntermediateRepresentation intermediateRepresentation,
    ExpressionParser parseExpression,
  ) {
    final RuntimeInput input = const RuntimeInputBuilder().build(
      intermediateRepresentation,
    );

    // Build combined signature map for expression validation
    final Map<String, FunctionSignature> allSignatures = {
      ...intermediateRepresentation.standardLibrarySignatures,
      for (final SemanticFunction function
          in intermediateRepresentation.customFunctions.values)
        function.name: FunctionSignature(
          name: function.name,
          parameters: function.parameters,
        ),
    };

    return RuntimeFacade._internal(
      intermediateRepresentation,
      parseExpression,
      input,
      allSignatures,
    );
  }

  bool get hasMain => intermediateRepresentation.containsFunction('main');

  Expression mainExpression(List<String> arguments) {
    final FunctionNode? main = _runtimeInput.getFunction('main');

    if ((main != null) && main.parameters.isNotEmpty) {
      final String escapedArgs = arguments
          .map(
            (String e) =>
                '"${e.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"',
          )
          .join(', ');
      return _parseExpression('main($escapedArgs)');
    } else {
      return _parseExpression('main()');
    }
  }

  String executeMain([List<String>? arguments]) {
    final Expression expression = mainExpression(arguments ?? []);

    return evaluate(expression);
  }

  String evaluate(Expression expression) {
    final Node result = evaluateToNode(expression);
    return _runtime.format(result.native()).toString();
  }

  /// Evaluates an expression and returns the runtime node.
  ///
  /// Used by tests that need to inspect the node type.
  Node evaluateToNode(Expression expression) {
    // Reset recursion depth at the start to clear any stale state from
    // previous failed evaluations.
    FunctionNode.resetDepth();

    const SemanticAnalyzer analyzer = SemanticAnalyzer([]);
    final Lowerer lowerer = Lowerer(_runtimeInput.functions);

    // Proper pipeline: Expression → SemanticNode → Node → evaluate
    final SemanticNode semanticNode = analyzer.checkExpression(
      expression: expression,
      currentFunction: '<expression>',
      availableParameters: {},
      usedParameters: {},
      allSignatures: _allSignatures,
    );

    final Node lowered = lowerer.lowerNode(semanticNode);
    return lowered.evaluate();
  }

  dynamic format(dynamic value) => _runtime.format(value);
}
