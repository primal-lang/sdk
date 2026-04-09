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

    test('custom function has correct location column', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );
      final SemanticFunction mainFn =
          intermediateRepresentation.customFunctions['main']!;

      // Location column points to the equals sign
      expect(mainFn.location.column, equals(8));
    });

    test('second function has correct location row', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'first = 1\nsecond = 2\nmain = first + second',
          );
      final SemanticFunction secondFn =
          intermediateRepresentation.customFunctions['second']!;

      expect(secondFn.location.row, equals(2));
    });

    test('parameter order is preserved', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'f(a, b, c) = a + b + c\nmain = f(1, 2, 3)',
          );
      final SemanticFunction fFn =
          intermediateRepresentation.customFunctions['f']!;

      expect(fFn.parameters[0].name, equals('a'));
      expect(fFn.parameters[1].name, equals('b'));
      expect(fFn.parameters[2].name, equals('c'));
    });

    test('SemanticFunction toString includes name and parameters', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'add(x, y) = x + y\nmain = add(1, 2)',
          );
      final SemanticFunction addFn =
          intermediateRepresentation.customFunctions['add']!;

      expect(addFn.toString(), equals('add(x, y)'));
    });

    test('SemanticFunction toString with no parameters', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );
      final SemanticFunction mainFn =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFn.toString(), equals('main()'));
    });

    test('warnings from multiple functions are collected', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'f(x) = 1\ng(y) = 2\nmain = f(1) + g(2)',
          );

      expect(intermediateRepresentation.warnings.length, equals(2));
    });

    test('function calling another custom function is resolved', () {
      final IntermediateRepresentation
      intermediateRepresentation = getIntermediateRepresentation(
        'double(x) = x * 2\nquadruple(x) = double(double(x))\nmain = quadruple(5)',
      );

      expect(
        intermediateRepresentation.customFunctions.containsKey('double'),
        isTrue,
      );
      expect(
        intermediateRepresentation.customFunctions.containsKey('quadruple'),
        isTrue,
      );
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('standard library signature has correct arity for unary function', () {
      final IntermediateRepresentation intermediateRepresentation =
          IntermediateRepresentation.empty();
      final FunctionSignature? notSig = intermediateRepresentation
          .getStandardLibrarySignature('bool.not');

      expect(notSig, isNotNull);
      expect(notSig?.arity, equals(1));
    });

    test(
      'standard library signature has correct arity for ternary function',
      () {
        final IntermediateRepresentation intermediateRepresentation =
            IntermediateRepresentation.empty();
        final FunctionSignature? ifSig = intermediateRepresentation
            .getStandardLibrarySignature('if');

        expect(ifSig, isNotNull);
        expect(ifSig?.arity, equals(3));
      },
    );

    test('empty() creates independent instances', () {
      final IntermediateRepresentation first =
          IntermediateRepresentation.empty();
      final IntermediateRepresentation second =
          IntermediateRepresentation.empty();

      expect(
        identical(
          first.standardLibrarySignatures,
          second.standardLibrarySignatures,
        ),
        isFalse,
      );
    });

    test('allFunctionNames returns new set on each access', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );

      final Set<String> first = intermediateRepresentation.allFunctionNames;
      final Set<String> second = intermediateRepresentation.allFunctionNames;

      expect(identical(first, second), isFalse);
    });

    test(
      'getCustomFunction returns null for standard library function name',
      () {
        final IntermediateRepresentation intermediateRepresentation =
            getIntermediateRepresentation(
              'main = 42',
            );

        expect(
          intermediateRepresentation.getCustomFunction('str.length'),
          isNull,
        );
      },
    );

    test(
      'getStandardLibrarySignature returns null for custom function name',
      () {
        final IntermediateRepresentation intermediateRepresentation =
            getIntermediateRepresentation(
              'myFunc = 42\nmain = myFunc',
            );

        expect(
          intermediateRepresentation.getStandardLibrarySignature('myFunc'),
          isNull,
        );
      },
    );

    test('function with list body compiles correctly', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = [1, 2, 3]',
          );

      expect(
        intermediateRepresentation.customFunctions.containsKey('main'),
        isTrue,
      );
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('function with map body compiles correctly', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = {"a": 1, "b": 2}',
          );

      expect(
        intermediateRepresentation.customFunctions.containsKey('main'),
        isTrue,
      );
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('function with nested call body compiles correctly', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = num.add(1, num.mul(2, 3))',
          );

      expect(
        intermediateRepresentation.customFunctions.containsKey('main'),
        isTrue,
      );
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('function with boolean body compiles correctly', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = true',
          );

      expect(
        intermediateRepresentation.customFunctions.containsKey('main'),
        isTrue,
      );
    });

    test('function with string body compiles correctly', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = "hello"',
          );

      expect(
        intermediateRepresentation.customFunctions.containsKey('main'),
        isTrue,
      );
    });

    test('unused parameter warning contains correct function name', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'myFunction(unused) = 42\nmain = myFunction(1)',
          );

      expect(intermediateRepresentation.warnings.length, equals(1));
      expect(
        intermediateRepresentation.warnings.first.toString(),
        contains('myFunction'),
      );
    });

    test('unused parameter warning contains correct parameter name', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'f(unusedParam) = 42\nmain = f(1)',
          );

      expect(intermediateRepresentation.warnings.length, equals(1));
      expect(
        intermediateRepresentation.warnings.first.toString(),
        contains('unusedParam'),
      );
    });

    test('containsFunction handles empty string', () {
      final IntermediateRepresentation intermediateRepresentation =
          IntermediateRepresentation.empty();

      expect(intermediateRepresentation.containsFunction(''), isFalse);
    });

    test('getCustomFunction handles empty string', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = 42',
          );

      expect(intermediateRepresentation.getCustomFunction(''), isNull);
    });

    test('getStandardLibrarySignature handles empty string', () {
      final IntermediateRepresentation intermediateRepresentation =
          IntermediateRepresentation.empty();

      expect(
        intermediateRepresentation.getStandardLibrarySignature(''),
        isNull,
      );
    });

    test('single parameter function has parameter list of length one', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'identity(x) = x\nmain = identity(42)',
          );
      final SemanticFunction identityFn =
          intermediateRepresentation.customFunctions['identity']!;

      expect(identityFn.parameters.length, equals(1));
      expect(identityFn.parameters.first.name, equals('x'));
    });

    test(
      'lowered function from complex expression produces CustomFunctionTerm',
      () {
        final IntermediateRepresentation intermediateRepresentation =
            getIntermediateRepresentation(
              'complex(a, b) = if (a > b) a else b\nmain = complex(1, 2)',
            );
        final SemanticFunction complexFn =
            intermediateRepresentation.customFunctions['complex']!;
        const Lowerer lowerer = Lowerer({});
        final CustomFunctionTerm lowered = lowerer.lowerFunction(complexFn);

        expect(lowered, isA<CustomFunctionTerm>());
        expect(lowered.name, equals('complex'));
        expect(lowered.parameters.length, equals(2));
      },
    );

    test('standard library contains multiple module categories', () {
      final IntermediateRepresentation intermediateRepresentation =
          IntermediateRepresentation.empty();

      expect(
        intermediateRepresentation.standardLibrarySignatures.containsKey(
          'list.map',
        ),
        isTrue,
      );
      expect(
        intermediateRepresentation.standardLibrarySignatures.containsKey(
          'str.concat',
        ),
        isTrue,
      );
      expect(
        intermediateRepresentation.standardLibrarySignatures.containsKey(
          'bool.and',
        ),
        isTrue,
      );
      expect(
        intermediateRepresentation.standardLibrarySignatures.containsKey('if'),
        isTrue,
      );
    });
  });
}
