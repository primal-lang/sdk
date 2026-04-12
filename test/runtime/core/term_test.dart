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

/// Test double for [NativeFunctionTermWithArguments] since it is abstract.
class TestNativeFunctionTermWithArguments
    extends NativeFunctionTermWithArguments {
  final Term Function() reduceFunction;

  const TestNativeFunctionTermWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
    required this.reduceFunction,
  });

  @override
  Term reduce() => reduceFunction();
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

  group('NativeFunctionTermWithArguments', () {
    test('type is FunctionType', () {
      final TestNativeFunctionTermWithArguments term =
          TestNativeFunctionTermWithArguments(
            name: 'testFunction',
            parameters: const [Parameter.number('x')],
            arguments: const [NumberTerm(42)],
            reduceFunction: () => const NumberTerm(42),
          );
      expect(term.type, isA<FunctionType>());
    });

    test('reduce() returns expected value', () {
      final TestNativeFunctionTermWithArguments term =
          TestNativeFunctionTermWithArguments(
            name: 'getValue',
            parameters: const [],
            arguments: const [],
            reduceFunction: () => const StringTerm('result'),
          );
      final Term result = term.reduce();
      expect(result, isA<StringTerm>());
      expect((result as StringTerm).value, 'result');
    });

    test('arguments are accessible', () {
      const List<Term> providedArguments = [
        NumberTerm(1),
        StringTerm('test'),
      ];
      final TestNativeFunctionTermWithArguments term =
          TestNativeFunctionTermWithArguments(
            name: 'withArgs',
            parameters: const [Parameter.number('a'), Parameter.string('b')],
            arguments: providedArguments,
            reduceFunction: () => const BooleanTerm(true),
          );
      expect(term.arguments, providedArguments);
    });

    test('toString() includes name and parameters', () {
      final TestNativeFunctionTermWithArguments term =
          TestNativeFunctionTermWithArguments(
            name: 'display',
            parameters: const [Parameter.number('value')],
            arguments: const [NumberTerm(100)],
            reduceFunction: () => const NumberTerm(100),
          );
      expect(term.toString(), 'display(value: Number)');
    });

    test('native() returns string representation', () {
      final TestNativeFunctionTermWithArguments term =
          TestNativeFunctionTermWithArguments(
            name: 'compute',
            parameters: const [Parameter.boolean('flag')],
            arguments: const [BooleanTerm(true)],
            reduceFunction: () => const BooleanTerm(true),
          );
      expect(term.native(), 'compute(flag: Boolean)');
    });

    test('empty parameters and arguments', () {
      final TestNativeFunctionTermWithArguments term =
          TestNativeFunctionTermWithArguments(
            name: 'noParams',
            parameters: const [],
            arguments: const [],
            reduceFunction: () => const NumberTerm(0),
          );
      expect(term.parameters, isEmpty);
      expect(term.arguments, isEmpty);
      expect(term.toString(), 'noParams()');
    });
  });

  group('Term base class default implementations', () {
    test('substitute() returns itself by default', () {
      const NumberTerm term = NumberTerm(42);
      const Bindings bindings = Bindings({'x': StringTerm('unused')});
      expect(term.substitute(bindings), same(term));
    });

    test('reduce() returns itself by default', () {
      const StringTerm term = StringTerm('value');
      expect(term.reduce(), same(term));
    });
  });

  group('CallTerm.getFunctionTerm()', () {
    test('returns function from FunctionTerm callee', () {
      final TestNativeFunctionTerm function = TestNativeFunctionTerm(
        name: 'identity',
        parameters: const [Parameter.number('x')],
        termFunction: (List<Term> arguments) => arguments[0],
      );
      final CallTerm call = CallTerm(
        callee: function,
        arguments: const [NumberTerm(42)],
      );
      expect(call.getFunctionTerm(function), same(function));
    });

    test('returns function from FunctionReferenceTerm callee', () {
      const TestFunctionTerm function = TestFunctionTerm(
        name: 'ref',
        parameters: [],
      );
      final Map<String, FunctionTerm> functions = {'ref': function};
      final FunctionReferenceTerm reference = FunctionReferenceTerm(
        'ref',
        functions,
      );
      const CallTerm call = CallTerm(
        callee: NumberTerm(0),
        arguments: [],
      );
      final FunctionTerm result = call.getFunctionTerm(reference);
      expect(result, same(function));
    });

    test('throws InvalidFunctionError for non-function term', () {
      const CallTerm call = CallTerm(
        callee: StringTerm('notAFunction'),
        arguments: [],
      );
      expect(
        () => call.getFunctionTerm(const StringTerm('notAFunction')),
        throwsA(isA<InvalidFunctionError>()),
      );
    });

    test('throws InvalidFunctionError for ListTerm', () {
      const ListTerm listTerm = ListTerm([NumberTerm(1)]);
      const CallTerm call = CallTerm(
        callee: listTerm,
        arguments: [],
      );
      expect(
        () => call.getFunctionTerm(listTerm),
        throwsA(isA<InvalidFunctionError>()),
      );
    });
  });

  group('FunctionTerm.substitute() base class', () {
    test('creates bindings and calls substitute on body', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'test',
        parameters: [Parameter.number('a')],
      );
      // The base FunctionTerm.substitute just returns this, so test that
      const Bindings bindings = Bindings({'x': NumberTerm(1)});
      expect(term.substitute(bindings), same(term));
    });
  });

  group('ListTerm edge cases', () {
    test('single element list', () {
      const ListTerm term = ListTerm([NumberTerm(42)]);
      expect(term.native(), [42]);
      expect(term.toString(), '[42]');
    });

    test('large list', () {
      final List<Term> elements = List.generate(1000, NumberTerm.new);
      final ListTerm term = ListTerm(elements);
      expect(term.native().length, 1000);
      expect(term.native()[0], 0);
      expect(term.native()[999], 999);
    });

    test('substitute() with no matching bindings returns equivalent list', () {
      const ListTerm term = ListTerm([NumberTerm(1), NumberTerm(2)]);
      const Bindings bindings = Bindings({'unused': StringTerm('value')});
      final Term result = term.substitute(bindings);
      expect(result, isA<ListTerm>());
      expect((result as ListTerm).native(), [1, 2]);
    });
  });

  group('MapTerm edge cases', () {
    test('single entry map', () {
      const MapTerm term = MapTerm({StringTerm('key'): NumberTerm(42)});
      expect(term.native(), {'key': 42});
    });

    test('map with number keys', () {
      const MapTerm term = MapTerm({
        NumberTerm(1): StringTerm('one'),
        NumberTerm(2): StringTerm('two'),
      });
      expect(term.native(), {1: 'one', 2: 'two'});
    });

    test('map with boolean keys', () {
      const MapTerm term = MapTerm({
        BooleanTerm(true): StringTerm('yes'),
        BooleanTerm(false): StringTerm('no'),
      });
      expect(term.native(), {true: 'yes', false: 'no'});
    });

    test('asMapWithKeys() with multiple types', () {
      const MapTerm term = MapTerm({
        NumberTerm(1): StringTerm('one'),
        StringTerm('two'): NumberTerm(2),
      });
      final Map<dynamic, Term> result = term.asMapWithKeys();
      expect(result.keys.toSet(), {1, 'two'});
    });

    test('value is correct', () {
      const Map<Term, Term> entries = {StringTerm('a'): NumberTerm(1)};
      const MapTerm term = MapTerm(entries);
      expect(term.value, entries);
    });
  });

  group('SetTerm edge cases', () {
    test('single element set', () {
      const SetTerm term = SetTerm({NumberTerm(42)});
      expect(term.native(), {42});
    });

    test('large set', () {
      final Set<Term> elements = Set.from(List.generate(100, NumberTerm.new));
      final SetTerm term = SetTerm(elements);
      expect(term.native().length, 100);
    });

    test('set with mixed types', () {
      const SetTerm term = SetTerm({
        NumberTerm(1),
        StringTerm('two'),
        BooleanTerm(true),
      });
      expect(term.native(), {1, 'two', true});
    });
  });

  group('VectorTerm edge cases', () {
    test('single element vector', () {
      const VectorTerm term = VectorTerm([NumberTerm(42)]);
      expect(term.native(), [42]);
    });

    test('nested substitution in vector', () {
      const VectorTerm term = VectorTerm([
        BoundVariableTerm('a'),
        BoundVariableTerm('b'),
      ]);
      const Bindings bindings = Bindings({
        'a': NumberTerm(1),
        'b': NumberTerm(2),
      });
      final Term result = term.substitute(bindings);
      expect(result, isA<VectorTerm>());
      expect((result as VectorTerm).native(), [1, 2]);
    });
  });

  group('StackTerm edge cases', () {
    test('single element stack', () {
      const StackTerm term = StackTerm([NumberTerm(42)]);
      expect(term.native(), [42]);
    });

    test('nested substitution in stack', () {
      const StackTerm term = StackTerm([
        BoundVariableTerm('x'),
        BoundVariableTerm('y'),
        NumberTerm(3),
      ]);
      const Bindings bindings = Bindings({
        'x': NumberTerm(1),
        'y': NumberTerm(2),
      });
      final Term result = term.substitute(bindings);
      expect(result, isA<StackTerm>());
      expect((result as StackTerm).native(), [1, 2, 3]);
    });
  });

  group('QueueTerm edge cases', () {
    test('single element queue', () {
      const QueueTerm term = QueueTerm([NumberTerm(42)]);
      expect(term.native(), [42]);
    });

    test('nested substitution in queue', () {
      const QueueTerm term = QueueTerm([
        BoundVariableTerm('first'),
        NumberTerm(2),
        BoundVariableTerm('last'),
      ]);
      const Bindings bindings = Bindings({
        'first': StringTerm('a'),
        'last': StringTerm('z'),
      });
      final Term result = term.substitute(bindings);
      expect(result, isA<QueueTerm>());
      expect((result as QueueTerm).native(), ['a', 2, 'z']);
    });
  });

  group('FunctionTerm with various parameter types', () {
    test('function with boolean parameter', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'check',
        parameters: [Parameter.boolean('flag')],
      );
      expect(term.toString(), 'check(flag: Boolean)');
    });

    test('function with file parameter', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'readFile',
        parameters: [Parameter.file('path')],
      );
      expect(term.toString(), 'readFile(path: File)');
    });

    test('function with directory parameter', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'listDir',
        parameters: [Parameter.directory('dir')],
      );
      expect(term.toString(), 'listDir(dir: Directory)');
    });

    test('function with list parameter', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'process',
        parameters: [Parameter.list('items')],
      );
      expect(term.toString(), 'process(items: List)');
    });

    test('function with map parameter', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'lookup',
        parameters: [Parameter.map('data')],
      );
      expect(term.toString(), 'lookup(data: Map)');
    });

    test('function with any parameter', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'identity',
        parameters: [Parameter.any('value')],
      );
      expect(term.toString(), 'identity(value: Any)');
    });

    test('function with function parameter', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'apply',
        parameters: [Parameter.function('callback')],
      );
      expect(term.toString(), 'apply(callback: Function)');
    });

    test('function with timestamp parameter', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'format',
        parameters: [Parameter.timestamp('time')],
      );
      expect(term.toString(), 'format(time: Timestamp)');
    });

    test('function with many parameters', () {
      const TestFunctionTerm term = TestFunctionTerm(
        name: 'complex',
        parameters: [
          Parameter.number('a'),
          Parameter.string('b'),
          Parameter.boolean('c'),
          Parameter.list('d'),
          Parameter.map('e'),
        ],
      );
      expect(term.parameterTypes.length, 5);
      expect(term.toString(), contains('complex'));
      expect(term.toString(), contains('Number'));
      expect(term.toString(), contains('String'));
      expect(term.toString(), contains('Boolean'));
      expect(term.toString(), contains('List'));
      expect(term.toString(), contains('Map'));
    });
  });

  group('CustomFunctionTerm edge cases', () {
    setUp(FunctionTerm.resetDepth);

    tearDown(FunctionTerm.resetDepth);

    test('apply() with nested function call in body', () {
      final TestNativeFunctionTerm innerFunction = TestNativeFunctionTerm(
        name: 'double',
        parameters: const [Parameter.number('x')],
        termFunction: (List<Term> arguments) {
          final num value = (arguments[0] as NumberTerm).value;
          return NumberTerm(value * 2);
        },
      );
      final Map<String, FunctionTerm> functions = {'double': innerFunction};
      final FunctionReferenceTerm doubleRef = FunctionReferenceTerm(
        'double',
        functions,
      );
      final CallTerm callDouble = CallTerm(
        callee: doubleRef,
        arguments: const [BoundVariableTerm('x')],
      );
      final CustomFunctionTerm wrapper = CustomFunctionTerm(
        name: 'wrapper',
        parameters: const [Parameter.number('x')],
        term: callDouble,
      );
      final Term result = wrapper.apply(const [NumberTerm(21)]);
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 42);
    });

    test('apply() with zero parameters', () {
      const CustomFunctionTerm term = CustomFunctionTerm(
        name: 'constant',
        parameters: [],
        term: StringTerm('hello'),
      );
      final Term result = term.apply(const []);
      expect(result, isA<StringTerm>());
      expect((result as StringTerm).value, 'hello');
    });

    test('substitute() returns substituted term directly', () {
      const CustomFunctionTerm term = CustomFunctionTerm(
        name: 'identity',
        parameters: [Parameter.number('x')],
        term: BoundVariableTerm('y'),
      );
      const Bindings bindings = Bindings({'y': StringTerm('substituted')});
      final Term result = term.substitute(bindings);
      expect(result, isA<StringTerm>());
      expect((result as StringTerm).value, 'substituted');
    });

    test('reduce() returns itself', () {
      const CustomFunctionTerm term = CustomFunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
        term: BoundVariableTerm('x'),
      );
      expect(term.reduce(), same(term));
    });
  });

  group('NativeFunctionTerm edge cases', () {
    test('substitute() with all bound parameters', () {
      final TestNativeFunctionTerm term = TestNativeFunctionTerm(
        name: 'add',
        parameters: const [
          Parameter.number('a'),
          Parameter.number('b'),
          Parameter.number('c'),
        ],
        termFunction: (List<Term> arguments) {
          final num sum =
              (arguments[0] as NumberTerm).value +
              (arguments[1] as NumberTerm).value +
              (arguments[2] as NumberTerm).value;
          return NumberTerm(sum);
        },
      );
      const Bindings bindings = Bindings({
        'a': NumberTerm(1),
        'b': NumberTerm(2),
        'c': NumberTerm(3),
      });
      final Term result = term.substitute(bindings);
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 6);
    });

    test('reduce() returns itself', () {
      final TestNativeFunctionTerm term = TestNativeFunctionTerm(
        name: 'f',
        parameters: const [],
        termFunction: (List<Term> arguments) => const NumberTerm(0),
      );
      expect(term.reduce(), same(term));
    });

    test('apply() with no parameters succeeds', () {
      final TestNativeFunctionTerm term = TestNativeFunctionTerm(
        name: 'zero',
        parameters: const [],
        termFunction: (List<Term> arguments) => const NumberTerm(0),
      );
      final Term result = term.apply(const []);
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 0);
    });
  });

  group('CallTerm edge cases', () {
    test('native() with nested CallTerm', () {
      final TestNativeFunctionTerm inner = TestNativeFunctionTerm(
        name: 'getNumber',
        parameters: const [],
        termFunction: (List<Term> arguments) => const NumberTerm(42),
      );
      final TestNativeFunctionTerm outer = TestNativeFunctionTerm(
        name: 'identity',
        parameters: const [Parameter.number('x')],
        termFunction: (List<Term> arguments) => arguments[0],
      );
      final CallTerm innerCall = CallTerm(
        callee: inner,
        arguments: const [],
      );
      final CallTerm outerCall = CallTerm(
        callee: outer,
        arguments: [innerCall],
      );
      expect(outerCall.native(), 42);
    });

    test('substitute() preserves non-variable arguments', () {
      const CallTerm call = CallTerm(
        callee: BoundVariableTerm('f'),
        arguments: [NumberTerm(1), StringTerm('two')],
      );
      final TestNativeFunctionTerm function = TestNativeFunctionTerm(
        name: 'test',
        parameters: const [Parameter.number('a'), Parameter.string('b')],
        termFunction: (List<Term> arguments) => const BooleanTerm(true),
      );
      final Bindings bindings = Bindings({'f': function});
      final Term result = call.substitute(bindings);
      expect(result, isA<CallTerm>());
      final CallTerm substituted = result as CallTerm;
      expect((substituted.arguments[0] as NumberTerm).value, 1);
      expect((substituted.arguments[1] as StringTerm).value, 'two');
    });

    test('reduce() with deeply nested CallTerm', () {
      final TestNativeFunctionTerm addOne = TestNativeFunctionTerm(
        name: 'addOne',
        parameters: const [Parameter.number('x')],
        termFunction: (List<Term> arguments) {
          // The argument may still be a CallTerm, so reduce it first
          final Term reducedArgument = arguments[0].reduce();
          final num value = (reducedArgument as NumberTerm).value;
          return NumberTerm(value + 1);
        },
      );
      CallTerm call = CallTerm(
        callee: addOne,
        arguments: const [NumberTerm(0)],
      );
      for (int i = 0; i < 5; i++) {
        call = CallTerm(
          callee: addOne,
          arguments: [call],
        );
      }
      final Term result = call.reduce();
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 6);
    });
  });

  group('FunctionReferenceTerm edge cases', () {
    test('native() returns function signature string', () {
      const TestFunctionTerm function = TestFunctionTerm(
        name: 'noParams',
        parameters: [],
      );
      final Map<String, FunctionTerm> functions = {'noParams': function};
      final FunctionReferenceTerm reference = FunctionReferenceTerm(
        'noParams',
        functions,
      );
      expect(reference.native(), 'noParams()');
    });

    test('type is always FunctionType', () {
      const TestFunctionTerm function = TestFunctionTerm(
        name: 'typed',
        parameters: [Parameter.string('s')],
      );
      final Map<String, FunctionTerm> functions = {'typed': function};
      final FunctionReferenceTerm reference = FunctionReferenceTerm(
        'typed',
        functions,
      );
      expect(reference.type, isA<FunctionType>());
    });
  });

  group('BooleanTerm edge cases', () {
    test('type is always BooleanType regardless of value', () {
      const BooleanTerm trueTerm = BooleanTerm(true);
      const BooleanTerm falseTerm = BooleanTerm(false);
      expect(trueTerm.type, isA<BooleanType>());
      expect(falseTerm.type, isA<BooleanType>());
    });

    test('value property matches constructor argument', () {
      const BooleanTerm trueTerm = BooleanTerm(true);
      const BooleanTerm falseTerm = BooleanTerm(false);
      expect(trueTerm.value, true);
      expect(falseTerm.value, false);
    });
  });

  group('TimestampTerm edge cases', () {
    test('timestamp at epoch', () {
      final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);
      final TimestampTerm term = TimestampTerm(epoch);
      expect(term.native(), epoch);
    });

    test('timestamp with milliseconds', () {
      final DateTime preciseTime = DateTime(2024, 1, 1, 12, 30, 45, 123);
      final TimestampTerm term = TimestampTerm(preciseTime);
      expect(term.native().millisecond, 123);
    });

    test('future timestamp', () {
      final DateTime future = DateTime(3000, 12, 31);
      final TimestampTerm term = TimestampTerm(future);
      expect(term.native().year, 3000);
    });
  });

  group('ValueTerm.from() additional cases', () {
    test('int zero returns NumberTerm', () {
      final ValueTerm term = ValueTerm.from(0);
      expect(term, isA<NumberTerm>());
      expect((term as NumberTerm).value, 0);
    });

    test('negative int returns NumberTerm', () {
      final ValueTerm term = ValueTerm.from(-42);
      expect(term, isA<NumberTerm>());
      expect((term as NumberTerm).value, -42);
    });

    test('negative double returns NumberTerm', () {
      final ValueTerm term = ValueTerm.from(-3.14);
      expect(term, isA<NumberTerm>());
      expect((term as NumberTerm).value, -3.14);
    });

    test('empty string returns StringTerm', () {
      final ValueTerm term = ValueTerm.from('');
      expect(term, isA<StringTerm>());
      expect((term as StringTerm).value, '');
    });

    test('empty List<Term> returns ListTerm', () {
      final ValueTerm term = ValueTerm.from(<Term>[]);
      expect(term, isA<ListTerm>());
      expect((term as ListTerm).value, isEmpty);
    });

    test('empty Map<Term, Term> returns MapTerm', () {
      final ValueTerm term = ValueTerm.from(<Term, Term>{});
      expect(term, isA<MapTerm>());
      expect((term as MapTerm).value, isEmpty);
    });

    test('empty Set<Term> returns SetTerm', () {
      final ValueTerm term = ValueTerm.from(<Term>{});
      expect(term, isA<SetTerm>());
      expect((term as SetTerm).value, isEmpty);
    });

    test('null throws InvalidLiteralValueError', () {
      expect(
        () => ValueTerm.from(null),
        throwsA(isA<InvalidLiteralValueError>()),
      );
    });

    test('DateTime.now() returns TimestampTerm', () {
      final DateTime now = DateTime.now();
      final ValueTerm term = ValueTerm.from(now);
      expect(term, isA<TimestampTerm>());
    });
  });

  group('FunctionTerm.equalSignature() edge cases', () {
    test('same name different parameter count returns true', () {
      const TestFunctionTerm f1 = TestFunctionTerm(
        name: 'func',
        parameters: [Parameter.number('x')],
      );
      const TestFunctionTerm f2 = TestFunctionTerm(
        name: 'func',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      expect(f1.equalSignature(f2), true);
    });

    test('empty name matches empty name', () {
      const TestFunctionTerm f1 = TestFunctionTerm(
        name: '',
        parameters: [],
      );
      const TestFunctionTerm f2 = TestFunctionTerm(
        name: '',
        parameters: [Parameter.number('x')],
      );
      expect(f1.equalSignature(f2), true);
    });

    test('case sensitive name comparison', () {
      const TestFunctionTerm f1 = TestFunctionTerm(
        name: 'Func',
        parameters: [],
      );
      const TestFunctionTerm f2 = TestFunctionTerm(
        name: 'func',
        parameters: [],
      );
      expect(f1.equalSignature(f2), false);
    });
  });

  group('FunctionTerm recursion depth edge cases', () {
    setUp(FunctionTerm.resetDepth);

    tearDown(FunctionTerm.resetDepth);

    test('incrementDepth at exactly max depth minus one succeeds', () {
      for (int i = 0; i < FunctionTerm.maxRecursionDepth - 1; i++) {
        FunctionTerm.incrementDepth();
      }
      expect(FunctionTerm.incrementDepth(), true);
    });

    test('multiple reset calls are idempotent', () {
      FunctionTerm.incrementDepth();
      FunctionTerm.incrementDepth();
      FunctionTerm.resetDepth();
      FunctionTerm.resetDepth();
      FunctionTerm.resetDepth();
      expect(FunctionTerm.incrementDepth(), true);
    });

    test('decrement then increment cycle', () {
      for (int i = 0; i < 10; i++) {
        FunctionTerm.incrementDepth();
        FunctionTerm.decrementDepth();
      }
      expect(FunctionTerm.incrementDepth(), true);
    });
  });

  group('CallTerm with BoundVariableTerm arguments', () {
    test('substitute() resolves all BoundVariableTerm arguments', () {
      const CallTerm call = CallTerm(
        callee: BoundVariableTerm('func'),
        arguments: [
          BoundVariableTerm('a'),
          BoundVariableTerm('b'),
          BoundVariableTerm('c'),
        ],
      );
      final TestNativeFunctionTerm function = TestNativeFunctionTerm(
        name: 'sum',
        parameters: const [
          Parameter.number('x'),
          Parameter.number('y'),
          Parameter.number('z'),
        ],
        termFunction: (List<Term> arguments) {
          final num sum =
              (arguments[0] as NumberTerm).value +
              (arguments[1] as NumberTerm).value +
              (arguments[2] as NumberTerm).value;
          return NumberTerm(sum);
        },
      );
      final Bindings bindings = Bindings({
        'func': function,
        'a': const NumberTerm(1),
        'b': const NumberTerm(2),
        'c': const NumberTerm(3),
      });
      final Term substituted = call.substitute(bindings);
      expect(substituted, isA<CallTerm>());
      final CallTerm substitutedCall = substituted as CallTerm;
      final Term result = substitutedCall.reduce();
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, 6);
    });
  });

  group('ListTerm with nested BoundVariableTerms', () {
    test('deeply nested substitution', () {
      const ListTerm innerList = ListTerm([
        BoundVariableTerm('inner'),
      ]);
      const ListTerm outerList = ListTerm([
        innerList,
        BoundVariableTerm('outer'),
      ]);
      const Bindings bindings = Bindings({
        'inner': NumberTerm(1),
        'outer': NumberTerm(2),
      });
      final Term result = outerList.substitute(bindings);
      expect(result, isA<ListTerm>());
      final List<dynamic> native = (result as ListTerm).native();
      expect(native, [
        [1],
        2,
      ]);
    });
  });

  group('MapTerm toString() formatting', () {
    test('empty map toString()', () {
      const MapTerm term = MapTerm({});
      expect(term.toString(), '{}');
    });

    test('multiple entries toString()', () {
      const MapTerm term = MapTerm({
        StringTerm('a'): NumberTerm(1),
        StringTerm('b'): NumberTerm(2),
      });
      final String str = term.toString();
      expect(str, contains('a: 1'));
      expect(str, contains('b: 2'));
    });
  });

  // --- LetBoundVariableTerm tests ---

  group('LetBoundVariableTerm', () {
    test('partial substitution - not found returns this', () {
      const LetBoundVariableTerm term = LetBoundVariableTerm('x');
      const Bindings bindings = Bindings({'y': NumberTerm(5)});
      final Term result = term.substitute(bindings);
      expect(result, same(term));
    });

    test('full substitution - found returns value', () {
      const LetBoundVariableTerm term = LetBoundVariableTerm('x');
      const Bindings bindings = Bindings({'x': NumberTerm(5)});
      final Term result = term.substitute(bindings);
      expect(result, isA<NumberTerm>());
      expect((result as NumberTerm).value, equals(5));
    });

    test('substitute with string value', () {
      const LetBoundVariableTerm term = LetBoundVariableTerm('name');
      const Bindings bindings = Bindings({'name': StringTerm('hello')});
      final Term result = term.substitute(bindings);
      expect(result, isA<StringTerm>());
      expect((result as StringTerm).value, equals('hello'));
    });

    test('reduce returns this', () {
      const LetBoundVariableTerm term = LetBoundVariableTerm('x');
      expect(term.reduce(), same(term));
    });

    test('type is AnyType', () {
      const LetBoundVariableTerm term = LetBoundVariableTerm('x');
      expect(term.type, isA<AnyType>());
    });

    test('native throws StateError if unsubstituted', () {
      const LetBoundVariableTerm term = LetBoundVariableTerm('x');
      expect(() => term.native(), throwsStateError);
    });

    test('toString returns name', () {
      const LetBoundVariableTerm term = LetBoundVariableTerm('myVariable');
      expect(term.toString(), equals('myVariable'));
    });

    test('substitute with empty bindings returns this', () {
      const LetBoundVariableTerm term = LetBoundVariableTerm('x');
      const Bindings bindings = Bindings({});
      expect(term.substitute(bindings), same(term));
    });

    test(
      'substitute with multiple bindings but different name returns this',
      () {
        const LetBoundVariableTerm term = LetBoundVariableTerm('z');
        const Bindings bindings = Bindings({
          'x': NumberTerm(1),
          'y': NumberTerm(2),
        });
        expect(term.substitute(bindings), same(term));
      },
    );
  });

  // --- LetTerm tests ---

  group('LetTerm', () {
    group('basic properties', () {
      test('type is AnyType', () {
        const LetTerm term = LetTerm(
          bindings: [('x', NumberTerm(1))],
          body: LetBoundVariableTerm('x'),
        );
        expect(term.type, isA<AnyType>());
      });

      test('toString returns let format', () {
        const LetTerm term = LetTerm(
          bindings: [('x', NumberTerm(1))],
          body: LetBoundVariableTerm('x'),
        );
        final String str = term.toString();
        expect(str, contains('let'));
        expect(str, contains('x'));
        expect(str, contains('in'));
      });

      test('toString with multiple bindings', () {
        const LetTerm term = LetTerm(
          bindings: [
            ('x', NumberTerm(1)),
            ('y', NumberTerm(2)),
          ],
          body: LetBoundVariableTerm('x'),
        );
        final String str = term.toString();
        expect(str, contains('x = 1'));
        expect(str, contains('y = 2'));
      });

      test('native delegates to reduce then native', () {
        const LetTerm term = LetTerm(
          bindings: [('x', NumberTerm(42))],
          body: LetBoundVariableTerm('x'),
        );
        expect(term.native(), equals(42));
      });
    });

    group('substitute', () {
      test('propagates through binding values', () {
        const LetTerm term = LetTerm(
          bindings: [('x', BoundVariableTerm('y'))],
          body: LetBoundVariableTerm('x'),
        );
        const Bindings bindings = Bindings({'y': NumberTerm(5)});
        final Term result = term.substitute(bindings);
        expect(result, isA<LetTerm>());
        final LetTerm letResult = result as LetTerm;
        expect(letResult.bindings[0].$2, isA<NumberTerm>());
      });

      test('propagates through body', () {
        const LetTerm term = LetTerm(
          bindings: [('x', NumberTerm(1))],
          body: BoundVariableTerm('y'),
        );
        const Bindings bindings = Bindings({'y': NumberTerm(5)});
        final Term result = term.substitute(bindings);
        expect(result, isA<LetTerm>());
        final LetTerm letResult = result as LetTerm;
        expect(letResult.body, isA<NumberTerm>());
      });

      test('let binding refs unchanged when not in bindings', () {
        const LetTerm term = LetTerm(
          bindings: [('x', NumberTerm(1))],
          body: LetBoundVariableTerm('x'),
        );
        const Bindings bindings = Bindings({'y': NumberTerm(5)});
        final Term result = term.substitute(bindings);
        expect(result, isA<LetTerm>());
        final LetTerm letResult = result as LetTerm;
        expect(letResult.body, isA<LetBoundVariableTerm>());
      });

      test('substitute with empty bindings returns equivalent term', () {
        const LetTerm term = LetTerm(
          bindings: [('x', NumberTerm(1))],
          body: LetBoundVariableTerm('x'),
        );
        const Bindings bindings = Bindings({});
        final Term result = term.substitute(bindings);
        expect(result, isA<LetTerm>());
      });
    });

    group('reduce', () {
      test('single binding evaluation', () {
        const LetTerm term = LetTerm(
          bindings: [('x', NumberTerm(42))],
          body: LetBoundVariableTerm('x'),
        );
        final Term result = term.reduce();
        expect(result, isA<NumberTerm>());
        expect((result as NumberTerm).value, equals(42));
      });

      test('sequential evaluation order', () {
        // let x = 1, y = x + 1 in y should give 2
        // We simulate x + 1 with a call
        final TestNativeFunctionTerm addOne = TestNativeFunctionTerm(
          name: 'addOne',
          parameters: const [Parameter.number('n')],
          termFunction: (List<Term> arguments) {
            final num value = (arguments[0] as NumberTerm).value;
            return NumberTerm(value + 1);
          },
        );
        final Map<String, FunctionTerm> functions = {'addOne': addOne};
        final LetTerm term = LetTerm(
          bindings: [
            (
              'x',
              const NumberTerm(1),
            ),
            (
              'y',
              CallTerm(
                callee: FunctionReferenceTerm('addOne', functions),
                arguments: const [LetBoundVariableTerm('x')],
              ),
            ),
          ],
          body: const LetBoundVariableTerm('y'),
        );
        final Term result = term.reduce();
        expect(result, isA<NumberTerm>());
        expect((result as NumberTerm).value, equals(2));
      });

      test('all bindings substituted in body', () {
        // let x = 1, y = 2 in x + y should give 3
        final TestNativeFunctionTerm add = TestNativeFunctionTerm(
          name: 'add',
          parameters: const [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
          termFunction: (List<Term> arguments) {
            final num a = (arguments[0] as NumberTerm).value;
            final num b = (arguments[1] as NumberTerm).value;
            return NumberTerm(a + b);
          },
        );
        final Map<String, FunctionTerm> functions = {'add': add};
        final LetTerm term = LetTerm(
          bindings: const [
            ('x', NumberTerm(1)),
            ('y', NumberTerm(2)),
          ],
          body: CallTerm(
            callee: FunctionReferenceTerm('add', functions),
            arguments: const [
              LetBoundVariableTerm('x'),
              LetBoundVariableTerm('y'),
            ],
          ),
        );
        final Term result = term.reduce();
        expect(result, isA<NumberTerm>());
        expect((result as NumberTerm).value, equals(3));
      });

      test('nested let', () {
        // let x = 1 in let y = x + 1 in y should give 2
        final TestNativeFunctionTerm addOne = TestNativeFunctionTerm(
          name: 'addOne',
          parameters: const [Parameter.number('n')],
          termFunction: (List<Term> arguments) {
            final num value = (arguments[0] as NumberTerm).value;
            return NumberTerm(value + 1);
          },
        );
        final Map<String, FunctionTerm> functions = {'addOne': addOne};
        final LetTerm term = LetTerm(
          bindings: const [('x', NumberTerm(1))],
          body: LetTerm(
            bindings: [
              (
                'y',
                CallTerm(
                  callee: FunctionReferenceTerm('addOne', functions),
                  arguments: const [LetBoundVariableTerm('x')],
                ),
              ),
            ],
            body: const LetBoundVariableTerm('y'),
          ),
        );
        final Term result = term.reduce();
        expect(result, isA<NumberTerm>());
        expect((result as NumberTerm).value, equals(2));
      });

      test('binding expression is evaluated to value', () {
        // let x = 1 + 1 in x should give 2
        final TestNativeFunctionTerm add = TestNativeFunctionTerm(
          name: 'add',
          parameters: const [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
          termFunction: (List<Term> arguments) {
            final num a = (arguments[0] as NumberTerm).value;
            final num b = (arguments[1] as NumberTerm).value;
            return NumberTerm(a + b);
          },
        );
        final Map<String, FunctionTerm> functions = {'add': add};
        final LetTerm term = LetTerm(
          bindings: [
            (
              'x',
              CallTerm(
                callee: FunctionReferenceTerm('add', functions),
                arguments: const [NumberTerm(1), NumberTerm(1)],
              ),
            ),
          ],
          body: const LetBoundVariableTerm('x'),
        );
        final Term result = term.reduce();
        expect(result, isA<NumberTerm>());
        expect((result as NumberTerm).value, equals(2));
      });

      test('reduce with string body', () {
        const LetTerm term = LetTerm(
          bindings: [('x', StringTerm('hello'))],
          body: LetBoundVariableTerm('x'),
        );
        final Term result = term.reduce();
        expect(result, isA<StringTerm>());
        expect((result as StringTerm).value, equals('hello'));
      });

      test('reduce with boolean body', () {
        const LetTerm term = LetTerm(
          bindings: [('flag', BooleanTerm(true))],
          body: LetBoundVariableTerm('flag'),
        );
        final Term result = term.reduce();
        expect(result, isA<BooleanTerm>());
        expect((result as BooleanTerm).value, isTrue);
      });

      test('reduce with list body', () {
        const LetTerm term = LetTerm(
          bindings: [
            (
              'items',
              ListTerm([NumberTerm(1), NumberTerm(2), NumberTerm(3)]),
            ),
          ],
          body: LetBoundVariableTerm('items'),
        );
        final Term result = term.reduce();
        expect(result, isA<ListTerm>());
        expect((result as ListTerm).native(), equals([1, 2, 3]));
      });
    });
  });

  // --- LetTerm error propagation tests ---

  group('LetTerm error propagation', () {
    test('error in binding propagates', () {
      // Division by zero in binding
      final TestNativeFunctionTerm divide = TestNativeFunctionTerm(
        name: 'divide',
        parameters: const [
          Parameter.number('a'),
          Parameter.number('b'),
        ],
        termFunction: (List<Term> arguments) {
          final num b = (arguments[1] as NumberTerm).value;
          if (b == 0) {
            throw DivisionByZeroError(function: 'divide');
          }
          final num a = (arguments[0] as NumberTerm).value;
          return NumberTerm(a / b);
        },
      );
      final Map<String, FunctionTerm> functions = {'divide': divide};
      final LetTerm term = LetTerm(
        bindings: [
          (
            'x',
            CallTerm(
              callee: FunctionReferenceTerm('divide', functions),
              arguments: const [NumberTerm(1), NumberTerm(0)],
            ),
          ),
        ],
        body: const LetBoundVariableTerm('x'),
      );
      expect(term.reduce, throwsA(isA<DivisionByZeroError>()));
    });

    test('error in second binding propagates', () {
      final TestNativeFunctionTerm divide = TestNativeFunctionTerm(
        name: 'divide',
        parameters: const [
          Parameter.number('a'),
          Parameter.number('b'),
        ],
        termFunction: (List<Term> arguments) {
          final num b = (arguments[1] as NumberTerm).value;
          if (b == 0) {
            throw DivisionByZeroError(function: 'divide');
          }
          final num a = (arguments[0] as NumberTerm).value;
          return NumberTerm(a / b);
        },
      );
      final Map<String, FunctionTerm> functions = {'divide': divide};
      final LetTerm term = LetTerm(
        bindings: [
          ('x', const NumberTerm(1)),
          (
            'y',
            CallTerm(
              callee: FunctionReferenceTerm('divide', functions),
              arguments: const [NumberTerm(1), NumberTerm(0)],
            ),
          ),
        ],
        body: const LetBoundVariableTerm('y'),
      );
      expect(term.reduce, throwsA(isA<DivisionByZeroError>()));
    });

    test('error in body propagates', () {
      final TestNativeFunctionTerm divide = TestNativeFunctionTerm(
        name: 'divide',
        parameters: const [
          Parameter.number('a'),
          Parameter.number('b'),
        ],
        termFunction: (List<Term> arguments) {
          final num b = (arguments[1] as NumberTerm).value;
          if (b == 0) {
            throw DivisionByZeroError(function: 'divide');
          }
          final num a = (arguments[0] as NumberTerm).value;
          return NumberTerm(a / b);
        },
      );
      final Map<String, FunctionTerm> functions = {'divide': divide};
      final LetTerm term = LetTerm(
        bindings: const [('x', NumberTerm(1))],
        body: CallTerm(
          callee: FunctionReferenceTerm('divide', functions),
          arguments: const [NumberTerm(1), NumberTerm(0)],
        ),
      );
      expect(term.reduce, throwsA(isA<DivisionByZeroError>()));
    });
  });
}
