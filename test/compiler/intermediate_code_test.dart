@Tags(['compiler'])
library;

import 'package:primal/compiler/models/function_signature.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/lowerer.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/warnings/semantic_warning.dart';
import 'package:test/test.dart';

import '../helpers/pipeline_helpers.dart';

void main() {
  group('IntermediateCode', () {
    test('empty() contains standard library signatures', () {
      final IntermediateCode code = IntermediateCode.empty();

      expect(code.standardLibrarySignatures, isNotEmpty);
      expect(code.customFunctions, isEmpty);
      expect(code.warnings, isEmpty);
    });

    test('empty() includes core library signatures', () {
      final IntermediateCode code = IntermediateCode.empty();

      expect(code.standardLibrarySignatures.containsKey('num.add'), isTrue);
      expect(code.standardLibrarySignatures.containsKey('str.length'), isTrue);
      expect(code.standardLibrarySignatures.containsKey('list.map'), isTrue);
    });

    test('compiled program includes user-defined functions', () {
      final IntermediateCode code = getIntermediateCode(
        'double(x) = x * 2\nmain = double(5)',
      );

      expect(code.customFunctions.containsKey('double'), isTrue);
      expect(code.customFunctions.containsKey('main'), isTrue);
    });

    test(
      'compiled program preserves standard library alongside user functions',
      () {
        final IntermediateCode code = getIntermediateCode('main = 42');

        expect(code.customFunctions.containsKey('main'), isTrue);
        expect(code.standardLibrarySignatures.containsKey('num.add'), isTrue);
      },
    );

    test('user function has correct parameter count', () {
      final IntermediateCode code = getIntermediateCode(
        'add(x, y) = x + y\nmain = add(1, 2)',
      );
      final SemanticFunction addFn = code.customFunctions['add']!;

      expect(addFn.parameters.length, equals(2));
    });

    test('warnings list populated for unused parameters', () {
      final IntermediateCode code = getIntermediateCode(
        'f(x, y) = x\nmain = f(1, 2)',
      );

      expect(code.warnings.length, equals(1));
      expect(code.warnings.first, isA<UnusedParameterWarning>());
      expect(
        code.warnings.first.toString(),
        equals('Warning: Unused parameter "y" in function "f"'),
      );
    });

    test('warnings list empty when all parameters are used', () {
      final IntermediateCode code = getIntermediateCode(
        'add(x, y) = x + y\nmain = add(1, 2)',
      );

      expect(code.warnings, isEmpty);
    });

    test('multiple unused parameters generate multiple warnings', () {
      final IntermediateCode code = getIntermediateCode(
        'f(x, y, z) = 42\nmain = f(1, 2, 3)',
      );

      expect(code.warnings.length, equals(3));
    });

    test('custom function is a SemanticFunction', () {
      final IntermediateCode code = getIntermediateCode('main = 42');
      final SemanticFunction mainFn = code.customFunctions['main']!;

      expect(mainFn, isA<SemanticFunction>());
    });

    test('lowered custom function is a CustomFunctionNode', () {
      final IntermediateCode code = getIntermediateCode('main = 42');
      final SemanticFunction mainFn = code.customFunctions['main']!;
      const Lowerer lowerer = Lowerer();
      final CustomFunctionNode lowered = lowerer.lowerFunction(mainFn);

      expect(lowered, isA<CustomFunctionNode>());
    });

    test('standard library signature is a FunctionSignature', () {
      final IntermediateCode code = getIntermediateCode('main = 42');
      final FunctionSignature? numAddSig = code.getStandardLibrarySignature(
        'num.add',
      );

      expect(numAddSig, isA<FunctionSignature>());
      expect(numAddSig?.arity, equals(2));
    });

    test('parameterless function has empty parameter list', () {
      final IntermediateCode code = getIntermediateCode('main = 42');
      final SemanticFunction mainFn = code.customFunctions['main']!;

      expect(mainFn.parameters, isEmpty);
    });

    test('containsFunction returns true for custom functions', () {
      final IntermediateCode code = getIntermediateCode('main = 42');

      expect(code.containsFunction('main'), isTrue);
    });

    test('containsFunction returns true for standard library functions', () {
      final IntermediateCode code = getIntermediateCode('main = 42');

      expect(code.containsFunction('num.add'), isTrue);
    });

    test('containsFunction returns false for unknown functions', () {
      final IntermediateCode code = getIntermediateCode('main = 42');

      expect(code.containsFunction('unknown'), isFalse);
    });

    test('allFunctionNames includes both custom and standard library', () {
      final IntermediateCode code = getIntermediateCode(
        'double(x) = x * 2\nmain = double(5)',
      );

      expect(code.allFunctionNames.contains('double'), isTrue);
      expect(code.allFunctionNames.contains('main'), isTrue);
      expect(code.allFunctionNames.contains('num.add'), isTrue);
    });
  });
}
