@Tags(['runtime'])
@TestOn('vm')
library;

import 'dart:io';

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/bindings.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:test/test.dart';

void main() {
  group('LiteralTerm.from()', () {
    test('bool returns BooleanTerm', () {
      final LiteralTerm term = LiteralTerm.from(true);
      expect(term, isA<BooleanTerm>());
    });

    test('int returns NumberTerm', () {
      final LiteralTerm term = LiteralTerm.from(42);
      expect(term, isA<NumberTerm>());
    });

    test('double returns NumberTerm', () {
      final LiteralTerm term = LiteralTerm.from(3.14);
      expect(term, isA<NumberTerm>());
    });

    test('String returns StringTerm', () {
      final LiteralTerm term = LiteralTerm.from('hello');
      expect(term, isA<StringTerm>());
    });

    test('List<Term> returns ListTerm', () {
      final LiteralTerm term = LiteralTerm.from(<Term>[const NumberTerm(1)]);
      expect(term, isA<ListTerm>());
    });

    test('Map<Term, Term> returns MapTerm', () {
      final LiteralTerm term = LiteralTerm.from(
        <Term, Term>{const StringTerm('a'): const NumberTerm(1)},
      );
      expect(term, isA<MapTerm>());
    });

    test('DateTime returns TimestampTerm', () {
      final LiteralTerm term = LiteralTerm.from(DateTime(2024));
      expect(term, isA<TimestampTerm>());
    });

    test('File returns FileTerm', () {
      final LiteralTerm term = LiteralTerm.from(File('test.txt'));
      expect(term, isA<FileTerm>());
    });

    test('Directory returns DirectoryTerm', () {
      final LiteralTerm term = LiteralTerm.from(Directory('test'));
      expect(term, isA<DirectoryTerm>());
    });

    test('Set<Term> returns SetTerm', () {
      final LiteralTerm term = LiteralTerm.from(<Term>{const NumberTerm(1)});
      expect(term, isA<SetTerm>());
    });

    test('unsupported type throws InvalidLiteralValueError', () {
      expect(
        () => LiteralTerm.from(Object()),
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
      const FunctionTerm function = FunctionTerm(
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
      const FunctionTerm function = FunctionTerm(name: 'f', parameters: []);
      final Map<String, FunctionTerm> functions = {'f': function};
      final FunctionReferenceTerm reference = FunctionReferenceTerm(
        'f',
        functions,
      );

      expect(reference.type, isA<FunctionType>());
    });

    test('toString() returns function name', () {
      const FunctionTerm function = FunctionTerm(
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
      const FunctionTerm function = FunctionTerm(
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
      const FunctionTerm term = FunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      expect(term.type, isA<FunctionType>());
    });

    test('toString() includes name and parameters', () {
      const FunctionTerm term = FunctionTerm(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      expect(term.toString(), 'add(a: Number, b: Number)');
    });

    test('parameterTypes returns list of types', () {
      const FunctionTerm term = FunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x'), Parameter.string('y')],
      );
      expect(term.parameterTypes.length, 2);
      expect(term.parameterTypes[0], isA<NumberType>());
      expect(term.parameterTypes[1], isA<StringType>());
    });

    test('native() returns string representation', () {
      const FunctionTerm term = FunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      expect(term.native(), 'f(x: Number)');
    });

    test('apply with wrong argument count throws', () {
      const FunctionTerm term = FunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      expect(
        () => term.apply([const NumberTerm(1), const NumberTerm(2)]),
        throwsA(isA<InvalidArgumentCountError>()),
      );
    });

    test('equalSignature compares names', () {
      const FunctionTerm f1 = FunctionTerm(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      const FunctionTerm f2 = FunctionTerm(
        name: 'f',
        parameters: [Parameter.string('y')],
      );
      const FunctionTerm f3 = FunctionTerm(
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
      const FunctionTerm term = FunctionTerm(
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
  });
}
