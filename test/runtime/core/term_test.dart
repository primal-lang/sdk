@Tags(['runtime'])
@TestOn('vm')
library;

import 'dart:io';

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/function_signature.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/bindings.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:test/test.dart';

/// Test double for [FunctionTerm] since it is abstract.
class TestFunctionTerm extends FunctionTerm {
  const TestFunctionTerm({required super.name, required super.parameters});
}

/// Test double for [NativeFunctionTerm] since it is abstract.
class TestNativeFunctionTerm extends NativeFunctionTerm {
  final Term Function(List<Term>) termFunction;

  const TestNativeFunctionTerm({
    required super.name,
    required super.parameters,
    required this.termFunction,
  });

  @override
  Term term(List<Term> arguments) => termFunction(arguments);
}

void main() {
  group('ValueTerm.from()', () {
    test('bool returns BooleanTerm', () {
      final ValueTerm term = ValueTerm.from(true);
      expect(term, isA<BooleanTerm>());
    });

    test('int returns NumberTerm', () {
      final ValueTerm term = ValueTerm.from(42);
      expect(term, isA<NumberTerm>());
    });

    test('double returns NumberTerm', () {
      final ValueTerm term = ValueTerm.from(3.14);
      expect(term, isA<NumberTerm>());
    });

    test('String returns StringTerm', () {
      final ValueTerm term = ValueTerm.from('hello');
      expect(term, isA<StringTerm>());
    });

    test('List<Term> returns ListTerm', () {
      final ValueTerm term = ValueTerm.from(<Term>[const NumberTerm(1)]);
      expect(term, isA<ListTerm>());
    });

    test('Map<Term, Term> returns MapTerm', () {
      final ValueTerm term = ValueTerm.from(
        <Term, Term>{const StringTerm('a'): const NumberTerm(1)},
      );
      expect(term, isA<MapTerm>());
    });

    test('DateTime returns TimestampTerm', () {
      final ValueTerm term = ValueTerm.from(DateTime(2024));
      expect(term, isA<TimestampTerm>());
    });

    test('File returns FileTerm', () {
      final ValueTerm term = ValueTerm.from(File('test.txt'));
      expect(term, isA<FileTerm>());
    });

    test('Directory returns DirectoryTerm', () {
      final ValueTerm term = ValueTerm.from(Directory('test'));
      expect(term, isA<DirectoryTerm>());
    });

    test('Set<Term> returns SetTerm', () {
      final ValueTerm term = ValueTerm.from(<Term>{const NumberTerm(1)});
      expect(term, isA<SetTerm>());
    });

    test('unsupported type throws InvalidLiteralValueError', () {
      expect(
        () => ValueTerm.from(Object()),
        throwsA(isA<InvalidLiteralValueError>()),
      );
    });
  });

  group('BooleanTerm', () {
    const BooleanTerm term = BooleanTerm(true);

    test('type is BooleanType', () {
      expect(term.type, isA<BooleanType>());
    });

    test('value is correct', () {
      expect(term.value, true);
    });

    test('native() returns raw bool', () {
      expect(term.native(), true);
    });

    test('toString() returns string representation', () {
      expect(term.toString(), 'true');
    });

    test('substitute() returns itself', () {
      const Bindings bindings = Bindings({});
      expect(term.substitute(bindings), same(term));
    });

    test('reduce() returns itself', () {
      expect(term.reduce(), same(term));
    });

    test('false value', () {
      const BooleanTerm falseTerm = BooleanTerm(false);
      expect(falseTerm.native(), false);
      expect(falseTerm.toString(), 'false');
    });
  });

  group('NumberTerm', () {
    const NumberTerm intTerm = NumberTerm(42);
    const NumberTerm doubleTerm = NumberTerm(3.14);

    test('type is NumberType', () {
      expect(intTerm.type, isA<NumberType>());
    });

    test('int value is correct', () {
      expect(intTerm.value, 42);
    });

    test('double value is correct', () {
      expect(doubleTerm.value, 3.14);
    });

    test('native() returns raw int', () {
      expect(intTerm.native(), 42);
    });

    test('native() returns raw double', () {
      expect(doubleTerm.native(), 3.14);
    });

    test('toString() for int', () {
      expect(intTerm.toString(), '42');
    });

    test('toString() for double', () {
      expect(doubleTerm.toString(), '3.14');
    });

    test('substitute() returns itself', () {
      const Bindings bindings = Bindings({});
      expect(intTerm.substitute(bindings), same(intTerm));
    });

    test('reduce() returns itself', () {
      expect(intTerm.reduce(), same(intTerm));
    });

    test('zero value', () {
      const NumberTerm zeroTerm = NumberTerm(0);
      expect(zeroTerm.native(), 0);
    });

    test('negative value', () {
      const NumberTerm negTerm = NumberTerm(-7);
      expect(negTerm.native(), -7);
    });
  });

  group('StringTerm', () {
    const StringTerm term = StringTerm('hello');

    test('type is StringType', () {
      expect(term.type, isA<StringType>());
    });

    test('value is correct', () {
      expect(term.value, 'hello');
    });

    test('native() returns raw string', () {
      expect(term.native(), 'hello');
    });

    test('toString() returns string representation', () {
      expect(term.toString(), 'hello');
    });

    test('substitute() returns itself', () {
      const Bindings bindings = Bindings({});
      expect(term.substitute(bindings), same(term));
    });

    test('reduce() returns itself', () {
      expect(term.reduce(), same(term));
    });

    test('empty string', () {
      const StringTerm emptyTerm = StringTerm('');
      expect(emptyTerm.native(), '');
      expect(emptyTerm.toString(), '');
    });
  });

  group('ListTerm', () {
    test('native() returns list of native values', () {
      const ListTerm term = ListTerm([
        NumberTerm(1),
        NumberTerm(2),
        NumberTerm(3),
      ]);
      expect(term.native(), [1, 2, 3]);
    });

    test('native() with mixed types', () {
      const ListTerm term = ListTerm([
        NumberTerm(1),
        StringTerm('two'),
        BooleanTerm(true),
      ]);
      expect(term.native(), [1, 'two', true]);
    });

    test('native() with empty list', () {
      const ListTerm term = ListTerm([]);
      expect(term.native(), []);
    });

    test('type is ListType', () {
      const ListTerm term = ListTerm([]);
      expect(term.type, isA<ListType>());
    });

    test('substitute() substitutes inner elements', () {
      const ListTerm term = ListTerm([
        BoundVariableTerm('x'),
        NumberTerm(2),
      ]);
      const Bindings bindings = Bindings({'x': NumberTerm(99)});
      final Term result = term.substitute(bindings);
      expect(result, isA<ListTerm>());
      expect((result as ListTerm).native(), [99, 2]);
    });
  });

  group('MapTerm', () {
    test('native() returns map of native values', () {
      const MapTerm term = MapTerm({
        StringTerm('a'): NumberTerm(1),
        StringTerm('b'): NumberTerm(2),
      });
      expect(term.native(), {'a': 1, 'b': 2});
    });

    test('native() with empty map', () {
      const MapTerm term = MapTerm({});
      expect(term.native(), {});
    });

    test('type is MapType', () {
      const MapTerm term = MapTerm({});
      expect(term.type, isA<MapType>());
    });

    test('asMapWithKeys() returns map with native keys', () {
      const MapTerm term = MapTerm({
        StringTerm('x'): NumberTerm(10),
        StringTerm('y'): NumberTerm(20),
      });
      final Map<dynamic, Term> result = term.asMapWithKeys();
      expect(result.keys.toList(), ['x', 'y']);
      expect(result['x'], isA<NumberTerm>());
      expect((result['x'] as NumberTerm).value, 10);
    });

    test('substitute() substitutes keys and values', () {
      const MapTerm term = MapTerm({
        StringTerm('key'): BoundVariableTerm('x'),
      });
      const Bindings bindings = Bindings({'x': NumberTerm(42)});
      final Term result = term.substitute(bindings);
      expect(result, isA<MapTerm>());
      expect((result as MapTerm).native(), {'key': 42});
    });
  });

  group('SetTerm', () {
    test('native() returns set of native values', () {
      const SetTerm term = SetTerm({
        NumberTerm(1),
        NumberTerm(2),
        NumberTerm(3),
      });
      expect(term.native(), {1, 2, 3});
    });

    test('native() with empty set', () {
      const SetTerm term = SetTerm({});
      expect(term.native(), <dynamic>{});
    });

    test('type is SetType', () {
      const SetTerm term = SetTerm({});
      expect(term.type, isA<SetType>());
    });

    test('substitute() substitutes inner elements', () {
      const SetTerm term = SetTerm({
        BoundVariableTerm('x'),
        NumberTerm(2),
      });
      const Bindings bindings = Bindings({'x': NumberTerm(99)});
      final Term result = term.substitute(bindings);
      expect(result, isA<SetTerm>());
      expect((result as SetTerm).native(), {99, 2});
    });
  });

  group('VectorTerm', () {
    test('native() returns list of native values', () {
      const VectorTerm term = VectorTerm([NumberTerm(1), NumberTerm(2)]);
      expect(term.native(), [1, 2]);
    });

    test('type is VectorType', () {
      const VectorTerm term = VectorTerm([]);
      expect(term.type, isA<VectorType>());
    });
  });

  group('BoundVariableTerm', () {
    test('substitute() returns bound value', () {
      const BoundVariableTerm term = BoundVariableTerm('x');
      const Bindings bindings = Bindings({'x': NumberTerm(42)});
      final Term result = term.substitute(bindings);
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });

    test('substitute() with string binding', () {
      const BoundVariableTerm term = BoundVariableTerm('name');
      const Bindings bindings = Bindings({'name': StringTerm('hello')});
      final Term result = term.substitute(bindings);
      expect(result, isA<StringTerm>());
      expect((result as StringTerm).value, 'hello');
    });

    test('substitute() with missing binding throws', () {
      const BoundVariableTerm term = BoundVariableTerm('y');
      const Bindings bindings = Bindings({'x': NumberTerm(1)});
      expect(
        () => term.substitute(bindings),
        throwsA(isA<NotFoundInScopeError>()),
      );
    });

    test('type is AnyType', () {
      const BoundVariableTerm term = BoundVariableTerm('x');
      expect(term.type, isA<AnyType>());
    });

    test('toString() returns variable name', () {
      const BoundVariableTerm term = BoundVariableTerm('myVar');
      expect(term.toString(), 'myVar');
    });

    test('native() throws StateError', () {
      const BoundVariableTerm term = BoundVariableTerm('x');
      expect(() => term.native(), throwsStateError);
    });
  });

  group('FunctionReferenceTerm', () {
    test('reduce() returns the referenced function', () {
      const TestFunctionTerm function = TestFunctionTerm(
        name: 'myFunc',
        parameters: [Parameter.number('x')],
      );
      final Map<String, FunctionTerm> functions = {'myFunc': function};
      final FunctionReferenceTerm reference = FunctionReferenceTerm(
        'myFunc',
        functions,
      );

      expect(reference.reduce(), same(function));
    });

    test('type is FunctionType', () {
      const TestFunctionTerm function = TestFunctionTerm(
        name: 'f',
        parameters: [],
      );
      final Map<String, FunctionTerm> functions = {'f': function};
      final FunctionReferenceTerm reference = FunctionReferenceTerm(
        'f',
        functions,
      );

      expect(reference.type, isA<FunctionType>());
    });

    test('toString() returns function name', () {
      const TestFunctionTerm function = TestFunctionTerm(
        name: 'myFunc',
        parameters: [],
      );
      final Map<String, FunctionTerm> functions = {'myFunc': function};
      final FunctionReferenceTerm reference = FunctionReferenceTerm(
        'myFunc',
        functions,
      );

      expect(reference.toString(), 'myFunc');
    });

    test('native() returns function string representation', () {
      const TestFunctionTerm function = TestFunctionTerm(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      final Map<String, FunctionTerm> functions = {'add': function};
      final FunctionReferenceTerm reference = FunctionReferenceTerm(
        'add',
        functions,
      );

      expect(reference.native(), 'add(a: Number, b: Number)');
    });
  });

  group('FunctionTerm', () {
    test('type is FunctionType', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      expect(term.type, isA<FunctionType>());
    });

    test('toString() includes name and parameters', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      expect(term.toString(), 'add(a: Number, b: Number)');
    });

    test('parameterTypes returns list of types', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x'), Parameter.string('y')],
      );
      expect(term.parameterTypes.length, 2);
      expect(term.parameterTypes[0], isA<NumberType>());
      expect(term.parameterTypes[1], isA<StringType>());
    });

    test('native() returns string representation', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      expect(term.native(), 'f(x: Number)');
    });

    test('apply with wrong argument count throws', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      expect(
        () => term.apply([const NumberTerm(1), const NumberTerm(2)]),
        throwsA(isA<InvalidArgumentCountError>()),
      );
    });

    test('equalSignature compares names', () {
      const TestFunctionTerm f1 = TestFunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      const TestFunctionTerm f2 = TestFunctionTerm(
        name: 'f',
        parameters: [Parameter.string('y')],
      );
      const TestFunctionTerm f3 = TestFunctionTerm(
        name: 'g',
        parameters: [Parameter.number('x')],
      );
      expect(f1.equalSignature(f2), true);
      expect(f1.equalSignature(f3), false);
    });
  });

  group('TimestampTerm', () {
    test('type is TimestampType', () {
      final TimestampTerm term = TimestampTerm(DateTime(2024, 1, 1));
      expect(term.type, isA<TimestampType>());
    });

    test('native() returns DateTime', () {
      final DateTime dt = DateTime(2024, 6, 15);
      final TimestampTerm term = TimestampTerm(dt);
      expect(term.native(), dt);
    });
  });

  group('FileTerm', () {
    test('type is FileType', () {
      final FileTerm term = FileTerm(File('dummy'));
      expect(term.type, isA<FileType>());
    });
  });

  group('DirectoryTerm', () {
    test('type is DirectoryType', () {
      final DirectoryTerm term = DirectoryTerm(Directory('dummy'));
      expect(term.type, isA<DirectoryType>());
    });
  });

  group('VectorTerm', () {
    test('substitute() substitutes inner elements', () {
      const VectorTerm term = VectorTerm([
        BoundVariableTerm('x'),
        NumberTerm(2),
      ]);
      const Bindings bindings = Bindings({'x': NumberTerm(99)});
      final Term result = term.substitute(bindings);
      expect(result, isA<VectorTerm>());
      expect((result as VectorTerm).native(), [99, 2]);
    });
  });

  group('StackTerm', () {
    test('native() returns list of native values', () {
      const StackTerm term = StackTerm([NumberTerm(1), NumberTerm(2)]);
      expect(term.native(), [1, 2]);
    });

    test('type is StackType', () {
      const StackTerm term = StackTerm([]);
      expect(term.type, isA<StackType>());
    });

    test('substitute() substitutes inner elements', () {
      const StackTerm term = StackTerm([
        BoundVariableTerm('x'),
        NumberTerm(2),
      ]);
      const Bindings bindings = Bindings({'x': NumberTerm(99)});
      final Term result = term.substitute(bindings);
      expect(result, isA<StackTerm>());
      expect((result as StackTerm).native(), [99, 2]);
    });
  });

  group('QueueTerm', () {
    test('native() returns list of native values', () {
      const QueueTerm term = QueueTerm([NumberTerm(1), NumberTerm(2)]);
      expect(term.native(), [1, 2]);
    });

    test('type is QueueType', () {
      const QueueTerm term = QueueTerm([]);
      expect(term.type, isA<QueueType>());
    });

    test('substitute() substitutes inner elements', () {
      const QueueTerm term = QueueTerm([
        BoundVariableTerm('x'),
        NumberTerm(2),
      ]);
      const Bindings bindings = Bindings({'x': NumberTerm(99)});
      final Term result = term.substitute(bindings);
      expect(result, isA<QueueTerm>());
      expect((result as QueueTerm).native(), [99, 2]);
    });
  });

  group('FunctionTerm reduce', () {
    test('reduce returns itself', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      expect(term.reduce(), same(term));
    });
  });

  group('CallTerm', () {
    test('getFunctionTerm with non-function callee throws', () {
      const CallTerm call = CallTerm(
        callee: NumberTerm(42),
        arguments: [],
      );
      expect(call.reduce, throwsA(isA<InvalidFunctionError>()));
    });

    test('type is FunctionCallType', () {
      const CallTerm call = CallTerm(
        callee: NumberTerm(42),
        arguments: [],
      );
      expect(call.type, isA<FunctionCallType>());
    });

    test('toString() shows callee and arguments', () {
      const CallTerm call = CallTerm(
        callee: NumberTerm(42),
        arguments: [NumberTerm(1)],
      );
      expect(call.toString(), '42(1)');
    });

    test('toString() with multiple arguments', () {
      const CallTerm call = CallTerm(
        callee: NumberTerm(42),
        arguments: [NumberTerm(1), StringTerm('a'), BooleanTerm(true)],
      );
      expect(call.toString(), '42(1, a, true)');
    });

    test('toString() with no arguments', () {
      const CallTerm call = CallTerm(
        callee: NumberTerm(42),
        arguments: [],
      );
      expect(call.toString(), '42()');
    });

    test('substitute() substitutes callee and arguments', () {
      const CallTerm call = CallTerm(
        callee: BoundVariableTerm('f'),
        arguments: [BoundVariableTerm('x'), NumberTerm(2)],
      );
      final TestNativeFunctionTerm function = TestNativeFunctionTerm(
        name: 'testFunc',
        parameters: const [Parameter.number('a'), Parameter.number('b')],
        termFunction: (List<Term> arguments) => const NumberTerm(100),
      );
      final Bindings bindings = Bindings({
        'f': function,
        'x': const NumberTerm(99),
      });
      final Term result = call.substitute(bindings);
      expect(result, isA<CallTerm>());
      final CallTerm substituted = result as CallTerm;
      expect(substituted.callee, same(function));
      expect((substituted.arguments[0] as NumberTerm).value, 99);
      expect((substituted.arguments[1] as NumberTerm).value, 2);
    });

    test('reduce() calls function with arguments', () {
      final TestNativeFunctionTerm function = TestNativeFunctionTerm(
        name: 'identity',
        parameters: const [Parameter.number('x')],
        termFunction: (List<Term> arguments) => arguments[0],
      );
      final CallTerm call = CallTerm(
        callee: function,
        arguments: const [NumberTerm(42)],
      );
      final Term result = call.reduce();
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });

    test('native() reduces and returns native value', () {
      final TestNativeFunctionTerm function = TestNativeFunctionTerm(
        name: 'getValue',
        parameters: const [],
        termFunction: (List<Term> arguments) => const StringTerm('result'),
      );
      final CallTerm call = CallTerm(
        callee: function,
        arguments: const [],
      );
      expect(call.native(), 'result');
    });

    test('reduce() with FunctionReferenceTerm callee', () {
      final TestNativeFunctionTerm function = TestNativeFunctionTerm(
        name: 'double',
        parameters: const [Parameter.number('x')],
        termFunction: (List<Term> arguments) {
          final num value = (arguments[0] as NumberTerm).value;
          return NumberTerm(value * 2);
        },
      );
      final Map<String, FunctionTerm> functions = {'double': function};
      final FunctionReferenceTerm reference = FunctionReferenceTerm(
        'double',
        functions,
      );
      final CallTerm call = CallTerm(
        callee: reference,
        arguments: const [NumberTerm(21)],
      );
      final Term result = call.reduce();
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });
  });

  group('FunctionReferenceTerm additional', () {
    test('reduce() throws NotFoundInScopeError when function not found', () {
      final Map<String, FunctionTerm> functions = {};
      final FunctionReferenceTerm reference = FunctionReferenceTerm(
        'nonexistent',
        functions,
      );
      expect(reference.reduce, throwsA(isA<NotFoundInScopeError>()));
    });

    test('substitute() returns itself', () {
      const TestFunctionTerm function = TestFunctionTerm(
        name: 'f',
        parameters: [],
      );
      final Map<String, FunctionTerm> functions = {'f': function};
      final FunctionReferenceTerm reference = FunctionReferenceTerm(
        'f',
        functions,
      );
      const Bindings bindings = Bindings({'x': NumberTerm(1)});
      expect(reference.substitute(bindings), same(reference));
    });
  });

  group('FunctionTerm static methods', () {
    setUp(FunctionTerm.resetDepth);

    tearDown(FunctionTerm.resetDepth);

    test('resetDepth() resets the counter', () {
      FunctionTerm.incrementDepth();
      FunctionTerm.incrementDepth();
      FunctionTerm.resetDepth();
      // Should not throw since depth is reset
      expect(FunctionTerm.incrementDepth(), true);
    });

    test('incrementDepth() returns true when under limit', () {
      expect(FunctionTerm.incrementDepth(), true);
    });

    test('decrementDepth() decrements the counter', () {
      FunctionTerm.incrementDepth();
      FunctionTerm.incrementDepth();
      FunctionTerm.decrementDepth();
      FunctionTerm.decrementDepth();
      // Should not throw since we decremented
      expect(FunctionTerm.incrementDepth(), true);
    });

    test('incrementDepth() throws RecursionLimitError at max depth', () {
      for (int i = 0; i < FunctionTerm.maxRecursionDepth; i++) {
        FunctionTerm.incrementDepth();
      }
      expect(
        FunctionTerm.incrementDepth,
        throwsA(isA<RecursionLimitError>()),
      );
    });
  });

  group('FunctionTerm toSignature()', () {
    test('returns FunctionSignature with name and parameters', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      final FunctionSignature signature = term.toSignature();
      expect(signature.name, 'add');
      expect(signature.parameters.length, 2);
      expect(signature.parameters[0].name, 'a');
      expect(signature.parameters[1].name, 'b');
    });

    test('arity matches parameter count', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x'), Parameter.string('y')],
      );
      final FunctionSignature signature = term.toSignature();
      expect(signature.arity, 2);
    });

    test('empty parameters returns signature with empty list', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'noArgs',
        parameters: [],
      );
      final FunctionSignature signature = term.toSignature();
      expect(signature.parameters, isEmpty);
      expect(signature.arity, 0);
    });
  });

  group('CustomFunctionTerm', () {
    setUp(FunctionTerm.resetDepth);

    tearDown(FunctionTerm.resetDepth);

    test('type is FunctionType', () {
      const CustomFunctionTerm term = CustomFunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
        term: BoundVariableTerm('x'),
      );
      expect(term.type, isA<FunctionType>());
    });

    test('apply() with correct argument count evaluates term', () {
      const CustomFunctionTerm term = CustomFunctionTerm(
        name: 'identity',
        parameters: [Parameter.number('x')],
        term: BoundVariableTerm('x'),
      );
      final Term result = term.apply(const [NumberTerm(42)]);
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });

    test('apply() with wrong argument count throws', () {
      const CustomFunctionTerm term = CustomFunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
        term: BoundVariableTerm('x'),
      );
      expect(
        () => term.apply(const [NumberTerm(1), NumberTerm(2)]),
        throwsA(isA<InvalidArgumentCountError>()),
      );
    });

    test('apply() with fewer arguments throws', () {
      const CustomFunctionTerm term = CustomFunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x'), Parameter.number('y')],
        term: BoundVariableTerm('x'),
      );
      expect(
        () => term.apply(const [NumberTerm(1)]),
        throwsA(isA<InvalidArgumentCountError>()),
      );
    });

    test('substitute() substitutes inner term', () {
      const CustomFunctionTerm term = CustomFunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
        term: BoundVariableTerm('y'),
      );
      const Bindings bindings = Bindings({'y': NumberTerm(99)});
      final Term result = term.substitute(bindings);
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 99);
    });

    test('apply() manages recursion depth', () {
      const CustomFunctionTerm term = CustomFunctionTerm(
        name: 'f',
        parameters: [],
        term: NumberTerm(1),
      );
      // Apply multiple times and verify depth is properly managed
      term.apply(const []);
      term.apply(const []);
      term.apply(const []);
      // Should still be able to apply (depth resets after each call)
      final Term result = term.apply(const []);
      expect(result, isA<NumberTerm>());
    });

    test('apply() reduces arguments before binding (call-by-value)', () {
      final TestNativeFunctionTerm innerFunction = TestNativeFunctionTerm(
        name: 'getValue',
        parameters: const [],
        termFunction: (List<Term> arguments) => const NumberTerm(42),
      );
      final CallTerm callTerm = CallTerm(
        callee: innerFunction,
        arguments: const [],
      );
      const CustomFunctionTerm term = CustomFunctionTerm(
        name: 'wrapper',
        parameters: [Parameter.number('x')],
        term: BoundVariableTerm('x'),
      );
      final Term result = term.apply([callTerm]);
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });

    test('toString() includes name and parameters', () {
      const CustomFunctionTerm term = CustomFunctionTerm(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
        term: BoundVariableTerm('a'),
      );
      expect(term.toString(), 'add(a: Number, b: Number)');
    });

    test('native() returns string representation', () {
      const CustomFunctionTerm term = CustomFunctionTerm(
        name: 'f',
        parameters: [Parameter.string('s')],
        term: BoundVariableTerm('s'),
      );
      expect(term.native(), 'f(s: String)');
    });
  });

  group('NativeFunctionTerm', () {
    test('substitute() retrieves bindings and calls term()', () {
      final TestNativeFunctionTerm term = TestNativeFunctionTerm(
        name: 'sum',
        parameters: const [Parameter.number('a'), Parameter.number('b')],
        termFunction: (List<Term> arguments) {
          final num a = (arguments[0] as NumberTerm).value;
          final num b = (arguments[1] as NumberTerm).value;
          return NumberTerm(a + b);
        },
      );
      const Bindings bindings = Bindings({
        'a': NumberTerm(10),
        'b': NumberTerm(20),
      });
      final Term result = term.substitute(bindings);
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 30);
    });

    test('apply() works with correct arguments', () {
      final TestNativeFunctionTerm term = TestNativeFunctionTerm(
        name: 'identity',
        parameters: const [Parameter.number('x')],
        termFunction: (List<Term> arguments) => arguments[0],
      );
      final Term result = term.apply(const [NumberTerm(42)]);
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });
  });

  group('NumberTerm edge cases', () {
    test('NaN value', () {
      const NumberTerm nanTerm = NumberTerm(double.nan);
      expect(nanTerm.native().isNaN, true);
    });

    test('positive infinity', () {
      const NumberTerm infTerm = NumberTerm(double.infinity);
      expect(infTerm.native(), double.infinity);
    });

    test('negative infinity', () {
      const NumberTerm negInfTerm = NumberTerm(double.negativeInfinity);
      expect(negInfTerm.native(), double.negativeInfinity);
    });

    test('very large int', () {
      const NumberTerm largeTerm = NumberTerm(9007199254740992);
      expect(largeTerm.native(), 9007199254740992);
    });

    test('very small double', () {
      const NumberTerm smallTerm = NumberTerm(0.0000000001);
      expect(smallTerm.native(), 0.0000000001);
    });
  });

  group('FileTerm additional', () {
    test('native() returns File', () {
      final File file = File('test.txt');
      final FileTerm term = FileTerm(file);
      expect(term.native(), same(file));
    });

    test('toString() returns file path', () {
      final FileTerm term = FileTerm(File('/path/to/file.txt'));
      expect(term.toString(), contains('file.txt'));
    });

    test('substitute() returns itself', () {
      final FileTerm term = FileTerm(File('test.txt'));
      const Bindings bindings = Bindings({});
      expect(term.substitute(bindings), same(term));
    });

    test('reduce() returns itself', () {
      final FileTerm term = FileTerm(File('test.txt'));
      expect(term.reduce(), same(term));
    });

    test('value is correct', () {
      final File file = File('myfile.txt');
      final FileTerm term = FileTerm(file);
      expect(term.value, same(file));
    });
  });

  group('DirectoryTerm additional', () {
    test('native() returns Directory', () {
      final Directory directory = Directory('/test/dir');
      final DirectoryTerm term = DirectoryTerm(directory);
      expect(term.native(), same(directory));
    });

    test('toString() returns directory path', () {
      final DirectoryTerm term = DirectoryTerm(Directory('/path/to/dir'));
      expect(term.toString(), contains('dir'));
    });

    test('substitute() returns itself', () {
      final DirectoryTerm term = DirectoryTerm(Directory('test'));
      const Bindings bindings = Bindings({});
      expect(term.substitute(bindings), same(term));
    });

    test('reduce() returns itself', () {
      final DirectoryTerm term = DirectoryTerm(Directory('test'));
      expect(term.reduce(), same(term));
    });

    test('value is correct', () {
      final Directory directory = Directory('mydir');
      final DirectoryTerm term = DirectoryTerm(directory);
      expect(term.value, same(directory));
    });
  });

  group('TimestampTerm additional', () {
    test('toString() returns DateTime string', () {
      final DateTime dt = DateTime(2024, 6, 15, 12, 30, 45);
      final TimestampTerm term = TimestampTerm(dt);
      expect(term.toString(), dt.toString());
    });

    test('substitute() returns itself', () {
      final TimestampTerm term = TimestampTerm(DateTime.now());
      const Bindings bindings = Bindings({});
      expect(term.substitute(bindings), same(term));
    });

    test('reduce() returns itself', () {
      final TimestampTerm term = TimestampTerm(DateTime.now());
      expect(term.reduce(), same(term));
    });

    test('value is correct', () {
      final DateTime dt = DateTime(2024, 1, 1);
      final TimestampTerm term = TimestampTerm(dt);
      expect(term.value, dt);
    });
  });

  group('ListTerm additional', () {
    test('reduce() returns itself', () {
      const ListTerm term = ListTerm([NumberTerm(1)]);
      expect(term.reduce(), same(term));
    });

    test('toString() returns list string', () {
      const ListTerm term = ListTerm([NumberTerm(1), NumberTerm(2)]);
      expect(term.toString(), '[1, 2]');
    });

    test('nested list native()', () {
      const ListTerm inner = ListTerm([NumberTerm(1), NumberTerm(2)]);
      const ListTerm outer = ListTerm([inner, NumberTerm(3)]);
      expect(outer.native(), [
        [1, 2],
        3,
      ]);
    });

    test('value is correct', () {
      const List<Term> elements = [NumberTerm(1)];
      const ListTerm term = ListTerm(elements);
      expect(term.value, elements);
    });
  });

  group('MapTerm additional', () {
    test('reduce() returns itself', () {
      const MapTerm term = MapTerm({StringTerm('a'): NumberTerm(1)});
      expect(term.reduce(), same(term));
    });

    test('toString() returns map string', () {
      const MapTerm term = MapTerm({StringTerm('a'): NumberTerm(1)});
      expect(term.toString(), '{a: 1}');
    });

    test('substitute() substitutes both keys and values with variables', () {
      const MapTerm term = MapTerm({
        BoundVariableTerm('k'): BoundVariableTerm('v'),
      });
      const Bindings bindings = Bindings({
        'k': StringTerm('key'),
        'v': NumberTerm(100),
      });
      final Term result = term.substitute(bindings);
      expect(result, isA<MapTerm>());
      expect((result as MapTerm).native(), {'key': 100});
    });

    test('asMapWithKeys() with empty map', () {
      const MapTerm term = MapTerm({});
      final Map<dynamic, Term> result = term.asMapWithKeys();
      expect(result, isEmpty);
    });

    test('native() with nested map', () {
      const MapTerm inner = MapTerm({StringTerm('x'): NumberTerm(1)});
      const MapTerm outer = MapTerm({StringTerm('nested'): inner});
      expect(outer.native(), {
        'nested': {'x': 1},
      });
    });
  });

  group('SetTerm additional', () {
    test('reduce() returns itself', () {
      const SetTerm term = SetTerm({NumberTerm(1)});
      expect(term.reduce(), same(term));
    });

    test('toString() returns set string', () {
      const SetTerm term = SetTerm({NumberTerm(1)});
      expect(term.toString(), '{1}');
    });

    test('value is correct', () {
      const Set<Term> elements = {NumberTerm(1), NumberTerm(2)};
      const SetTerm term = SetTerm(elements);
      expect(term.value, elements);
    });
  });

  group('VectorTerm additional', () {
    test('reduce() returns itself', () {
      const VectorTerm term = VectorTerm([NumberTerm(1)]);
      expect(term.reduce(), same(term));
    });

    test('toString() returns vector string', () {
      const VectorTerm term = VectorTerm([NumberTerm(1), NumberTerm(2)]);
      expect(term.toString(), '[1, 2]');
    });

    test('empty vector', () {
      const VectorTerm term = VectorTerm([]);
      expect(term.native(), []);
      expect(term.toString(), '[]');
    });

    test('value is correct', () {
      const List<Term> elements = [NumberTerm(1)];
      const VectorTerm term = VectorTerm(elements);
      expect(term.value, elements);
    });
  });

  group('StackTerm additional', () {
    test('reduce() returns itself', () {
      const StackTerm term = StackTerm([NumberTerm(1)]);
      expect(term.reduce(), same(term));
    });

    test('toString() returns stack string', () {
      const StackTerm term = StackTerm([NumberTerm(1), NumberTerm(2)]);
      expect(term.toString(), '[1, 2]');
    });

    test('empty stack', () {
      const StackTerm term = StackTerm([]);
      expect(term.native(), []);
    });

    test('value is correct', () {
      const List<Term> elements = [NumberTerm(1)];
      const StackTerm term = StackTerm(elements);
      expect(term.value, elements);
    });
  });

  group('QueueTerm additional', () {
    test('reduce() returns itself', () {
      const QueueTerm term = QueueTerm([NumberTerm(1)]);
      expect(term.reduce(), same(term));
    });

    test('toString() returns queue string', () {
      const QueueTerm term = QueueTerm([NumberTerm(1), NumberTerm(2)]);
      expect(term.toString(), '[1, 2]');
    });

    test('empty queue', () {
      const QueueTerm term = QueueTerm([]);
      expect(term.native(), []);
    });

    test('value is correct', () {
      const List<Term> elements = [NumberTerm(1)];
      const QueueTerm term = QueueTerm(elements);
      expect(term.value, elements);
    });
  });

  group('BoundVariableTerm additional', () {
    test('reduce() returns itself', () {
      const BoundVariableTerm term = BoundVariableTerm('x');
      expect(term.reduce(), same(term));
    });

    test('substitute() with empty bindings throws', () {
      const BoundVariableTerm term = BoundVariableTerm('x');
      const Bindings bindings = Bindings({});
      expect(
        () => term.substitute(bindings),
        throwsA(isA<NotFoundInScopeError>()),
      );
    });
  });

  group('FunctionTerm apply with empty parameters', () {
    test('apply() with empty parameters and empty arguments succeeds', () {
      final TestNativeFunctionTerm term = TestNativeFunctionTerm(
        name: 'noArgs',
        parameters: const [],
        termFunction: (List<Term> arguments) => const NumberTerm(42),
      );
      final Term result = term.apply(const []);
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });

    test('apply() with empty parameters but with arguments throws', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'noArgs',
        parameters: [],
      );
      expect(
        () => term.apply(const [NumberTerm(1)]),
        throwsA(isA<InvalidArgumentCountError>()),
      );
    });
  });

  group('StringTerm additional', () {
    test('string with special characters', () {
      const StringTerm term = StringTerm('hello\nworld\ttab');
      expect(term.native(), 'hello\nworld\ttab');
    });

    test('string with unicode', () {
      const StringTerm term = StringTerm('\u{1F600}');
      expect(term.native(), '\u{1F600}');
    });

    test('very long string', () {
      final String longString = 'a' * 10000;
      final StringTerm term = StringTerm(longString);
      expect(term.native().length, 10000);
    });
  });
}
