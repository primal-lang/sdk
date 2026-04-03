@Tags(['unit'])
library;

import 'package:primal/compiler/models/type.dart';
import 'package:test/test.dart';

void main() {
  group('Type', () {
    test('BooleanType toString returns Boolean', () {
      expect(const BooleanType().toString(), 'Boolean');
    });

    test('NumberType toString returns Number', () {
      expect(const NumberType().toString(), 'Number');
    });

    test('StringType toString returns String', () {
      expect(const StringType().toString(), 'String');
    });

    test('FileType toString returns File', () {
      expect(const FileType().toString(), 'File');
    });

    test('DirectoryType toString returns Directory', () {
      expect(const DirectoryType().toString(), 'Directory');
    });

    test('TimestampType toString returns Timestamp', () {
      expect(const TimestampType().toString(), 'Timestamp');
    });

    test('VectorType toString returns Vector', () {
      expect(const VectorType().toString(), 'Vector');
    });

    test('StackType toString returns Stack', () {
      expect(const StackType().toString(), 'Stack');
    });

    test('QueueType toString returns Queue', () {
      expect(const QueueType().toString(), 'Queue');
    });

    test('SetType toString returns Set', () {
      expect(const SetType().toString(), 'Set');
    });

    test('ListType toString returns List', () {
      expect(const ListType().toString(), 'List');
    });

    test('MapType toString returns Map', () {
      expect(const MapType().toString(), 'Map');
    });

    test('FunctionCallType toString returns FunctionCall', () {
      expect(const FunctionCallType().toString(), 'FunctionCall');
    });

    test('FunctionType toString returns Function', () {
      expect(const FunctionType().toString(), 'Function');
    });

    test('AnyType toString returns Any', () {
      expect(const AnyType().toString(), 'Any');
    });

    test('all types extend Type', () {
      expect(const BooleanType(), isA<Type>());
      expect(const NumberType(), isA<Type>());
      expect(const StringType(), isA<Type>());
      expect(const FileType(), isA<Type>());
      expect(const DirectoryType(), isA<Type>());
      expect(const TimestampType(), isA<Type>());
      expect(const VectorType(), isA<Type>());
      expect(const StackType(), isA<Type>());
      expect(const QueueType(), isA<Type>());
      expect(const SetType(), isA<Type>());
      expect(const ListType(), isA<Type>());
      expect(const MapType(), isA<Type>());
      expect(const FunctionCallType(), isA<Type>());
      expect(const FunctionType(), isA<Type>());
      expect(const AnyType(), isA<Type>());
    });

    test('const constructors create identical instances', () {
      expect(identical(const BooleanType(), const BooleanType()), true);
      expect(identical(const NumberType(), const NumberType()), true);
      expect(identical(const StringType(), const StringType()), true);
    });
  });
}
