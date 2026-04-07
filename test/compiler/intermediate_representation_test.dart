@Tags(['compiler'])
library;

import 'package:primal/compiler/lowering/lowerer.dart';
import 'package:primal/compiler/models/function_signature.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/warnings/semantic_warning.dart';
import 'package:test/test.dart';

import '../helpers/pipeline_helpers.dart';

void main() {
  group('IntermediateRepresentation', () {
    test('empty() contains standard library signatures', () {
      final IntermediateRepresentation intermediateRepresentation =
          IntermediateRepresentation.empty();

      expect(intermediateRepresentation.standardLibrarySignatures, isNotEmpty);
      expect(intermediateRepresentation.customFunctions, isEmpty);
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('empty() includes core library signatures', () {
      final IntermediateRepresentation intermediateRepresentation =
          IntermediateRepresentation.empty();

      expect(
        intermediateRepresentation.standardLibrarySignatures.containsKey(
          'num.add',
        ),
        isTrue,
      );
      expect(
        intermediateRepresentation.standardLibrarySignatures.containsKey(
          'str.length',
        ),
        isTrue,
      );
      expect(
        intermediateRepresentation.standardLibrarySignatures.containsKey(
          'list.map',
        ),
        isTrue,
      );
    });

    test('compiled program includes user-defined functions', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'double(x) = x * 2\nmain = double(5)',
          );

      expect(
        intermediateRepresentation.customFunctions.containsKey('double'),
        isTrue,
      );
      expect(
        intermediateRepresentation.customFunctions.containsKey('main'),
        isTrue,
      );
    });

    test(
      'compiled program preserves standard library alongside user functions',
      () {
        final IntermediateRepresentation intermediateRepresentation =
            getIntermediateRepresentation(
              'main = 42',
            );

        expect(
          intermediateRepresentation.customFunctions.containsKey('main'),
          isTrue,
        );
        expect(
          intermediateRepresentation.standardLibrarySignatures.containsKey(
            'num.add',
          ),
          isTrue,
        );
      },
    );

    test('user function has correct parameter count', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'add(x, y) = x + y\nmain = add(1, 2)',
          );
      final SemanticFunction addFn =
          intermediateRepresentation.customFunctions['add']!;

      expect(addFn.parameters.length, equals(2));
    });

    test('warnings list populated for unused parameters', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'f(x, y) = x\nmain = f(1, 2)',
          );

      expect(intermediateRepresentation.warnings.length, equals(1));
      expect(
        intermediateRepresentation.warnings.first,
        isA<UnusedParameterWarning>(),
      );
      expect(
        intermediateRepresentation.warnings.first.toString(),
        equals('Warning: Unused parameter "y" in function "f"'),
      );
    });

    test('warnings list empty when all parameters are used', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'add(x, y) = x + y\nmain = add(1, 2)',
          );

      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('multiple unused parameters generate multiple warnings', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'f(x, y, z) = 42\nmain = f(1, 2, 3)',
          );

      expect(intermediateRepresentation.warnings.length, equals(3));
    });

    test('custom function is a SemanticFunction', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );
      final SemanticFunction mainFn =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFn, isA<SemanticFunction>());
    });

    test('lowered custom function is a CustomFunctionTerm', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );
      final SemanticFunction mainFn =
          intermediateRepresentation.customFunctions['main']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(mainFn);

      expect(lowered, isA<CustomFunctionTerm>());
    });

    test('standard library signature is a FunctionSignature', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );
      final FunctionSignature? numAddSig = intermediateRepresentation
          .getStandardLibrarySignature(
            'num.add',
          );

      expect(numAddSig, isA<FunctionSignature>());
      expect(numAddSig?.arity, equals(2));
    });

    test('parameterless function has empty parameter list', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );
      final SemanticFunction mainFn =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFn.parameters, isEmpty);
    });

    test('containsFunction returns true for custom functions', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );

      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('containsFunction returns true for standard library functions', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );

      expect(intermediateRepresentation.containsFunction('num.add'), isTrue);
    });

    test('containsFunction returns false for unknown functions', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );

      expect(intermediateRepresentation.containsFunction('unknown'), isFalse);
    });

    test('allFunctionNames includes both custom and standard library', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'double(x) = x * 2\nmain = double(5)',
          );

      expect(
        intermediateRepresentation.allFunctionNames.contains('double'),
        isTrue,
      );
      expect(
        intermediateRepresentation.allFunctionNames.contains('main'),
        isTrue,
      );
      expect(
        intermediateRepresentation.allFunctionNames.contains('num.add'),
        isTrue,
      );
    });

    test('allFunctionNames with empty() only contains standard library', () {
      final IntermediateRepresentation intermediateRepresentation =
          IntermediateRepresentation.empty();

      expect(intermediateRepresentation.allFunctionNames, isNotEmpty);
      expect(
        intermediateRepresentation.allFunctionNames.contains('num.add'),
        isTrue,
      );
      expect(
        intermediateRepresentation.customFunctions,
        isEmpty,
      );
    });

    test('getStandardLibrarySignature returns null for unknown function', () {
      final IntermediateRepresentation intermediateRepresentation =
          IntermediateRepresentation.empty();

      expect(
        intermediateRepresentation.getStandardLibrarySignature('unknown'),
        isNull,
      );
    });

    test('getCustomFunction returns the custom function', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'double(x) = x * 2\nmain = double(5)',
          );
      final SemanticFunction? doubleFn = intermediateRepresentation
          .getCustomFunction('double');

      expect(doubleFn, isNotNull);
      expect(doubleFn, isA<SemanticFunction>());
      expect(doubleFn!.name, equals('double'));
      expect(doubleFn.parameters.length, equals(1));
    });

    test('getCustomFunction returns null for unknown function', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );

      expect(
        intermediateRepresentation.getCustomFunction('unknown'),
        isNull,
      );
    });

    test('getCustomFunction returns null for standard library function', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );

      expect(
        intermediateRepresentation.getCustomFunction('num.add'),
        isNull,
      );
    });

    test('function with multiple parameters has correct parameter count', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'f(a, b, c, d, e) = a + b + c + d + e\nmain = f(1, 2, 3, 4, 5)',
          );
      final SemanticFunction fFn =
          intermediateRepresentation.customFunctions['f']!;

      expect(fFn.parameters.length, equals(5));
    });

    test('multiple custom functions are all accessible', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'add(x, y) = x + y\nmul(x, y) = x * y\nmain = add(1, mul(2, 3))',
          );

      expect(intermediateRepresentation.customFunctions.length, equals(3));
      expect(
        intermediateRepresentation.customFunctions.containsKey('add'),
        isTrue,
      );
      expect(
        intermediateRepresentation.customFunctions.containsKey('mul'),
        isTrue,
      );
      expect(
        intermediateRepresentation.customFunctions.containsKey('main'),
        isTrue,
      );
    });

    test('custom function body is a SemanticNode', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );
      final SemanticFunction mainFn =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFn.body, isNotNull);
    });

    test('custom function has location information', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );
      final SemanticFunction mainFn =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFn.location, isNotNull);
      expect(mainFn.location.row, equals(1));
    });

    test('constructor creates instance with provided values', () {
      final IntermediateRepresentation intermediateRepresentation =
          IntermediateRepresentation(
            customFunctions: {},
            standardLibrarySignatures: {},
            warnings: [],
          );

      expect(intermediateRepresentation.customFunctions, isEmpty);
      expect(intermediateRepresentation.standardLibrarySignatures, isEmpty);
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('containsFunction returns false with empty representations', () {
      final IntermediateRepresentation intermediateRepresentation =
          IntermediateRepresentation(
            customFunctions: {},
            standardLibrarySignatures: {},
            warnings: [],
          );

      expect(intermediateRepresentation.containsFunction('anything'), isFalse);
    });

    test('allFunctionNames is empty when no functions exist', () {
      final IntermediateRepresentation intermediateRepresentation =
          IntermediateRepresentation(
            customFunctions: {},
            standardLibrarySignatures: {},
            warnings: [],
          );

      expect(intermediateRepresentation.allFunctionNames, isEmpty);
    });
  });
}
