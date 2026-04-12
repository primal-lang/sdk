@Tags(['compiler'])
library;

import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:test/test.dart';
import '../helpers/pipeline_helpers.dart';

void main() {
  const Compiler compiler = Compiler();

  group('RuntimeFacade', () {
    group('hasMain', () {
      test('returns true when main is defined', () {
        final RuntimeFacade runtime = getRuntime('main = 42');
        expect(runtime.hasMain, true);
      });

      test('returns false when main is not defined', () {
        final RuntimeFacade runtime = getRuntime('f(x) = x');
        expect(runtime.hasMain, false);
      });

      test('returns false for empty intermediate code', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        expect(runtime.hasMain, false);
      });
    });

    group('executeMain', () {
      test('executes parameterless main', () {
        final RuntimeFacade runtime = getRuntime('main = 42');
        expect(runtime.executeMain(), '42');
      });

      test('executes main with arguments', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        expect(runtime.executeMain(['hello']), '"hello"');
      });

      test('executes main with multiple arguments', () {
        final RuntimeFacade runtime = getRuntime(
          'main(a, b) = to.string(a) + to.string(b)',
        );
        expect(runtime.executeMain(['foo', 'bar']), '"foobar"');
      });
    });

    group('evaluate', () {
      test('evaluates simple expression', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Expression expression = getExpression('1 + 2');
        expect(runtime.evaluate(expression), '3');
      });

      test('evaluates expression using custom functions', () {
        final RuntimeFacade runtime = getRuntime('double(x) = x * 2');
        final Expression expression = getExpression('double(5)');
        expect(runtime.evaluate(expression), '10');
      });

      test('evaluates nested expressions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Expression expression = getExpression('(1 + 2) * (3 + 4)');
        expect(runtime.evaluate(expression), '21');
      });
    });

    group('mainExpression', () {
      test('returns main() call for parameterless main', () {
        final RuntimeFacade runtime = getRuntime('main = 42');
        final Expression expression = runtime.mainExpression([]);
        expect(expression.toString(), 'main()');
      });

      test('returns main call with arguments for parameterized main', () {
        final RuntimeFacade runtime = getRuntime('main(a, b) = a + b');
        final Expression expression = runtime.mainExpression(['x', 'y']);
        expect(expression.toString(), 'main("x", "y")');
      });

      test('escapes double quotes in arguments', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain(['hello "world"']);
        expect(result, '"hello "world""');
      });

      test('escapes backslashes in arguments', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain([r'path\to\file']);
        expect(result, r'"path\to\file"');
      });

      test('escapes both quotes and backslashes in arguments', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain([r'say "hello\" world']);
        expect(result, r'"say "hello\" world"');
      });
    });

    group('defineFunction', () {
      test('defines a constant that can be evaluated', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'pi = 3.14',
        )!;

        runtime.defineFunction(definition);

        // Constants are zero-argument functions, so call with ()
        final Expression expression = getExpression('pi()');
        expect(runtime.evaluate(expression), '3.14');
      });

      test('defines a function that can be called', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'double(x) = x * 2',
        )!;

        runtime.defineFunction(definition);

        final Expression expression = getExpression('double(5)');
        expect(runtime.evaluate(expression), '10');
      });

      test('defines a function with multiple parameters', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'add(a, b, c) = a + b + c',
        )!;

        runtime.defineFunction(definition);

        final Expression expression = getExpression('add(1, 2, 3)');
        expect(runtime.evaluate(expression), '6');
      });

      test('allows redefining user-defined functions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition1 = compiler.functionDefinition(
          'value = 1',
        )!;
        final FunctionDefinition definition2 = compiler.functionDefinition(
          'value = 2',
        )!;

        runtime.defineFunction(definition1);
        // Constants are zero-argument functions
        expect(runtime.evaluate(getExpression('value()')), '1');

        runtime.defineFunction(definition2);
        expect(runtime.evaluate(getExpression('value()')), '2');
      });

      test('supports recursive functions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        // Primal uses "if (cond) then else" syntax
        final FunctionDefinition definition = compiler.functionDefinition(
          'factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)',
        )!;

        runtime.defineFunction(definition);

        final Expression expression = getExpression('factorial(5)');
        expect(runtime.evaluate(expression), '120');
      });

      test('throws when trying to redefine standard library function', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        // Use a real standard library function name
        final FunctionDefinition definition = compiler.functionDefinition(
          'num.add = 1',
        )!;

        expect(
          () => runtime.defineFunction(definition),
          throwsA(isA<CannotRedefineStandardLibraryError>()),
        );
      });

      test('throws for duplicate parameters', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'bad(x, x) = x',
        )!;

        expect(
          () => runtime.defineFunction(definition),
          throwsA(isA<DuplicatedParameterError>()),
        );
      });

      test('throws for undefined identifier in function body', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'bad(x) = y',
        )!;

        expect(
          () => runtime.defineFunction(definition),
          throwsA(isA<UndefinedIdentifierError>()),
        );
      });

      test('can use previously defined functions in new definitions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition double = compiler.functionDefinition(
          'double(x) = x * 2',
        )!;
        final FunctionDefinition quadruple = compiler.functionDefinition(
          'quadruple(x) = double(double(x))',
        )!;

        runtime.defineFunction(double);
        runtime.defineFunction(quadruple);

        expect(runtime.evaluate(getExpression('quadruple(3)')), '12');
      });

      test('can use standard library functions in definitions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        // Use num.mul which is the standard library multiply function
        final FunctionDefinition definition = compiler.functionDefinition(
          'double(x) = num.mul(x, 2)',
        )!;

        runtime.defineFunction(definition);

        expect(runtime.evaluate(getExpression('double(5)')), '10');
      });
    });

    group('userDefinedFunctionSignatures', () {
      test('returns empty list for empty runtime', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        expect(runtime.userDefinedFunctionSignatures, isEmpty);
      });

      test('returns signatures from source file', () {
        final RuntimeFacade runtime = getRuntime('double(x) = x * 2');
        expect(runtime.userDefinedFunctionSignatures, ['double(x)']);
      });

      test('returns signatures sorted alphabetically', () {
        final RuntimeFacade runtime = getRuntime('''
          zeta = 26
          alpha = 1
          mu(x) = x
        ''');
        expect(runtime.userDefinedFunctionSignatures, [
          'alpha()',
          'mu(x)',
          'zeta()',
        ]);
      });

      test('includes dynamically defined functions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'triple(x) = x * 3',
        )!;
        runtime.defineFunction(definition);

        expect(runtime.userDefinedFunctionSignatures, ['triple(x)']);
      });

      test('returns signatures with multiple parameters', () {
        final RuntimeFacade runtime = getRuntime('add(a, b, c) = a + b + c');
        expect(runtime.userDefinedFunctionSignatures, ['add(a, b, c)']);
      });
    });

    group('reset', () {
      test('clears all user-defined functions', () {
        final RuntimeFacade runtime = getRuntime('double(x) = x * 2');
        expect(runtime.userDefinedFunctionSignatures, isNotEmpty);

        runtime.reset();

        expect(runtime.userDefinedFunctionSignatures, isEmpty);
      });

      test('clears dynamically defined functions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'value = 42',
        )!;
        runtime.defineFunction(definition);
        expect(runtime.userDefinedFunctionSignatures, isNotEmpty);

        runtime.reset();

        expect(runtime.userDefinedFunctionSignatures, isEmpty);
      });

      test('allows redefining functions after reset', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition1 = compiler.functionDefinition(
          'value = 1',
        )!;
        runtime.defineFunction(definition1);
        runtime.reset();

        final FunctionDefinition definition2 = compiler.functionDefinition(
          'value = 2',
        )!;
        runtime.defineFunction(definition2);

        expect(runtime.evaluate(getExpression('value()')), '2');
      });

      test('preserves standard library after reset', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        runtime.reset();

        // Standard library functions should still work
        expect(runtime.evaluate(getExpression('num.add(1, 2)')), '3');
      });
    });

    group('loadFromIntermediateRepresentation', () {
      test('loads functions from IR', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final IntermediateRepresentation representation =
            getIntermediateRepresentation('double(x) = x * 2');

        final int count = runtime.loadFromIntermediateRepresentation(
          representation,
        );

        expect(count, 1);
        expect(runtime.evaluate(getExpression('double(5)')), '10');
      });

      test('returns correct count for multiple functions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final IntermediateRepresentation representation =
            getIntermediateRepresentation('''
              add(a, b) = a + b
              sub(a, b) = a - b
              mul(a, b) = a * b
            ''');

        final int count = runtime.loadFromIntermediateRepresentation(
          representation,
        );

        expect(count, 3);
      });

      test('clears previous user-defined functions before loading', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition oldFunction = compiler.functionDefinition(
          'old = 1',
        )!;
        runtime.defineFunction(oldFunction);

        final IntermediateRepresentation representation =
            getIntermediateRepresentation('new_ = 2');
        runtime.loadFromIntermediateRepresentation(representation);

        expect(
          runtime.userDefinedFunctionSignatures,
          isNot(contains('old()')),
        );
        expect(runtime.userDefinedFunctionSignatures, contains('new_()'));
      });

      test('returns zero for empty representation', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        final int count = runtime.loadFromIntermediateRepresentation(
          IntermediateRepresentation.empty(),
        );

        expect(count, 0);
      });
    });

    group('deleteFunction', () {
      test('removes a user-defined function', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'value = 42',
        )!;
        runtime.defineFunction(definition);

        runtime.deleteFunction('value');

        expect(runtime.userDefinedFunctionSignatures, isEmpty);
      });

      test('throws FunctionNotFoundError for non-existent function', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          () => runtime.deleteFunction('nonexistent'),
          throwsA(isA<FunctionNotFoundError>()),
        );
      });

      test('throws CannotDeleteStandardLibraryError for stdlib function', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          () => runtime.deleteFunction('num.add'),
          throwsA(isA<CannotDeleteStandardLibraryError>()),
        );
      });

      test('allows defining a function with same name after deletion', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition1 = compiler.functionDefinition(
          'value = 1',
        )!;
        runtime.defineFunction(definition1);
        runtime.deleteFunction('value');

        final FunctionDefinition definition2 = compiler.functionDefinition(
          'value = 2',
        )!;
        runtime.defineFunction(definition2);

        expect(runtime.evaluate(getExpression('value()')), '2');
      });
    });

    group('renameFunction', () {
      test('renames a user-defined function', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'oldName = 42',
        )!;
        runtime.defineFunction(definition);

        runtime.renameFunction('oldName', 'newName');

        expect(
          runtime.userDefinedFunctionSignatures,
          isNot(contains('oldName()')),
        );
        expect(runtime.userDefinedFunctionSignatures, contains('newName()'));
        expect(runtime.evaluate(getExpression('newName()')), '42');
      });

      test('preserves parameters when renaming', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'old(a, b) = a + b',
        )!;
        runtime.defineFunction(definition);

        runtime.renameFunction('old', 'new_');

        expect(runtime.userDefinedFunctionSignatures, ['new_(a, b)']);
        expect(runtime.evaluate(getExpression('new_(1, 2)')), '3');
      });

      test('throws FunctionNotFoundError for non-existent old name', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          () => runtime.renameFunction('nonexistent', 'newName'),
          throwsA(isA<FunctionNotFoundError>()),
        );
      });

      test('throws CannotRenameStandardLibraryError for stdlib function', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          () => runtime.renameFunction('num.add', 'myAdd'),
          throwsA(isA<CannotRenameStandardLibraryError>()),
        );
      });

      test('throws FunctionAlreadyExistsError when new name exists', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition1 = compiler.functionDefinition(
          'first = 1',
        )!;
        final FunctionDefinition definition2 = compiler.functionDefinition(
          'second = 2',
        )!;
        runtime.defineFunction(definition1);
        runtime.defineFunction(definition2);

        expect(
          () => runtime.renameFunction('first', 'second'),
          throwsA(isA<FunctionAlreadyExistsError>()),
        );
      });

      test(
        'throws FunctionAlreadyExistsError when renaming to stdlib name',
        () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'myFunc = 42',
          )!;
          runtime.defineFunction(definition);

          expect(
            () => runtime.renameFunction('myFunc', 'num.add'),
            throwsA(isA<FunctionAlreadyExistsError>()),
          );
        },
      );
    });

    group('evaluateToTerm', () {
      test('returns NumberTerm for numeric expression', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Expression expression = getExpression('1 + 2');

        final Term result = runtime.evaluateToTerm(expression);

        expect(result, isA<NumberTerm>());
        expect(result.native(), 3);
      });

      test('returns StringTerm for string expression', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Expression expression = getExpression('"hello"');

        final Term result = runtime.evaluateToTerm(expression);

        expect(result, isA<StringTerm>());
        expect(result.native(), 'hello');
      });

      test('returns BooleanTerm for boolean expression', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Expression expression = getExpression('true');

        final Term result = runtime.evaluateToTerm(expression);

        expect(result, isA<BooleanTerm>());
        expect(result.native(), true);
      });

      test('returns ListTerm for list expression', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Expression expression = getExpression('[1, 2, 3]');

        final Term result = runtime.evaluateToTerm(expression);

        expect(result, isA<ListTerm>());
        expect(result.native(), [1, 2, 3]);
      });
    });

    group('format', () {
      test('formats numbers unchanged', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.format(42), 42);
        expect(runtime.format(3.14), 3.14);
      });

      test('formats booleans unchanged', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.format(true), true);
        expect(runtime.format(false), false);
      });

      test('formats strings with quotes', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.format('hello'), '"hello"');
      });

      test('formats lists recursively', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        // format() returns the formatted representation, which for lists
        // is still a list with formatted elements (not a string)
        expect(runtime.format([1, 2, 3]).toString(), '[1, 2, 3]');
      });

      test('formats nested lists', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          runtime.format([
            [1, 2],
            [3, 4],
          ]).toString(),
          '[[1, 2], [3, 4]]',
        );
      });
    });

    group('executeMain edge cases', () {
      test('executes main that returns a list', () {
        final RuntimeFacade runtime = getRuntime('main = [1, 2, 3]');
        expect(runtime.executeMain(), '[1, 2, 3]');
      });

      test('executes main that returns a boolean', () {
        final RuntimeFacade runtime = getRuntime('main = true');
        expect(runtime.executeMain(), 'true');
      });

      test('executes main that returns a string', () {
        final RuntimeFacade runtime = getRuntime('main = "hello"');
        expect(runtime.executeMain(), '"hello"');
      });

      test('executes main with empty arguments list', () {
        final RuntimeFacade runtime = getRuntime('main = 42');
        expect(runtime.executeMain([]), '42');
      });

      test('executes main that uses custom functions', () {
        final RuntimeFacade runtime = getRuntime('''
          double(x) = x * 2
          main = double(21)
        ''');
        expect(runtime.executeMain(), '42');
      });
    });

    group('mainExpression edge cases', () {
      test('returns main() call with empty arguments for zero-param main', () {
        final RuntimeFacade runtime = getRuntime('main = 42');
        final Expression expression = runtime.mainExpression(['ignored']);
        // When main has no parameters, arguments are ignored
        expect(expression.toString(), 'main()');
      });

      test('handles special characters in arguments', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain(['line1\nline2']);
        expect(result, '"line1\nline2"');
      });

      test('handles empty string argument', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain(['']);
        expect(result, '""');
      });
    });

    group('evaluate edge cases', () {
      test('evaluates expression with all standard operators', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.evaluate(getExpression('5 + 3')), '8');
        expect(runtime.evaluate(getExpression('5 - 3')), '2');
        expect(runtime.evaluate(getExpression('5 * 3')), '15');
        expect(runtime.evaluate(getExpression('6 / 3')), '2.0');
        expect(runtime.evaluate(getExpression('7 % 3')), '1');
      });

      test('evaluates comparison operators', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.evaluate(getExpression('5 > 3')), 'true');
        expect(runtime.evaluate(getExpression('5 < 3')), 'false');
        expect(runtime.evaluate(getExpression('5 >= 5')), 'true');
        expect(runtime.evaluate(getExpression('5 <= 5')), 'true');
        expect(runtime.evaluate(getExpression('5 == 5')), 'true');
        expect(runtime.evaluate(getExpression('5 != 3')), 'true');
      });

      test('evaluates logical operators', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.evaluate(getExpression('true && true')), 'true');
        expect(runtime.evaluate(getExpression('true && false')), 'false');
        expect(runtime.evaluate(getExpression('true || false')), 'true');
        expect(runtime.evaluate(getExpression('false || false')), 'false');
        expect(runtime.evaluate(getExpression('!true')), 'false');
        expect(runtime.evaluate(getExpression('!false')), 'true');
      });

      test('evaluates conditional expressions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.evaluate(getExpression('if (true) 1 else 2')), '1');
        expect(runtime.evaluate(getExpression('if (false) 1 else 2')), '2');
      });

      test('evaluates string concatenation', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          runtime.evaluate(getExpression('"hello" + " " + "world"')),
          '"hello world"',
        );
      });
    });

    group('defineFunction edge cases', () {
      test('restores previous signature on semantic analysis failure', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        // First define a valid function
        final FunctionDefinition validDefinition = compiler.functionDefinition(
          'myFunc(x) = x + 1',
        )!;
        runtime.defineFunction(validDefinition);

        // Try to redefine with an invalid body (undefined identifier)
        final FunctionDefinition invalidDefinition = compiler
            .functionDefinition(
              'myFunc(x) = undefined_var',
            )!;

        expect(
          () => runtime.defineFunction(invalidDefinition),
          throwsA(isA<UndefinedIdentifierError>()),
        );

        // Original function should still work
        expect(runtime.evaluate(getExpression('myFunc(5)')), '6');
      });

      test('removes signature when definition fails for new function', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        // Try to define a function with undefined identifier
        final FunctionDefinition invalidDefinition = compiler
            .functionDefinition(
              'newFunc(x) = undefined_var',
            )!;

        expect(
          () => runtime.defineFunction(invalidDefinition),
          throwsA(isA<UndefinedIdentifierError>()),
        );

        // Function should not exist
        expect(
          runtime.userDefinedFunctionSignatures,
          isNot(contains('newFunc(x)')),
        );
      });

      test('defines function with no parameters as constant', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'constant = 100',
        )!;

        runtime.defineFunction(definition);

        expect(runtime.userDefinedFunctionSignatures, ['constant()']);
        expect(runtime.evaluate(getExpression('constant()')), '100');
      });

      test('handles lambda-like higher order functions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition identity = compiler.functionDefinition(
          'identity(x) = x',
        )!;
        final FunctionDefinition apply = compiler.functionDefinition(
          'apply(f, x) = f(x)',
        )!;

        runtime.defineFunction(identity);
        runtime.defineFunction(apply);

        expect(runtime.evaluate(getExpression('apply(identity, 42)')), '42');
      });
    });

    group('evaluateToTerm additional types', () {
      test('returns SetTerm for set expression', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Expression expression = getExpression('set.new([1, 2, 3])');

        final Term result = runtime.evaluateToTerm(expression);

        expect(result, isA<SetTerm>());
        expect(result.native(), {1, 2, 3});
      });

      test('returns MapTerm for map expression', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Expression expression = getExpression('{"a": 1}');

        final Term result = runtime.evaluateToTerm(expression);

        expect(result, isA<MapTerm>());
        expect(result.native(), {'a': 1});
      });

      test('returns FunctionTerm for function reference', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Expression expression = getExpression('num.add');

        final Term result = runtime.evaluateToTerm(expression);

        expect(result, isA<FunctionTerm>());
      });

      test('returns empty ListTerm for empty list', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Expression expression = getExpression('[]');

        final Term result = runtime.evaluateToTerm(expression);

        expect(result, isA<ListTerm>());
        expect(result.native(), isEmpty);
      });
    });

    group('format additional types', () {
      test('formats empty list', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.format([]).toString(), '[]');
      });

      test('formats set', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.format({1, 2, 3}).toString(), '{1, 2, 3}');
      });

      test('formats empty set', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.format(<dynamic>{}).toString(), '{}');
      });

      test('formats map', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        final dynamic result = runtime.format({'a': 1, 'b': 2});
        expect(result, {'"a"': 1, '"b"': 2});
      });

      test('formats empty map', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.format(<String, int>{}).toString(), '{}');
      });

      test('formats mixed type list', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          runtime.format([1, 'hello', true]).toString(),
          '[1, "hello", true]',
        );
      });

      test('formats negative numbers', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.format(-42), -42);
        expect(runtime.format(-3.14), -3.14);
      });

      test('formats zero', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.format(0), 0);
        expect(runtime.format(0.0), 0.0);
      });

      test('formats empty string', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.format(''), '""');
      });
    });

    group('loadFromIntermediateRepresentation additional cases', () {
      test('loads mutually dependent functions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final IntermediateRepresentation representation =
            getIntermediateRepresentation('''
              isEven(n) = if (n == 0) true else isOdd(n - 1)
              isOdd(n) = if (n == 0) false else isEven(n - 1)
            ''');

        final int count = runtime.loadFromIntermediateRepresentation(
          representation,
        );

        expect(count, 2);
        expect(runtime.evaluate(getExpression('isEven(4)')), 'true');
        expect(runtime.evaluate(getExpression('isOdd(3)')), 'true');
      });

      test('functions from loaded IR can use standard library', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final IntermediateRepresentation representation =
            getIntermediateRepresentation('square(x) = num.mul(x, x)');

        runtime.loadFromIntermediateRepresentation(representation);

        expect(runtime.evaluate(getExpression('square(5)')), '25');
      });
    });

    group('hasMain edge cases', () {
      test('returns true when main has parameters', () {
        final RuntimeFacade runtime = getRuntime('main(x) = x');
        expect(runtime.hasMain, true);
      });

      test('returns true when main is one of several functions', () {
        final RuntimeFacade runtime = getRuntime('''
          helper(x) = x * 2
          main = helper(21)
        ''');
        expect(runtime.hasMain, true);
      });
    });

    group('evaluate error handling', () {
      test('throws DivisionByZeroError for division by zero', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          () => runtime.evaluate(getExpression('1 / 0')),
          throwsA(isA<DivisionByZeroError>()),
        );
      });

      test('throws DivisionByZeroError for negative division by zero', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          () => runtime.evaluate(getExpression('-1 / 0')),
          throwsA(isA<DivisionByZeroError>()),
        );
      });
    });

    group('deleteFunction edge cases', () {
      test('deletes function loaded from IR', () {
        final RuntimeFacade runtime = getRuntime('myFunc(x) = x * 2');
        expect(runtime.userDefinedFunctionSignatures, ['myFunc(x)']);

        runtime.deleteFunction('myFunc');

        expect(runtime.userDefinedFunctionSignatures, isEmpty);
      });

      test('allows deletion after renaming a function', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'original = 42',
        )!;
        runtime.defineFunction(definition);
        runtime.renameFunction('original', 'renamed');

        runtime.deleteFunction('renamed');

        expect(runtime.userDefinedFunctionSignatures, isEmpty);
      });
    });

    group('renameFunction edge cases', () {
      test('renamed function executes correctly', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'double(x) = x * 2',
        )!;
        runtime.defineFunction(definition);

        runtime.renameFunction('double', 'twice');

        expect(runtime.evaluate(getExpression('twice(5)')), '10');
      });

      test('can rename to single character name', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'longName = 42',
        )!;
        runtime.defineFunction(definition);

        runtime.renameFunction('longName', 'x');

        expect(runtime.userDefinedFunctionSignatures, ['x()']);
      });

      test('can rename constant to function-like name', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'pi = 3.14',
        )!;
        runtime.defineFunction(definition);

        runtime.renameFunction('pi', 'getPi');

        expect(runtime.userDefinedFunctionSignatures, ['getPi()']);
        expect(runtime.evaluate(getExpression('getPi()')), '3.14');
      });
    });

    group('userDefinedFunctionSignatures edge cases', () {
      test('excludes standard library functions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.userDefinedFunctionSignatures, isEmpty);
        // Standard library functions should still work
        expect(runtime.evaluate(getExpression('num.add(1, 2)')), '3');
      });

      test('preserves function signature format with underscores', () {
        final RuntimeFacade runtime = getRuntime(
          'my_function(a_param) = a_param',
        );
        expect(runtime.userDefinedFunctionSignatures, ['my_function(a_param)']);
      });
    });

    group('reset edge cases', () {
      test('multiple resets are idempotent', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'value = 42',
        )!;
        runtime.defineFunction(definition);

        runtime.reset();
        runtime.reset();
        runtime.reset();

        expect(runtime.userDefinedFunctionSignatures, isEmpty);
      });

      test('reset on empty runtime does not throw', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.reset, returnsNormally);
      });
    });

    group('mainExpression with null main', () {
      test('returns main() call even when main does not exist', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        final Expression expression = runtime.mainExpression([]);

        expect(expression.toString(), 'main()');
      });

      test('returns main() with no arguments even when arguments provided', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        final Expression expression = runtime.mainExpression([
          'ignored',
          'args',
        ]);

        expect(expression.toString(), 'main()');
      });
    });

    group('defineFunction with complex expressions', () {
      test('defines function using list operations', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'sumList(items) = list.reduce(items, 0, num.add)',
        )!;

        runtime.defineFunction(definition);

        expect(runtime.evaluate(getExpression('sumList([1, 2, 3, 4])')), '10');
      });

      test('defines function with deeply nested conditionals', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'classify(n) = if (n < 0) "negative" else if (n == 0) "zero" else "positive"',
        )!;

        runtime.defineFunction(definition);

        expect(runtime.evaluate(getExpression('classify(-5)')), '"negative"');
        expect(runtime.evaluate(getExpression('classify(0)')), '"zero"');
        expect(runtime.evaluate(getExpression('classify(5)')), '"positive"');
      });
    });

    group('evaluate with various literal types', () {
      test('evaluates negative number', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.evaluate(getExpression('-42')), '-42');
      });

      test('evaluates floating point number', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.evaluate(getExpression('3.14159')), '3.14159');
      });

      test('evaluates string with special characters', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          runtime.evaluate(getExpression('"hello\\nworld"')),
          '"hello\nworld"',
        );
      });

      test('evaluates empty list', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.evaluate(getExpression('[]')), '[]');
      });

      test('evaluates single element list', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.evaluate(getExpression('[42]')), '[42]');
      });

      test('evaluates false boolean', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.evaluate(getExpression('false')), 'false');
      });
    });

    group('executeMain with edge case arguments', () {
      test('handles argument with only whitespace', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain(['   ']);
        expect(result, '"   "');
      });

      test('handles argument with unicode characters', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain(['\u00e9\u00e0\u00fc']);
        expect(result, '"\u00e9\u00e0\u00fc"');
      });

      test('handles very long argument', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String longString = 'x' * 1000;
        final String result = runtime.executeMain([longString]);
        expect(result, '"$longString"');
      });

      test('handles multiple empty string arguments', () {
        final RuntimeFacade runtime = getRuntime('main(a, b, c) = a + b + c');
        final String result = runtime.executeMain(['', '', '']);
        expect(result, '""');
      });
    });

    group('intermediateRepresentation property', () {
      test('returns the intermediate representation passed to constructor', () {
        final IntermediateRepresentation representation =
            getIntermediateRepresentation('myFunc(x) = x');
        final RuntimeFacade runtime = RuntimeFacade(
          representation,
          compiler.expression,
        );

        expect(runtime.intermediateRepresentation, same(representation));
      });

      test(
        'empty intermediate representation has standard library signatures',
        () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.intermediateRepresentation.standardLibrarySignatures,
            isNotEmpty,
          );
          expect(
            runtime.intermediateRepresentation.standardLibrarySignatures
                .containsKey('num.add'),
            isTrue,
          );
        },
      );
    });

    group('defineFunction parameter validation', () {
      test('throws for three duplicate parameters', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'bad(x, x, x) = x',
        )!;

        expect(
          () => runtime.defineFunction(definition),
          throwsA(isA<DuplicatedParameterError>()),
        );
      });

      test('allows parameters with similar names', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'func(x, x1, x2) = x + x1 + x2',
        )!;

        runtime.defineFunction(definition);

        expect(runtime.evaluate(getExpression('func(1, 2, 3)')), '6');
      });

      test('allows parameter with leading underscore', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'constant(unused) = 42',
        )!;

        runtime.defineFunction(definition);

        expect(runtime.evaluate(getExpression('constant(999)')), '42');
      });
    });

    group('executeMain error handling', () {
      test('throws UndefinedFunctionError when main is not defined', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          runtime.executeMain,
          throwsA(isA<UndefinedFunctionError>()),
        );
      });

      test(
        'throws UndefinedFunctionError when main is not defined with args',
        () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            () => runtime.executeMain(['arg1']),
            throwsA(isA<UndefinedFunctionError>()),
          );
        },
      );
    });

    group('evaluate error handling additional cases', () {
      test('throws UndefinedFunctionError for calling undefined function', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          () => runtime.evaluate(getExpression('undefined_func(1)')),
          throwsA(isA<UndefinedFunctionError>()),
        );
      });

      test('throws InvalidNumberOfArgumentsError for wrong argument count', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          () => runtime.evaluate(getExpression('num.add(1)')),
          throwsA(isA<InvalidNumberOfArgumentsError>()),
        );
      });

      test('throws InvalidNumberOfArgumentsError for too many arguments', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          () => runtime.evaluate(getExpression('num.add(1, 2, 3)')),
          throwsA(isA<InvalidNumberOfArgumentsError>()),
        );
      });

      test('throws DivisionByZeroError for modulo by zero', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          () => runtime.evaluate(getExpression('5 % 0')),
          throwsA(isA<DivisionByZeroError>()),
        );
      });

      test('throws RecursionLimitError for infinite recursion', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'infinite(x) = infinite(x)',
        )!;
        runtime.defineFunction(definition);

        expect(
          () => runtime.evaluate(getExpression('infinite(1)')),
          throwsA(isA<RecursionLimitError>()),
        );
      });

      test('throws RecursionLimitError for mutual infinite recursion', () {
        final RuntimeFacade runtime = getRuntime('''
          ping(x) = pong(x)
          pong(x) = ping(x)
        ''');

        expect(
          () => runtime.evaluate(getExpression('ping(1)')),
          throwsA(isA<RecursionLimitError>()),
        );
      });
    });

    group('evaluateToTerm error handling', () {
      test('throws for undefined function call', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          () => runtime.evaluateToTerm(getExpression('nonexistent()')),
          throwsA(isA<UndefinedFunctionError>()),
        );
      });

      test('throws DivisionByZeroError through evaluateToTerm', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          () => runtime.evaluateToTerm(getExpression('1 / 0')),
          throwsA(isA<DivisionByZeroError>()),
        );
      });
    });

    group('format with special types', () {
      test('formats DateTime as ISO8601 string', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final DateTime dateTime = DateTime.utc(2024, 1, 15, 10, 30, 0);

        expect(runtime.format(dateTime), '"2024-01-15T10:30:00.000Z"');
      });

      test('formats DateTime with milliseconds', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final DateTime dateTime = DateTime.utc(2024, 6, 15, 14, 30, 45, 123);

        expect(runtime.format(dateTime), '"2024-06-15T14:30:45.123Z"');
      });
    });

    group('evaluate with user-defined functions', () {
      test('evaluates chained function calls', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition addOne = compiler.functionDefinition(
          'addOne(x) = x + 1',
        )!;
        final FunctionDefinition multiplyTwo = compiler.functionDefinition(
          'multiplyTwo(x) = x * 2',
        )!;
        runtime.defineFunction(addOne);
        runtime.defineFunction(multiplyTwo);

        expect(
          runtime.evaluate(getExpression('multiplyTwo(addOne(5))')),
          '12',
        );
      });

      test('evaluates function with conditional returning function call', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition double = compiler.functionDefinition(
          'double(x) = x * 2',
        )!;
        final FunctionDefinition triple = compiler.functionDefinition(
          'triple(x) = x * 3',
        )!;
        final FunctionDefinition
        conditionalMultiply = compiler.functionDefinition(
          'conditionalMultiply(x, useDouble) = if (useDouble) double(x) else triple(x)',
        )!;
        runtime.defineFunction(double);
        runtime.defineFunction(triple);
        runtime.defineFunction(conditionalMultiply);

        expect(
          runtime.evaluate(getExpression('conditionalMultiply(5, true)')),
          '10',
        );
        expect(
          runtime.evaluate(getExpression('conditionalMultiply(5, false)')),
          '15',
        );
      });
    });

    group('loadFromIntermediateRepresentation edge cases', () {
      test('replaces existing dynamically defined function', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition oldDouble = compiler.functionDefinition(
          'double(x) = x * 2',
        )!;
        runtime.defineFunction(oldDouble);
        expect(runtime.evaluate(getExpression('double(5)')), '10');

        // Load IR with different 'double' implementation
        final IntermediateRepresentation representation =
            getIntermediateRepresentation('double(x) = x + x');
        runtime.loadFromIntermediateRepresentation(representation);

        // New function should work the same but old dynamic one is replaced
        expect(runtime.evaluate(getExpression('double(5)')), '10');
      });

      test('handles function with complex body from IR', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final IntermediateRepresentation representation =
            getIntermediateRepresentation(
              'absolute(x) = if (x < 0) 0 - x else x',
            );

        runtime.loadFromIntermediateRepresentation(representation);

        expect(runtime.evaluate(getExpression('absolute(-5)')), '5');
        expect(runtime.evaluate(getExpression('absolute(5)')), '5');
        expect(runtime.evaluate(getExpression('absolute(0)')), '0');
      });
    });

    group('renameFunction referential integrity', () {
      test('renamed function can still be called', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'originalSum(a, b) = a + b',
        )!;
        runtime.defineFunction(definition);

        runtime.renameFunction('originalSum', 'renamedSum');

        expect(runtime.evaluate(getExpression('renamedSum(3, 4)')), '7');
      });

      test('renamed function no longer accessible by old name', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'myFunc = 42',
        )!;
        runtime.defineFunction(definition);
        runtime.renameFunction('myFunc', 'yourFunc');

        expect(
          () => runtime.evaluate(getExpression('myFunc()')),
          throwsA(isA<UndefinedFunctionError>()),
        );
      });
    });

    group('defineFunction with expressions returning different types', () {
      test('defines function returning map', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'makeMap(k, v) = {k: v}',
        )!;
        runtime.defineFunction(definition);

        expect(
          runtime.evaluate(getExpression('makeMap("name", "Alice")')),
          '{"name": "Alice"}',
        );
      });

      test('defines function returning set', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'makeSet(items) = set.new(items)',
        )!;
        runtime.defineFunction(definition);

        final Term result = runtime.evaluateToTerm(
          getExpression('makeSet([1, 2, 3])'),
        );
        expect(result, isA<SetTerm>());
      });

      test('defines function that transforms list', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition doubleValue = compiler.functionDefinition(
          'doubleValue(x) = x * 2',
        )!;
        final FunctionDefinition doubleAll = compiler.functionDefinition(
          'doubleAll(items) = list.map(items, doubleValue)',
        )!;
        runtime.defineFunction(doubleValue);
        runtime.defineFunction(doubleAll);

        expect(
          runtime.evaluate(getExpression('doubleAll([1, 2, 3])')),
          '[2, 4, 6]',
        );
      });
    });

    group('evaluate with boundary values', () {
      test('evaluates very large number', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          runtime.evaluate(getExpression('999999999999999')),
          '999999999999999',
        );
      });

      test('evaluates very small negative number', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          runtime.evaluate(getExpression('-999999999999999')),
          '-999999999999999',
        );
      });

      test('evaluates deeply nested list', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          runtime.evaluate(getExpression('[[[[1]]]]')),
          '[[[[1]]]]',
        );
      });

      test('evaluates list with many elements', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          runtime.evaluate(getExpression('[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]')),
          '[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]',
        );
      });

      test('evaluates empty map', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(runtime.evaluate(getExpression('{}')), '{}');
      });
    });

    group('format edge cases', () {
      test('formats list containing strings with quotes', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          runtime.format(['hello', 'world']).toString(),
          '["hello", "world"]',
        );
      });

      test('formats map with numeric keys', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        final dynamic result = runtime.format({1: 'one', 2: 'two'});
        expect(result, {1: '"one"', 2: '"two"'});
      });

      test('formats nested map', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        final dynamic result = runtime.format({
          'outer': {'inner': 1},
        });
        expect(result, {
          '"outer"': {'"inner"': 1},
        });
      });

      test('formats list containing map', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        final dynamic result = runtime.format([
          {'key': 'value'},
        ]);
        expect(result.toString(), '[{"key": "value"}]');
      });

      test('formats set containing strings', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        final dynamic result = runtime.format({'a', 'b', 'c'});
        expect(result, {'"a"', '"b"', '"c"'});
      });
    });

    group('reset interaction with other operations', () {
      test('reset followed by define followed by load clears defined', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'manuallyDefined = 1',
        )!;
        runtime.defineFunction(definition);
        runtime.reset();
        final FunctionDefinition anotherDefinition = compiler
            .functionDefinition(
              'anotherFunc = 2',
            )!;
        runtime.defineFunction(anotherDefinition);

        final IntermediateRepresentation representation =
            getIntermediateRepresentation('loadedFunc = 3');
        runtime.loadFromIntermediateRepresentation(representation);

        // Only loadedFunc should exist
        expect(runtime.userDefinedFunctionSignatures, ['loadedFunc()']);
      });

      test('delete after reset throws FunctionNotFoundError', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'toBeDeleted = 42',
        )!;
        runtime.defineFunction(definition);
        runtime.reset();

        expect(
          () => runtime.deleteFunction('toBeDeleted'),
          throwsA(isA<FunctionNotFoundError>()),
        );
      });
    });

    group('mainExpression with special argument values', () {
      test('handles argument with tab character', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain(['hello\tworld']);
        expect(result, '"hello\tworld"');
      });

      test('handles argument with multiple newlines', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain(['line1\n\nline3']);
        expect(result, '"line1\n\nline3"');
      });

      test('handles numeric-like string argument', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain(['123']);
        expect(result, '"123"');
      });

      test('handles boolean-like string argument', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain(['true']);
        expect(result, '"true"');
      });
    });

    group('evaluate with function composition', () {
      test('passes function as argument to higher-order function', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition double = compiler.functionDefinition(
          'double(x) = x * 2',
        )!;
        runtime.defineFunction(double);

        expect(
          runtime.evaluate(getExpression('list.map([1, 2, 3], double)')),
          '[2, 4, 6]',
        );
      });

      test('uses stdlib function as argument', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );

        expect(
          runtime.evaluate(getExpression('list.map([1, 2, 3], num.abs)')),
          '[1, 2, 3]',
        );
      });
    });

    group('userDefinedFunctionSignatures comprehensive', () {
      test('maintains correct count after multiple operations', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition func1 = compiler.functionDefinition(
          'func1 = 1',
        )!;
        final FunctionDefinition func2 = compiler.functionDefinition(
          'func2 = 2',
        )!;
        final FunctionDefinition func3 = compiler.functionDefinition(
          'func3 = 3',
        )!;

        runtime.defineFunction(func1);
        runtime.defineFunction(func2);
        runtime.defineFunction(func3);
        expect(runtime.userDefinedFunctionSignatures.length, 3);

        runtime.deleteFunction('func2');
        expect(runtime.userDefinedFunctionSignatures.length, 2);

        runtime.renameFunction('func1', 'renamedFunc1');
        expect(runtime.userDefinedFunctionSignatures.length, 2);
        expect(
          runtime.userDefinedFunctionSignatures,
          ['func3()', 'renamedFunc1()'],
        );
      });

      test('returns signatures with complex parameter types', () {
        final RuntimeFacade runtime = getRuntime(
          'complexFunc(list, map, callback) = callback(list, map)',
        );
        expect(
          runtime.userDefinedFunctionSignatures,
          ['complexFunc(list, map, callback)'],
        );
      });
    });

    group('evaluateToTerm value extraction', () {
      test('extracts correct native value from NumberTerm', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Term result = runtime.evaluateToTerm(getExpression('42'));

        expect(result.native(), 42);
      });

      test('extracts correct native value from nested ListTerm', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Term result = runtime.evaluateToTerm(
          getExpression('[[1, 2], [3, 4]]'),
        );

        expect(
          result.native(),
          [
            [1, 2],
            [3, 4],
          ],
        );
      });

      test('extracts correct native value from MapTerm', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Term result = runtime.evaluateToTerm(
          getExpression('{"x": 1, "y": 2}'),
        );

        expect(result.native(), {'x': 1, 'y': 2});
      });
    });

    group('defineFunction signature tracking', () {
      test('signature is available immediately after definition', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'newFunc(a, b) = a + b',
        )!;

        runtime.defineFunction(definition);

        expect(
          runtime.userDefinedFunctionSignatures,
          contains('newFunc(a, b)'),
        );
      });

      test('signature with many parameters is formatted correctly', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'manyParams(a, b, c, d, e) = a + b + c + d + e',
        )!;

        runtime.defineFunction(definition);

        expect(
          runtime.userDefinedFunctionSignatures,
          ['manyParams(a, b, c, d, e)'],
        );
      });
    });

    group('Let expressions', () {
      group('basic let evaluation', () {
        test('evaluates simple let with single binding', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(runtime.evaluate(getExpression('let x = 5 in x')), '5');
        });

        test('evaluates let with expression in body', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(runtime.evaluate(getExpression('let x = 5 in x + 3')), '8');
        });

        test('evaluates let with multiple bindings', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(getExpression('let x = 1, y = 2 in x + y')),
            '3',
          );
        });

        test('evaluates let with sequential binding dependency', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(getExpression('let x = 1, y = x + 1 in y')),
            '2',
          );
        });

        test('evaluates let with three sequential bindings', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('let a = 1, b = a + 1, c = b + 1 in a + b + c'),
            ),
            '6',
          );
        });
      });

      group('let with function parameters', () {
        test('let binding uses function parameter', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'f(x) = let y = x + 1 in y',
          )!;
          runtime.defineFunction(definition);

          expect(runtime.evaluate(getExpression('f(5)')), '6');
        });

        test('let binding uses multiple function parameters', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'f(a, b) = let sum = a + b in sum * 2',
          )!;
          runtime.defineFunction(definition);

          expect(runtime.evaluate(getExpression('f(3, 4)')), '14');
        });

        test('multiple let bindings use function parameters', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'f(x) = let a = x, b = a + x in b',
          )!;
          runtime.defineFunction(definition);

          expect(runtime.evaluate(getExpression('f(5)')), '10');
        });

        test('let does not shadow function parameter', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'f(x) = let y = x in x + y',
          )!;
          runtime.defineFunction(definition);

          expect(runtime.evaluate(getExpression('f(3)')), '6');
        });
      });

      group('let with if expressions', () {
        test('let in if condition', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('if (let x = true in x) 1 else 2'),
            ),
            '1',
          );
        });

        test('let in then branch', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('if (true) let x = 5 in x else 0'),
            ),
            '5',
          );
        });

        test('let in else branch', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('if (false) 0 else let x = 10 in x'),
            ),
            '10',
          );
        });

        test('let wrapping entire if expression', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('let cond = true in if (cond) 1 else 2'),
            ),
            '1',
          );
        });

        test('let binding used in conditional branches', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('let x = 5 in if (x > 3) x * 2 else x'),
            ),
            '10',
          );
        });

        test('nested conditionals with let', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression(
                'let x = 5 in if (x > 10) "big" else if (x > 3) "medium" else "small"',
              ),
            ),
            '"medium"',
          );
        });
      });

      group('let in list/map elements', () {
        test('let in list element', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(getExpression('[let x = 1 in x, 2, 3]')),
            '[1, 2, 3]',
          );
        });

        test('multiple let expressions in list', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('[let a = 1 in a, let b = 2 in b, let c = 3 in c]'),
            ),
            '[1, 2, 3]',
          );
        });

        test('let wrapping list', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(getExpression('let x = 5 in [x, x + 1, x + 2]')),
            '[5, 6, 7]',
          );
        });

        test('let in map value', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(getExpression('{"key": let x = 42 in x}')),
            '{"key": 42}',
          );
        });

        test('let in map key', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(getExpression('{let k = "key" in k: 1}')),
            '{"key": 1}',
          );
        });

        test('let wrapping map', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('let x = 1, y = 2 in {"a": x, "b": y}'),
            ),
            '{"a": 1, "b": 2}',
          );
        });
      });

      group('nested let expressions', () {
        test('let inside let body', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('let x = 1 in let y = 2 in x + y'),
            ),
            '3',
          );
        });

        test('inner let references outer let binding', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('let x = 5 in let y = x + 1 in y'),
            ),
            '6',
          );
        });

        test('inner let uses different binding names', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('let x = 1 in let y = 2 in x + y'),
            ),
            '3',
          );
        });

        test('deeply nested let expressions', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression(
                'let a = 1 in let b = a + 1 in let c = b + 1 in a + b + c',
              ),
            ),
            '6',
          );
        });

        test('let in binding value of another let', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('let x = let y = 5 in y * 2 in x + 1'),
            ),
            '11',
          );
        });

        test('nested let with independent bindings', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          // Inner let y=2 uses outer x=1
          // After inner let completes, outer x is still accessible
          expect(
            runtime.evaluate(
              getExpression(
                'let x = 1 in (let y = x + 1 in y) + x',
              ),
            ),
            '3',
          );
        });
      });

      group('let with function shadowing', () {
        test('let binding shadows function name', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'double(x) = x * 2',
          )!;
          runtime.defineFunction(definition);

          // let binding 'double' shadows the function 'double'
          expect(
            runtime.evaluate(
              getExpression('let double = 10 in double'),
            ),
            '10',
          );
        });

        test('let binding shadows stdlib function', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          // After let, we can still use num.add outside the let
          expect(
            runtime.evaluate(
              getExpression('(let num.add = 100 in num.add) + num.add(1, 2)'),
            ),
            '103',
          );
        });

        test('function usable after let scope ends', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'double(x) = x * 2',
          )!;
          runtime.defineFunction(definition);

          // After let scope, double function should work again
          expect(
            runtime.evaluate(
              getExpression('(let double = 5 in double) + double(3)'),
            ),
            '11',
          );
        });
      });

      group('higher-order let bindings', () {
        test('let binding holds function reference', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'double(x) = x * 2',
          )!;
          runtime.defineFunction(definition);

          expect(
            runtime.evaluate(
              getExpression('let f = double in f(5)'),
            ),
            '10',
          );
        });

        test('let binding holds stdlib function', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('let add = num.add in add(3, 4)'),
            ),
            '7',
          );
        });

        test('let binding used with list.map', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'double(x) = x * 2',
          )!;
          runtime.defineFunction(definition);

          expect(
            runtime.evaluate(
              getExpression('let f = double in list.map([1, 2, 3], f)'),
            ),
            '[2, 4, 6]',
          );
        });

        test('let binding holds identity function', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'identity(x) = x',
          )!;
          runtime.defineFunction(definition);

          expect(
            runtime.evaluate(
              getExpression('let id = identity in id(42)'),
            ),
            '42',
          );
        });

        test('let binding holds function used with multiple args', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('let add = num.add in add(5, 3)'),
            ),
            '8',
          );
        });
      });

      group('let error propagation', () {
        test('error in binding value propagates', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            () => runtime.evaluate(getExpression('let x = 1 / 0 in x')),
            throwsA(isA<DivisionByZeroError>()),
          );
        });

        test('error in body propagates', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            () => runtime.evaluate(getExpression('let x = 0 in 1 / x')),
            throwsA(isA<DivisionByZeroError>()),
          );
        });

        test('error in second binding propagates', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            () => runtime.evaluate(
              getExpression('let x = 1, y = x / 0 in y'),
            ),
            throwsA(isA<DivisionByZeroError>()),
          );
        });

        test('recursion limit error in let body', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'infinite(x) = infinite(x)',
          )!;
          runtime.defineFunction(definition);

          expect(
            () => runtime.evaluate(
              getExpression('let f = infinite in f(1)'),
            ),
            throwsA(isA<RecursionLimitError>()),
          );
        });

        test('undefined function error in let body', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            () => runtime.evaluate(
              getExpression('let x = 1 in undefined_func(x)'),
            ),
            throwsA(isA<UndefinedFunctionError>()),
          );
        });
      });

      group('REPL-style let operations', () {
        test('define function using let expression', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'compute(x, y) = let sum = x + y, product = x * y in sum + product',
          )!;

          runtime.defineFunction(definition);

          expect(runtime.evaluate(getExpression('compute(2, 3)')), '11');
        });

        test('define recursive function with let for intermediate values', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'fib(n) = if (n <= 1) n else let a = fib(n - 1), b = fib(n - 2) in a + b',
          )!;

          runtime.defineFunction(definition);

          expect(runtime.evaluate(getExpression('fib(6)')), '8');
        });

        test('redefine function with different let structure', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition1 = compiler.functionDefinition(
            'f(x) = let a = x in a',
          )!;
          final FunctionDefinition definition2 = compiler.functionDefinition(
            'f(x) = let a = x, b = a in b',
          )!;

          runtime.defineFunction(definition1);
          expect(runtime.evaluate(getExpression('f(5)')), '5');

          runtime.defineFunction(definition2);
          expect(runtime.evaluate(getExpression('f(10)')), '10');
        });

        test('evaluate standalone let expression in REPL', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          // Simulate REPL evaluating expressions
          expect(
            runtime.evaluate(
              getExpression('let x = 10, y = 20 in x * y'),
            ),
            '200',
          );
        });

        test('let in main function', () {
          final RuntimeFacade runtime = getRuntime(
            'main = let greeting = "Hello" in greeting',
          );

          expect(runtime.executeMain(), '"Hello"');
        });

        test('let in main function with arguments', () {
          final RuntimeFacade runtime = getRuntime(
            'main(name) = let greeting = "Hello, " in greeting + name',
          );

          expect(runtime.executeMain(['World']), '"Hello, World"');
        });

        test('complex let in executeMain', () {
          final RuntimeFacade runtime = getRuntime('''
            helper(x) = x * 2
            main = let x = 5, y = helper(x) in y + 1
          ''');

          expect(runtime.executeMain(), '11');
        });
      });

      group('let with various types', () {
        test('let with string binding', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(getExpression('let s = "hello" in s + " world"')),
            '"hello world"',
          );
        });

        test('let with boolean binding', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(getExpression('let b = true in !b')),
            'false',
          );
        });

        test('let with list binding', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('let items = [1, 2, 3] in list.length(items)'),
            ),
            '3',
          );
        });

        test('let with map binding', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression('let m = {"a": 1} in map.at(m, "a")'),
            ),
            '1',
          );
        });

        test('let with set binding', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            runtime.evaluate(
              getExpression(
                'let s = set.new([1, 2, 3]) in set.contains(s, 2)',
              ),
            ),
            'true',
          );
        });
      });

      group('let evaluateToTerm', () {
        test('evaluateToTerm with let returns correct term type', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          final Term result = runtime.evaluateToTerm(
            getExpression('let x = 42 in x'),
          );

          expect(result, isA<NumberTerm>());
          expect(result.native(), 42);
        });

        test('evaluateToTerm with let returning list', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          final Term result = runtime.evaluateToTerm(
            getExpression('let x = 1 in [x, x + 1]'),
          );

          expect(result, isA<ListTerm>());
          expect(result.native(), [1, 2]);
        });

        test('evaluateToTerm with let returning function', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          final Term result = runtime.evaluateToTerm(
            getExpression('let f = num.add in f'),
          );

          expect(result, isA<FunctionTerm>());
        });
      });

      group('let runtime error cases', () {
        test('index let-bound map', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'f(m) = let map = m in map["a"]',
          )!;
          runtime.defineFunction(definition);

          expect(
            runtime.evaluate(getExpression('f({"a": 42})')),
            '42',
          );
        });

        test('non-callable let binding throws InvalidFunctionError', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'f(n) = let x = 5 in x(n)',
          )!;
          runtime.defineFunction(definition);

          expect(
            () => runtime.evaluate(getExpression('f(1)')),
            throwsA(isA<InvalidFunctionError>()),
          );
        });

        test('non-indexable let binding throws InvalidArgumentTypesError', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );
          final FunctionDefinition definition = compiler.functionDefinition(
            'f(n) = let x = 5 in x[0]',
          )!;
          runtime.defineFunction(definition);

          expect(
            () => runtime.evaluate(getExpression('f(1)')),
            throwsA(isA<InvalidArgumentTypesError>()),
          );
        });

        test('REPL error has no function context', () {
          final RuntimeFacade runtime = RuntimeFacade(
            IntermediateRepresentation.empty(),
            compiler.expression,
          );

          expect(
            () => runtime.evaluate(getExpression('let x = x in x')),
            throwsA(
              isA<UndefinedIdentifierError>().having(
                (e) => e.message,
                'message',
                isNot(contains('in function')),
              ),
            ),
          );
        });
      });
    });
  });
}
