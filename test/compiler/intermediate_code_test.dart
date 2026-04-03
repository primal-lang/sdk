@Tags(['compiler'])
library;

import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/lowerer.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/warnings/semantic_warning.dart';
import 'package:test/test.dart';

import '../helpers/pipeline_helpers.dart';

void main() {
  group('IntermediateCode', () {
    test('empty() contains standard library functions', () {
      final code = IntermediateCode.empty();

      expect(code.standardLibrary, isNotEmpty);
      expect(code.customFunctions, isEmpty);
      expect(code.warnings, isEmpty);
    });

    test('empty() includes core library functions', () {
      final code = IntermediateCode.empty();

      expect(code.standardLibrary.containsKey('num.add'), isTrue);
      expect(code.standardLibrary.containsKey('str.length'), isTrue);
      expect(code.standardLibrary.containsKey('list.map'), isTrue);
    });

    test('compiled program includes user-defined functions', () {
      final code = getIntermediateCode('double(x) = x * 2\nmain = double(5)');

      expect(code.customFunctions.containsKey('double'), isTrue);
      expect(code.customFunctions.containsKey('main'), isTrue);
    });

    test(
      'compiled program preserves standard library alongside user functions',
      () {
        final code = getIntermediateCode('main = 42');

        expect(code.customFunctions.containsKey('main'), isTrue);
        expect(code.standardLibrary.containsKey('num.add'), isTrue);
      },
    );

    test('user function has correct parameter count', () {
      final code = getIntermediateCode('add(x, y) = x + y\nmain = add(1, 2)');
      final addFn = code.customFunctions['add']!;

      expect(addFn.parameters.length, equals(2));
    });

    test('warnings list populated for unused parameters', () {
      final code = getIntermediateCode('f(x, y) = x\nmain = f(1, 2)');

      expect(code.warnings.length, equals(1));
      expect(code.warnings.first, isA<UnusedParameterWarning>());
      expect(
        code.warnings.first.toString(),
        equals('Warning: Unused parameter "y" in function "f"'),
      );
    });

    test('warnings list empty when all parameters are used', () {
      final code = getIntermediateCode('add(x, y) = x + y\nmain = add(1, 2)');

      expect(code.warnings, isEmpty);
    });

    test('multiple unused parameters generate multiple warnings', () {
      final code = getIntermediateCode('f(x, y, z) = 42\nmain = f(1, 2, 3)');

      expect(code.warnings.length, equals(3));
    });

    test('custom function is a SemanticFunction', () {
      final code = getIntermediateCode('main = 42');
      final mainFn = code.customFunctions['main']!;

      expect(mainFn, isA<SemanticFunction>());
    });

    test('lowered custom function is a CustomFunctionNode', () {
      final code = getIntermediateCode('main = 42');
      final mainFn = code.customFunctions['main']!;
      const lowerer = Lowerer();
      final lowered = lowerer.lowerFunction(mainFn);

      expect(lowered, isA<CustomFunctionNode>());
    });

    test('standard library function node is a NativeFunctionNode', () {
      final code = getIntermediateCode('main = 42');
      final numAdd = code.standardLibrary['num.add']!;

      expect(numAdd, isA<NativeFunctionNode>());
    });

    test('parameterless function has empty parameter list', () {
      final code = getIntermediateCode('main = 42');
      final mainFn = code.customFunctions['main']!;

      expect(mainFn.parameters, isEmpty);
    });

    test('containsFunction returns true for custom functions', () {
      final code = getIntermediateCode('main = 42');

      expect(code.containsFunction('main'), isTrue);
    });

    test('containsFunction returns true for standard library functions', () {
      final code = getIntermediateCode('main = 42');

      expect(code.containsFunction('num.add'), isTrue);
    });

    test('containsFunction returns false for unknown functions', () {
      final code = getIntermediateCode('main = 42');

      expect(code.containsFunction('unknown'), isFalse);
    });

    test('allFunctionNames includes both custom and standard library', () {
      final code = getIntermediateCode('double(x) = x * 2\nmain = double(5)');

      expect(code.allFunctionNames.contains('double'), isTrue);
      expect(code.allFunctionNames.contains('main'), isTrue);
      expect(code.allFunctionNames.contains('num.add'), isTrue);
    });
  });
}
