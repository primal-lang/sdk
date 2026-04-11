@Tags(['compiler'])
library;

import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/lowering/lowerer.dart';
import 'package:primal/compiler/models/function_signature.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/semantic/semantic_node.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';
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

  group('SemanticFunction', () {
    test('body is a SemanticNumberNode for numeric literal', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = 42');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticNumberNode>());
      expect((mainFunction.body as SemanticNumberNode).value, equals(42));
    });

    test('body is a SemanticBooleanNode for boolean literal', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = true');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticBooleanNode>());
      expect((mainFunction.body as SemanticBooleanNode).value, isTrue);
    });

    test('body is a SemanticBooleanNode for false literal', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = false');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticBooleanNode>());
      expect((mainFunction.body as SemanticBooleanNode).value, isFalse);
    });

    test('body is a SemanticStringNode for string literal', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = "hello world"');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticStringNode>());
      expect(
        (mainFunction.body as SemanticStringNode).value,
        equals('hello world'),
      );
    });

    test('body is a SemanticListNode for list literal', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = [1, 2, 3]');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticListNode>());
      final SemanticListNode listNode = mainFunction.body as SemanticListNode;
      expect(listNode.value.length, equals(3));
    });

    test('body is a SemanticMapNode for map literal', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = {"a": 1}');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticMapNode>());
      final SemanticMapNode mapNode = mainFunction.body as SemanticMapNode;
      expect(mapNode.value.length, equals(1));
    });

    test('body is a SemanticCallNode for function call', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = num.add(1, 2)');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticCallNode>());
    });

    test('parameter reference creates SemanticBoundVariableNode', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('identity(x) = x\nmain = identity(5)');
      final SemanticFunction identityFunction =
          intermediateRepresentation.customFunctions['identity']!;

      expect(identityFunction.body, isA<SemanticBoundVariableNode>());
      expect(
        (identityFunction.body as SemanticBoundVariableNode).name,
        equals('x'),
      );
    });

    test(
      'function reference creates SemanticIdentifierNode with signature',
      () {
        final IntermediateRepresentation intermediateRepresentation =
            getIntermediateRepresentation(
              'apply(f, x) = f(x)\nmain = apply(num.abs, 5)',
            );
        final SemanticFunction mainFunction =
            intermediateRepresentation.customFunctions['main']!;

        expect(mainFunction.body, isA<SemanticCallNode>());
        final SemanticCallNode callNode = mainFunction.body as SemanticCallNode;
        final SemanticNode firstArgument = callNode.arguments[0];
        expect(firstArgument, isA<SemanticIdentifierNode>());
        expect(
          (firstArgument as SemanticIdentifierNode).resolvedSignature,
          isNotNull,
        );
      },
    );

    test('empty list body compiles correctly', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = []');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticListNode>());
      final SemanticListNode listNode = mainFunction.body as SemanticListNode;
      expect(listNode.value, isEmpty);
    });

    test('empty map body compiles correctly', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = {}');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticMapNode>());
      final SemanticMapNode mapNode = mainFunction.body as SemanticMapNode;
      expect(mapNode.value, isEmpty);
    });

    test('nested list body compiles correctly', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = [[1, 2], [3, 4]]');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticListNode>());
      final SemanticListNode listNode = mainFunction.body as SemanticListNode;
      expect(listNode.value.length, equals(2));
      expect(listNode.value[0], isA<SemanticListNode>());
      expect(listNode.value[1], isA<SemanticListNode>());
    });

    test('nested map body compiles correctly', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = {"outer": {"inner": 1}}');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticMapNode>());
      final SemanticMapNode mapNode = mainFunction.body as SemanticMapNode;
      expect(mapNode.value.length, equals(1));
      expect(mapNode.value[0].value, isA<SemanticMapNode>());
    });

    test('location row is preserved from source', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'first = 1\nsecond = 2\nthird = 3\nmain = 0',
          );
      final SemanticFunction thirdFunction =
          intermediateRepresentation.customFunctions['third']!;

      expect(thirdFunction.location.row, equals(3));
    });
  });

  group('SemanticNode toString', () {
    test('SemanticBooleanNode toString returns value', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = true');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body.toString(), equals('true'));
    });

    test('SemanticNumberNode toString returns value', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = 42');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body.toString(), equals('42'));
    });

    test('SemanticStringNode toString returns quoted value', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = "hello"');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body.toString(), equals('"hello"'));
    });

    test('SemanticListNode toString returns bracketed elements', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = [1, 2, 3]');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body.toString(), equals('[1, 2, 3]'));
    });

    test('SemanticMapNode toString returns braced entries', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = {"a": 1}');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body.toString(), equals('{"a": 1}'));
    });

    test('SemanticIdentifierNode toString returns name', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'apply(f, x) = f(x)\nmain = apply(num.abs, 5)',
          );
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;
      final SemanticCallNode callNode = mainFunction.body as SemanticCallNode;
      final SemanticNode functionArgument = callNode.arguments[0];

      expect(functionArgument.toString(), equals('num.abs'));
    });

    test('SemanticBoundVariableNode toString returns name', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('identity(x) = x\nmain = identity(5)');
      final SemanticFunction identityFunction =
          intermediateRepresentation.customFunctions['identity']!;

      expect(identityFunction.body.toString(), equals('x'));
    });

    test('SemanticCallNode toString returns function and arguments', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = num.add(1, 2)');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body.toString(), equals('num.add(1, 2)'));
    });

    test('SemanticMapEntryNode toString returns key colon value', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = {"key": 42}');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;
      final SemanticMapNode mapNode = mainFunction.body as SemanticMapNode;
      final SemanticMapEntryNode entry = mapNode.value[0];

      expect(entry.toString(), equals('"key": 42'));
    });
  });

  group('SemanticAnalyzer error conditions', () {
    test('throws DuplicatedFunctionError for duplicate custom functions', () {
      expect(
        () => getIntermediateRepresentation('f = 1\nf = 2\nmain = f'),
        throwsA(isA<DuplicatedFunctionError>()),
      );
    });

    test(
      'throws DuplicatedFunctionError when custom function shadows standard library',
      () {
        // Standard library functions use dotted names like 'num.add', which are valid identifiers
        expect(
          () => getIntermediateRepresentation('num.add(x, y) = x\nmain = 0'),
          throwsA(isA<DuplicatedFunctionError>()),
        );
      },
    );

    test('throws DuplicatedParameterError for duplicate parameter names', () {
      expect(
        () => getIntermediateRepresentation('f(x, x) = x\nmain = f(1, 2)'),
        throwsA(isA<DuplicatedParameterError>()),
      );
    });

    test(
      'throws UndefinedIdentifierError for undefined identifier in body',
      () {
        expect(
          () => getIntermediateRepresentation('f(x) = y\nmain = f(1)'),
          throwsA(isA<UndefinedIdentifierError>()),
        );
      },
    );

    test('throws UndefinedFunctionError for undefined function call', () {
      expect(
        () => getIntermediateRepresentation('main = undefined(1)'),
        throwsA(isA<UndefinedFunctionError>()),
      );
    });

    test('throws InvalidNumberOfArgumentsError for wrong arity', () {
      expect(
        () => getIntermediateRepresentation('main = num.add(1)'),
        throwsA(isA<InvalidNumberOfArgumentsError>()),
      );
    });

    test('throws InvalidNumberOfArgumentsError for too many arguments', () {
      expect(
        () => getIntermediateRepresentation('main = num.add(1, 2, 3)'),
        throwsA(isA<InvalidNumberOfArgumentsError>()),
      );
    });

    test('throws NotCallableError for calling number literal', () {
      expect(
        () => getIntermediateRepresentation('main = 5(1)'),
        throwsA(isA<NotCallableError>()),
      );
    });

    test('throws NotCallableError for calling boolean literal', () {
      expect(
        () => getIntermediateRepresentation('main = true(1)'),
        throwsA(isA<NotCallableError>()),
      );
    });

    test('throws NotCallableError for calling string literal', () {
      expect(
        () => getIntermediateRepresentation('main = "hello"(1)'),
        throwsA(isA<NotCallableError>()),
      );
    });

    test('throws NotCallableError for calling list literal', () {
      expect(
        () => getIntermediateRepresentation('main = [1, 2](1)'),
        throwsA(isA<NotCallableError>()),
      );
    });

    test('throws NotCallableError for calling map literal', () {
      expect(
        () => getIntermediateRepresentation('main = {"a": 1}(1)'),
        throwsA(isA<NotCallableError>()),
      );
    });

    test('throws NotIndexableError for indexing number literal', () {
      expect(
        () => getIntermediateRepresentation('main = 5[0]'),
        throwsA(isA<NotIndexableError>()),
      );
    });

    test('throws NotIndexableError for indexing boolean literal', () {
      expect(
        () => getIntermediateRepresentation('main = true[0]'),
        throwsA(isA<NotIndexableError>()),
      );
    });

    test('DuplicatedFunctionError message contains function name', () {
      try {
        getIntermediateRepresentation('myFunc = 1\nmyFunc = 2\nmain = myFunc');
        fail('Expected DuplicatedFunctionError');
      } on DuplicatedFunctionError catch (error) {
        expect(error.toString(), contains('myFunc'));
      }
    });

    test(
      'DuplicatedParameterError message contains function and parameter',
      () {
        try {
          getIntermediateRepresentation(
            'myFunc(param, param) = param\nmain = myFunc(1, 2)',
          );
          fail('Expected DuplicatedParameterError');
        } on DuplicatedParameterError catch (error) {
          expect(error.toString(), contains('myFunc'));
          expect(error.toString(), contains('param'));
        }
      },
    );

    test('UndefinedIdentifierError message contains identifier name', () {
      try {
        getIntermediateRepresentation('f(x) = unknownVar\nmain = f(1)');
        fail('Expected UndefinedIdentifierError');
      } on UndefinedIdentifierError catch (error) {
        expect(error.toString(), contains('unknownVar'));
      }
    });

    test('UndefinedFunctionError message contains function name', () {
      try {
        getIntermediateRepresentation('main = unknownFunction(1)');
        fail('Expected UndefinedFunctionError');
      } on UndefinedFunctionError catch (error) {
        expect(error.toString(), contains('unknownFunction'));
      }
    });

    test(
      'InvalidNumberOfArgumentsError message contains expected and actual',
      () {
        try {
          getIntermediateRepresentation('main = num.add(1)');
          fail('Expected InvalidNumberOfArgumentsError');
        } on InvalidNumberOfArgumentsError catch (error) {
          expect(error.toString(), contains('2'));
          expect(error.toString(), contains('1'));
        }
      },
    );

    test('NotCallableError message contains type', () {
      try {
        getIntermediateRepresentation('main = 42(1)');
        fail('Expected NotCallableError');
      } on NotCallableError catch (error) {
        expect(error.toString(), contains('number'));
      }
    });

    test('NotIndexableError message contains type', () {
      try {
        getIntermediateRepresentation('main = 42[0]');
        fail('Expected NotIndexableError');
      } on NotIndexableError catch (error) {
        expect(error.toString(), contains('number'));
      }
    });
  });

  group('FunctionSignature', () {
    test('arity returns zero for parameterless signature', () {
      const FunctionSignature signature = FunctionSignature(
        name: 'test',
        parameters: [],
      );

      expect(signature.arity, equals(0));
    });

    test('arity returns correct count for multiple parameters', () {
      const FunctionSignature signature = FunctionSignature(
        name: 'test',
        parameters: [
          Parameter.any('a'),
          Parameter.any('b'),
          Parameter.any('c'),
        ],
      );

      expect(signature.arity, equals(3));
    });

    test('equality returns true for identical signatures', () {
      const FunctionSignature first = FunctionSignature(
        name: 'test',
        parameters: [Parameter.any('x'), Parameter.any('y')],
      );
      const FunctionSignature second = FunctionSignature(
        name: 'test',
        parameters: [Parameter.any('x'), Parameter.any('y')],
      );

      expect(first == second, isTrue);
    });

    test('equality returns false for different names', () {
      const FunctionSignature first = FunctionSignature(
        name: 'test1',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature second = FunctionSignature(
        name: 'test2',
        parameters: [Parameter.any('x')],
      );

      expect(first == second, isFalse);
    });

    test('equality returns false for different parameter count', () {
      const FunctionSignature first = FunctionSignature(
        name: 'test',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature second = FunctionSignature(
        name: 'test',
        parameters: [Parameter.any('x'), Parameter.any('y')],
      );

      expect(first == second, isFalse);
    });

    test('equality returns false for different parameter names', () {
      const FunctionSignature first = FunctionSignature(
        name: 'test',
        parameters: [Parameter.any('a')],
      );
      const FunctionSignature second = FunctionSignature(
        name: 'test',
        parameters: [Parameter.any('b')],
      );

      expect(first == second, isFalse);
    });

    test('hashCode is equal for identical signatures', () {
      const FunctionSignature first = FunctionSignature(
        name: 'test',
        parameters: [Parameter.any('x')],
      );
      const FunctionSignature second = FunctionSignature(
        name: 'test',
        parameters: [Parameter.any('x')],
      );

      expect(first.hashCode, equals(second.hashCode));
    });

    test('toString returns name and parameter list', () {
      const FunctionSignature signature = FunctionSignature(
        name: 'myFunction',
        parameters: [Parameter.any('a'), Parameter.any('b')],
      );

      expect(signature.toString(), equals('myFunction(a, b)'));
    });

    test('toString returns empty parentheses for no parameters', () {
      const FunctionSignature signature = FunctionSignature(
        name: 'noParams',
        parameters: [],
      );

      expect(signature.toString(), equals('noParams()'));
    });

    test('equality with same instance returns true', () {
      const FunctionSignature signature = FunctionSignature(
        name: 'test',
        parameters: [Parameter.any('x')],
      );

      expect(signature == signature, isTrue);
    });

    test('equality with non-FunctionSignature returns false', () {
      const FunctionSignature signature = FunctionSignature(
        name: 'test',
        parameters: [Parameter.any('x')],
      );

      // ignore: unrelated_type_equality_checks
      expect(signature == ('not a signature' as dynamic), isFalse);
    });
  });

  group('Warnings', () {
    test('SemanticWarning inherits from GenericWarning', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('f(unused) = 1\nmain = f(1)');

      expect(intermediateRepresentation.warnings.first, isA<GenericWarning>());
    });

    test('UnusedParameterWarning inherits from SemanticWarning', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('f(unused) = 1\nmain = f(1)');

      expect(
        intermediateRepresentation.warnings.first,
        isA<SemanticWarning>(),
      );
    });

    test('warning toString format starts with Warning prefix', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('f(unused) = 1\nmain = f(1)');

      expect(
        intermediateRepresentation.warnings.first.toString(),
        startsWith('Warning:'),
      );
    });

    test('no warnings when parameter is used in nested call', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'f(x) = num.add(x, 1)\nmain = f(5)',
          );

      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('no warnings when parameter is used in list', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('f(x) = [x, x]\nmain = f(5)');

      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('no warnings when parameter is used in map key', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('f(x) = {x: 1}\nmain = f("key")');

      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('no warnings when parameter is used in map value', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('f(x) = {"key": x}\nmain = f(5)');

      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('warnings list is modifiable', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('f(unused) = 1\nmain = f(1)');
      final int originalLength = intermediateRepresentation.warnings.length;

      intermediateRepresentation.warnings.clear();

      expect(intermediateRepresentation.warnings.length, equals(0));
      expect(originalLength, equals(1));
    });
  });

  group('Lowerer integration', () {
    test('lowering SemanticBooleanNode produces BooleanTerm', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = true');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(mainFunction);

      expect(lowered.term, isA<BooleanTerm>());
    });

    test('lowering SemanticNumberNode produces NumberTerm', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = 42');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(mainFunction);

      expect(lowered.term, isA<NumberTerm>());
    });

    test('lowering SemanticStringNode produces StringTerm', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = "hello"');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(mainFunction);

      expect(lowered.term, isA<StringTerm>());
    });

    test('lowering SemanticListNode produces ListTerm', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = [1, 2, 3]');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(mainFunction);

      expect(lowered.term, isA<ListTerm>());
    });

    test('lowering SemanticMapNode produces MapTerm', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = {"a": 1}');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(mainFunction);

      expect(lowered.term, isA<MapTerm>());
    });

    test('lowering SemanticBoundVariableNode produces BoundVariableTerm', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('identity(x) = x\nmain = identity(5)');
      final SemanticFunction identityFunction =
          intermediateRepresentation.customFunctions['identity']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(
        identityFunction,
      );

      expect(lowered.term, isA<BoundVariableTerm>());
    });

    test('lowering SemanticCallNode produces CallTerm', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = num.add(1, 2)');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(mainFunction);

      expect(lowered.term, isA<CallTerm>());
    });

    test('lowering SemanticIdentifierNode produces FunctionReferenceTerm', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'apply(f, x) = f(x)\nmain = apply(num.abs, 5)',
          );
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(mainFunction);
      final CallTerm callTerm = lowered.term as CallTerm;

      expect(callTerm.arguments[0], isA<FunctionReferenceTerm>());
    });

    test('lowered function preserves name', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('myFunction = 42\nmain = myFunction');
      final SemanticFunction myFunction =
          intermediateRepresentation.customFunctions['myFunction']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(myFunction);

      expect(lowered.name, equals('myFunction'));
    });

    test('lowered function preserves parameter count', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'threeParams(a, b, c) = a\nmain = threeParams(1, 2, 3)',
          );
      final SemanticFunction threeParamsFunction =
          intermediateRepresentation.customFunctions['threeParams']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(
        threeParamsFunction,
      );

      expect(lowered.parameters.length, equals(3));
    });

    test('lowering empty list produces empty ListTerm', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = []');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(mainFunction);
      final ListTerm listTerm = lowered.term as ListTerm;

      expect(listTerm.value, isEmpty);
    });

    test('lowering empty map produces empty MapTerm', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = {}');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm lowered = lowerer.lowerFunction(mainFunction);
      final MapTerm mapTerm = lowered.term as MapTerm;

      expect(mapTerm.value, isEmpty);
    });
  });

  group('Edge cases', () {
    test('function with negative number body', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = -42');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticCallNode>());
    });

    test('function with decimal number body', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = 3.14');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticNumberNode>());
      expect((mainFunction.body as SemanticNumberNode).value, equals(3.14));
    });

    test('function with empty string body', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = ""');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticStringNode>());
      expect((mainFunction.body as SemanticStringNode).value, equals(''));
    });

    test('function with single element list', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = [42]');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticListNode>());
      final SemanticListNode listNode = mainFunction.body as SemanticListNode;
      expect(listNode.value.length, equals(1));
    });

    test('function with single entry map', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = {"key": "value"}');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticMapNode>());
      final SemanticMapNode mapNode = mainFunction.body as SemanticMapNode;
      expect(mapNode.value.length, equals(1));
    });

    test('function with mixed type list', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = [1, "two", true]');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticListNode>());
      final SemanticListNode listNode = mainFunction.body as SemanticListNode;
      expect(listNode.value[0], isA<SemanticNumberNode>());
      expect(listNode.value[1], isA<SemanticStringNode>());
      expect(listNode.value[2], isA<SemanticBooleanNode>());
    });

    test('function calling itself recursively compiles', () {
      final IntermediateRepresentation
      intermediateRepresentation = getIntermediateRepresentation(
        'factorial(n) = if (n == 0) 1 else n * factorial(n - 1)\nmain = factorial(5)',
      );

      expect(
        intermediateRepresentation.customFunctions.containsKey('factorial'),
        isTrue,
      );
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('mutually recursive functions compile', () {
      final IntermediateRepresentation
      intermediateRepresentation = getIntermediateRepresentation(
        'isEven(n) = if (n == 0) true else isOdd(n - 1)\nisOdd(n) = if (n == 0) false else isEven(n - 1)\nmain = isEven(4)',
      );

      expect(
        intermediateRepresentation.customFunctions.containsKey('isEven'),
        isTrue,
      );
      expect(
        intermediateRepresentation.customFunctions.containsKey('isOdd'),
        isTrue,
      );
    });

    test('higher-order function passing custom function compiles', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'double(x) = x * 2\nmain = list.map([1, 2, 3], double)',
          );

      expect(
        intermediateRepresentation.customFunctions.containsKey('double'),
        isTrue,
      );
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('deeply nested function calls compile', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'main = num.add(num.add(num.add(1, 2), 3), 4)',
          );

      expect(
        intermediateRepresentation.customFunctions.containsKey('main'),
        isTrue,
      );
    });

    test('function with parameter shadowing outer function name compiles', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'outer = 1\ninner(outer) = outer\nmain = inner(5)',
          );

      expect(
        intermediateRepresentation.customFunctions.containsKey('inner'),
        isTrue,
      );
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('chained function calls compile', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation(
            'a(x) = x + 1\nb(x) = x * 2\nc(x) = x - 1\nmain = c(b(a(5)))',
          );

      expect(intermediateRepresentation.customFunctions.length, equals(4));
    });

    test('location preserves column for expression start', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('f(x) = x + 1\nmain = 0');
      final SemanticFunction functionF =
          intermediateRepresentation.customFunctions['f']!;

      expect(functionF.location.column, greaterThan(0));
    });

    test('list with expressions compiles correctly', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = [1 + 2, 3 * 4]');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticListNode>());
      final SemanticListNode listNode = mainFunction.body as SemanticListNode;
      expect(listNode.value[0], isA<SemanticCallNode>());
      expect(listNode.value[1], isA<SemanticCallNode>());
    });

    test('map with expression values compiles correctly', () {
      final IntermediateRepresentation intermediateRepresentation =
          getIntermediateRepresentation('main = {"sum": 1 + 2}');
      final SemanticFunction mainFunction =
          intermediateRepresentation.customFunctions['main']!;

      expect(mainFunction.body, isA<SemanticMapNode>());
      final SemanticMapNode mapNode = mainFunction.body as SemanticMapNode;
      expect(mapNode.value[0].value, isA<SemanticCallNode>());
    });
  });
}
