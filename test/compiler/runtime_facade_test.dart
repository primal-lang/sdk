@Tags(['compiler'])
library;

import 'package:primal/compiler/compiler.dart';
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
  });
}
