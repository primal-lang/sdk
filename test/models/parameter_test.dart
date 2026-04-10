@Tags(['unit'])
library;

import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:test/test.dart';

void main() {
  group('Parameter', () {
    test('boolean factory creates parameter with BooleanType', () {
      const Parameter p = Parameter.boolean('flag');
      expect(p.name, 'flag');
      expect(p.type, isA<BooleanType>());
    });

    test('number factory creates parameter with NumberType', () {
      const Parameter p = Parameter.number('x');
      expect(p.name, 'x');
      expect(p.type, isA<NumberType>());
    });

    test('string factory creates parameter with StringType', () {
      const Parameter p = Parameter.string('s');
      expect(p.name, 's');
      expect(p.type, isA<StringType>());
    });

    test('file factory creates parameter with FileType', () {
      const Parameter p = Parameter.file('f');
      expect(p.name, 'f');
      expect(p.type, isA<FileType>());
    });

    test('directory factory creates parameter with DirectoryType', () {
      const Parameter p = Parameter.directory('d');
      expect(p.name, 'd');
      expect(p.type, isA<DirectoryType>());
    });

    test('timestamp factory creates parameter with TimestampType', () {
      const Parameter p = Parameter.timestamp('t');
      expect(p.name, 't');
      expect(p.type, isA<TimestampType>());
    });

    test('list factory creates parameter with ListType', () {
      const Parameter p = Parameter.list('l');
      expect(p.name, 'l');
      expect(p.type, isA<ListType>());
    });

    test('vector factory creates parameter with VectorType', () {
      const Parameter p = Parameter.vector('v');
      expect(p.name, 'v');
      expect(p.type, isA<VectorType>());
    });

    test('set factory creates parameter with SetType', () {
      const Parameter p = Parameter.set('s');
      expect(p.name, 's');
      expect(p.type, isA<SetType>());
    });

    test('stack factory creates parameter with StackType', () {
      const Parameter p = Parameter.stack('s');
      expect(p.name, 's');
      expect(p.type, isA<StackType>());
    });

    test('queue factory creates parameter with QueueType', () {
      const Parameter p = Parameter.queue('q');
      expect(p.name, 'q');
      expect(p.type, isA<QueueType>());
    });

    test('map factory creates parameter with MapType', () {
      const Parameter p = Parameter.map('m');
      expect(p.name, 'm');
      expect(p.type, isA<MapType>());
    });

    test('function factory creates parameter with FunctionType', () {
      const Parameter p = Parameter.function('f');
      expect(p.name, 'f');
      expect(p.type, isA<FunctionType>());
    });

    test('any factory creates parameter with AnyType', () {
      const Parameter p = Parameter.any('a');
      expect(p.name, 'a');
      expect(p.type, isA<AnyType>());
    });

    test('ordered factory creates parameter with OrderedType', () {
      const Parameter p = Parameter.ordered('o');
      expect(p.name, 'o');
      expect(p.type, isA<OrderedType>());
    });

    test('equatable factory creates parameter with EquatableType', () {
      const Parameter p = Parameter.equatable('e');
      expect(p.name, 'e');
      expect(p.type, isA<EquatableType>());
    });

    test('hashable factory creates parameter with HashableType', () {
      const Parameter p = Parameter.hashable('h');
      expect(p.name, 'h');
      expect(p.type, isA<HashableType>());
    });

    test('indexable factory creates parameter with IndexableType', () {
      const Parameter p = Parameter.indexable('i');
      expect(p.name, 'i');
      expect(p.type, isA<IndexableType>());
    });

    test('collection factory creates parameter with CollectionType', () {
      const Parameter p = Parameter.collection('c');
      expect(p.name, 'c');
      expect(p.type, isA<CollectionType>());
    });

    test('iterable factory creates parameter with IterableType', () {
      const Parameter p = Parameter.iterable('i');
      expect(p.name, 'i');
      expect(p.type, isA<IterableType>());
    });

    test('addable factory creates parameter with AddableType', () {
      const Parameter p = Parameter.addable('a');
      expect(p.name, 'a');
      expect(p.type, isA<AddableType>());
    });

    test('subtractable factory creates parameter with SubtractableType', () {
      const Parameter p = Parameter.subtractable('s');
      expect(p.name, 's');
      expect(p.type, isA<SubtractableType>());
    });

    group('toString', () {
      test('returns parameter name', () {
        const Parameter p = Parameter.number('myParam');
        expect(p.toString(), 'myParam');
      });

      test('returns empty string for empty name', () {
        const Parameter p = Parameter.number('');
        expect(p.toString(), '');
      });

      test('returns name with special characters', () {
        const Parameter p = Parameter.string('param_name');
        expect(p.toString(), 'param_name');
      });

      test('returns name with unicode characters', () {
        const Parameter p = Parameter.string('\u03b1\u03b2\u03b3');
        expect(p.toString(), '\u03b1\u03b2\u03b3');
      });
    });

    group('equality', () {
      test('identical parameters are equal', () {
        const Parameter p = Parameter.number('x');
        expect(p == p, isTrue);
      });

      test('parameters with same name and type are equal', () {
        const Parameter p1 = Parameter.number('x');
        const Parameter p2 = Parameter.number('x');
        expect(p1 == p2, isTrue);
        expect(p1.hashCode, p2.hashCode);
      });

      test('parameters with different names are not equal', () {
        const Parameter p1 = Parameter.number('x');
        const Parameter p2 = Parameter.number('y');
        expect(p1 == p2, isFalse);
      });

      test('parameters with same name but different types are not equal', () {
        const Parameter p1 = Parameter.number('x');
        const Parameter p2 = Parameter.string('x');
        expect(p1 == p2, isFalse);
      });

      test('parameter is not equal to non-Parameter object', () {
        const Parameter p = Parameter.number('x');
        const Object other = 'x';
        expect(p == other, isFalse);
      });

      test('parameters with empty names are equal if types match', () {
        const Parameter p1 = Parameter.number('');
        const Parameter p2 = Parameter.number('');
        expect(p1 == p2, isTrue);
        expect(p1.hashCode, p2.hashCode);
      });

      test('different parameters have different hash codes', () {
        const Parameter p1 = Parameter.number('x');
        const Parameter p2 = Parameter.number('y');
        expect(p1.hashCode, isNot(p2.hashCode));
      });

      test('parameters with same name but type class differ', () {
        const Parameter p1 = Parameter.ordered('x');
        const Parameter p2 = Parameter.equatable('x');
        expect(p1 == p2, isFalse);
      });
    });

    group('edge cases', () {
      test('parameter with empty name', () {
        const Parameter p = Parameter.any('');
        expect(p.name, '');
        expect(p.type, isA<AnyType>());
      });

      test('parameter with whitespace name', () {
        const Parameter p = Parameter.number('  ');
        expect(p.name, '  ');
        expect(p.type, isA<NumberType>());
      });

      test('parameter with numeric name', () {
        const Parameter p = Parameter.string('123');
        expect(p.name, '123');
        expect(p.type, isA<StringType>());
      });

      test('parameter with single character name', () {
        const Parameter p = Parameter.boolean('x');
        expect(p.name, 'x');
        expect(p.type, isA<BooleanType>());
      });

      test('parameter with long name', () {
        const String longName =
            'thisIsAVeryLongParameterNameThatExceedsTypicalLengths';
        const Parameter p = Parameter.number(longName);
        expect(p.name, longName);
        expect(p.type, isA<NumberType>());
      });
    });
  });
}
