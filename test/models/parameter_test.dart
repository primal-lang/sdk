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

    test('toString returns parameter name', () {
      const Parameter p = Parameter.number('myParam');
      expect(p.toString(), 'myParam');
    });
  });
}
