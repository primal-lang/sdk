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

    group('Type equality', () {
      test('same type instances are equal', () {
        expect(const BooleanType() == const BooleanType(), true);
        expect(const NumberType() == const NumberType(), true);
        expect(const StringType() == const StringType(), true);
        expect(const FileType() == const FileType(), true);
        expect(const DirectoryType() == const DirectoryType(), true);
        expect(const TimestampType() == const TimestampType(), true);
        expect(const VectorType() == const VectorType(), true);
        expect(const StackType() == const StackType(), true);
        expect(const QueueType() == const QueueType(), true);
        expect(const SetType() == const SetType(), true);
        expect(const ListType() == const ListType(), true);
        expect(const MapType() == const MapType(), true);
        expect(const FunctionCallType() == const FunctionCallType(), true);
        expect(const FunctionType() == const FunctionType(), true);
        expect(const AnyType() == const AnyType(), true);
      });

      test('different type instances are not equal', () {
        expect(const BooleanType() == const NumberType(), false);
        expect(const StringType() == const ListType(), false);
        expect(const FunctionType() == const FunctionCallType(), false);
        expect(const AnyType() == const BooleanType(), false);
      });

      test('type is not equal to non-Type object', () {
        // ignore: unrelated_type_equality_checks
        expect(const BooleanType() == 'Boolean', false);
        // ignore: unrelated_type_equality_checks
        expect(const NumberType() == 42, false);
      });
    });

    group('Type hashCode', () {
      test('same type instances have same hashCode', () {
        expect(const BooleanType().hashCode, const BooleanType().hashCode);
        expect(const NumberType().hashCode, const NumberType().hashCode);
        expect(const StringType().hashCode, const StringType().hashCode);
      });

      test('different type instances have different hashCodes', () {
        expect(
          const BooleanType().hashCode != const NumberType().hashCode,
          true,
        );
        expect(
          const StringType().hashCode != const ListType().hashCode,
          true,
        );
      });
    });

    group('Type.accepts', () {
      test('concrete type accepts same type', () {
        expect(const BooleanType().accepts(const BooleanType()), true);
        expect(const NumberType().accepts(const NumberType()), true);
        expect(const StringType().accepts(const StringType()), true);
        expect(const FileType().accepts(const FileType()), true);
        expect(const DirectoryType().accepts(const DirectoryType()), true);
        expect(const TimestampType().accepts(const TimestampType()), true);
        expect(const VectorType().accepts(const VectorType()), true);
        expect(const StackType().accepts(const StackType()), true);
        expect(const QueueType().accepts(const QueueType()), true);
        expect(const SetType().accepts(const SetType()), true);
        expect(const ListType().accepts(const ListType()), true);
        expect(const MapType().accepts(const MapType()), true);
        expect(
          const FunctionCallType().accepts(const FunctionCallType()),
          true,
        );
        expect(const FunctionType().accepts(const FunctionType()), true);
      });

      test('concrete type does not accept different type', () {
        expect(const BooleanType().accepts(const NumberType()), false);
        expect(const NumberType().accepts(const StringType()), false);
        expect(const StringType().accepts(const ListType()), false);
        expect(const FunctionType().accepts(const FunctionCallType()), false);
      });
    });

    group('AnyType.accepts', () {
      test('AnyType accepts any type', () {
        expect(const AnyType().accepts(const BooleanType()), true);
        expect(const AnyType().accepts(const NumberType()), true);
        expect(const AnyType().accepts(const StringType()), true);
        expect(const AnyType().accepts(const FileType()), true);
        expect(const AnyType().accepts(const DirectoryType()), true);
        expect(const AnyType().accepts(const TimestampType()), true);
        expect(const AnyType().accepts(const VectorType()), true);
        expect(const AnyType().accepts(const StackType()), true);
        expect(const AnyType().accepts(const QueueType()), true);
        expect(const AnyType().accepts(const SetType()), true);
        expect(const AnyType().accepts(const ListType()), true);
        expect(const AnyType().accepts(const MapType()), true);
        expect(const AnyType().accepts(const FunctionCallType()), true);
        expect(const AnyType().accepts(const FunctionType()), true);
        expect(const AnyType().accepts(const AnyType()), true);
      });
    });
  });

  group('TypeClass', () {
    group('OrderedType', () {
      test('toString returns Ordered', () {
        expect(const OrderedType().toString(), 'Ordered');
      });

      test('memberTypes contains Number, String, Timestamp, and Duration', () {
        final List<Type> memberTypes = const OrderedType().memberTypes;
        expect(memberTypes.length, 4);
        expect(memberTypes.contains(const NumberType()), true);
        expect(memberTypes.contains(const StringType()), true);
        expect(memberTypes.contains(const TimestampType()), true);
        expect(memberTypes.contains(const DurationType()), true);
      });

      test('accepts member types', () {
        const OrderedType orderedType = OrderedType();
        expect(orderedType.accepts(const NumberType()), true);
        expect(orderedType.accepts(const StringType()), true);
        expect(orderedType.accepts(const TimestampType()), true);
        expect(orderedType.accepts(const DurationType()), true);
      });

      test('does not accept non-member types', () {
        const OrderedType orderedType = OrderedType();
        expect(orderedType.accepts(const BooleanType()), false);
        expect(orderedType.accepts(const ListType()), false);
        expect(orderedType.accepts(const MapType()), false);
      });
    });

    group('EquatableType', () {
      test('toString returns Equatable', () {
        expect(const EquatableType().toString(), 'Equatable');
      });

      test('memberTypes contains expected types', () {
        final List<Type> memberTypes = const EquatableType().memberTypes;
        expect(memberTypes.length, 13);
        expect(memberTypes.contains(const BooleanType()), true);
        expect(memberTypes.contains(const NumberType()), true);
        expect(memberTypes.contains(const StringType()), true);
        expect(memberTypes.contains(const FileType()), true);
        expect(memberTypes.contains(const DirectoryType()), true);
        expect(memberTypes.contains(const TimestampType()), true);
        expect(memberTypes.contains(const DurationType()), true);
        expect(memberTypes.contains(const VectorType()), true);
        expect(memberTypes.contains(const StackType()), true);
        expect(memberTypes.contains(const QueueType()), true);
        expect(memberTypes.contains(const SetType()), true);
        expect(memberTypes.contains(const ListType()), true);
        expect(memberTypes.contains(const MapType()), true);
      });

      test('accepts member types', () {
        const EquatableType equatableType = EquatableType();
        expect(equatableType.accepts(const BooleanType()), true);
        expect(equatableType.accepts(const NumberType()), true);
        expect(equatableType.accepts(const ListType()), true);
        expect(equatableType.accepts(const MapType()), true);
      });

      test('does not accept non-member types', () {
        const EquatableType equatableType = EquatableType();
        expect(equatableType.accepts(const FunctionType()), false);
        expect(equatableType.accepts(const FunctionCallType()), false);
        expect(equatableType.accepts(const AnyType()), false);
      });
    });

    group('HashableType', () {
      test('toString returns Hashable', () {
        expect(const HashableType().toString(), 'Hashable');
      });

      test(
        'memberTypes contains Number, String, Boolean, Timestamp, and Duration',
        () {
          final List<Type> memberTypes = const HashableType().memberTypes;
          expect(memberTypes.length, 5);
          expect(memberTypes.contains(const NumberType()), true);
          expect(memberTypes.contains(const StringType()), true);
          expect(memberTypes.contains(const BooleanType()), true);
          expect(memberTypes.contains(const TimestampType()), true);
          expect(memberTypes.contains(const DurationType()), true);
        },
      );

      test('accepts member types', () {
        const HashableType hashableType = HashableType();
        expect(hashableType.accepts(const NumberType()), true);
        expect(hashableType.accepts(const StringType()), true);
        expect(hashableType.accepts(const BooleanType()), true);
        expect(hashableType.accepts(const TimestampType()), true);
        expect(hashableType.accepts(const DurationType()), true);
      });

      test('does not accept non-member types', () {
        const HashableType hashableType = HashableType();
        expect(hashableType.accepts(const ListType()), false);
        expect(hashableType.accepts(const MapType()), false);
        expect(hashableType.accepts(const VectorType()), false);
      });
    });

    group('IndexableType', () {
      test('toString returns Indexable', () {
        expect(const IndexableType().toString(), 'Indexable');
      });

      test('memberTypes contains String, List, and Map', () {
        final List<Type> memberTypes = const IndexableType().memberTypes;
        expect(memberTypes.length, 3);
        expect(memberTypes.contains(const StringType()), true);
        expect(memberTypes.contains(const ListType()), true);
        expect(memberTypes.contains(const MapType()), true);
      });

      test('accepts member types', () {
        const IndexableType indexableType = IndexableType();
        expect(indexableType.accepts(const StringType()), true);
        expect(indexableType.accepts(const ListType()), true);
        expect(indexableType.accepts(const MapType()), true);
      });

      test('does not accept non-member types', () {
        const IndexableType indexableType = IndexableType();
        expect(indexableType.accepts(const NumberType()), false);
        expect(indexableType.accepts(const SetType()), false);
        expect(indexableType.accepts(const VectorType()), false);
      });
    });

    group('CollectionType', () {
      test('toString returns Collection', () {
        expect(const CollectionType().toString(), 'Collection');
      });

      test('memberTypes contains List, Set, Stack, Queue, and Map', () {
        final List<Type> memberTypes = const CollectionType().memberTypes;
        expect(memberTypes.length, 5);
        expect(memberTypes.contains(const ListType()), true);
        expect(memberTypes.contains(const SetType()), true);
        expect(memberTypes.contains(const StackType()), true);
        expect(memberTypes.contains(const QueueType()), true);
        expect(memberTypes.contains(const MapType()), true);
      });

      test('accepts member types', () {
        const CollectionType collectionType = CollectionType();
        expect(collectionType.accepts(const ListType()), true);
        expect(collectionType.accepts(const SetType()), true);
        expect(collectionType.accepts(const StackType()), true);
        expect(collectionType.accepts(const QueueType()), true);
        expect(collectionType.accepts(const MapType()), true);
      });

      test('does not accept non-member types', () {
        const CollectionType collectionType = CollectionType();
        expect(collectionType.accepts(const StringType()), false);
        expect(collectionType.accepts(const NumberType()), false);
        expect(collectionType.accepts(const VectorType()), false);
      });
    });

    group('IterableType', () {
      test('toString returns Iterable', () {
        expect(const IterableType().toString(), 'Iterable');
      });

      test('memberTypes contains String, List, Set, Stack, and Queue', () {
        final List<Type> memberTypes = const IterableType().memberTypes;
        expect(memberTypes.length, 5);
        expect(memberTypes.contains(const StringType()), true);
        expect(memberTypes.contains(const ListType()), true);
        expect(memberTypes.contains(const SetType()), true);
        expect(memberTypes.contains(const StackType()), true);
        expect(memberTypes.contains(const QueueType()), true);
      });

      test('accepts member types', () {
        const IterableType iterableType = IterableType();
        expect(iterableType.accepts(const StringType()), true);
        expect(iterableType.accepts(const ListType()), true);
        expect(iterableType.accepts(const SetType()), true);
        expect(iterableType.accepts(const StackType()), true);
        expect(iterableType.accepts(const QueueType()), true);
      });

      test('does not accept non-member types', () {
        const IterableType iterableType = IterableType();
        expect(iterableType.accepts(const MapType()), false);
        expect(iterableType.accepts(const NumberType()), false);
        expect(iterableType.accepts(const VectorType()), false);
      });
    });

    group('AddableType', () {
      test('toString returns Addable', () {
        expect(const AddableType().toString(), 'Addable');
      });

      test(
        'memberTypes contains Number, String, Vector, List, Set, and Duration',
        () {
          final List<Type> memberTypes = const AddableType().memberTypes;
          expect(memberTypes.length, 6);
          expect(memberTypes.contains(const NumberType()), true);
          expect(memberTypes.contains(const StringType()), true);
          expect(memberTypes.contains(const VectorType()), true);
          expect(memberTypes.contains(const ListType()), true);
          expect(memberTypes.contains(const SetType()), true);
          expect(memberTypes.contains(const DurationType()), true);
        },
      );

      test('accepts member types', () {
        const AddableType addableType = AddableType();
        expect(addableType.accepts(const NumberType()), true);
        expect(addableType.accepts(const StringType()), true);
        expect(addableType.accepts(const VectorType()), true);
        expect(addableType.accepts(const ListType()), true);
        expect(addableType.accepts(const SetType()), true);
        expect(addableType.accepts(const DurationType()), true);
      });

      test('does not accept non-member types', () {
        const AddableType addableType = AddableType();
        expect(addableType.accepts(const MapType()), false);
        expect(addableType.accepts(const BooleanType()), false);
        expect(addableType.accepts(const QueueType()), false);
      });
    });

    group('SubtractableType', () {
      test('toString returns Subtractable', () {
        expect(const SubtractableType().toString(), 'Subtractable');
      });

      test('memberTypes contains Number, Vector, Set, and Duration', () {
        final List<Type> memberTypes = const SubtractableType().memberTypes;
        expect(memberTypes.length, 4);
        expect(memberTypes.contains(const NumberType()), true);
        expect(memberTypes.contains(const VectorType()), true);
        expect(memberTypes.contains(const SetType()), true);
        expect(memberTypes.contains(const DurationType()), true);
      });

      test('accepts member types', () {
        const SubtractableType subtractableType = SubtractableType();
        expect(subtractableType.accepts(const NumberType()), true);
        expect(subtractableType.accepts(const VectorType()), true);
        expect(subtractableType.accepts(const SetType()), true);
        expect(subtractableType.accepts(const DurationType()), true);
      });

      test('does not accept non-member types', () {
        const SubtractableType subtractableType = SubtractableType();
        expect(subtractableType.accepts(const StringType()), false);
        expect(subtractableType.accepts(const ListType()), false);
        expect(subtractableType.accepts(const MapType()), false);
      });
    });

    group('TypeClass equality', () {
      test('same TypeClass instances are equal', () {
        expect(const OrderedType() == const OrderedType(), true);
        expect(const EquatableType() == const EquatableType(), true);
        expect(const HashableType() == const HashableType(), true);
        expect(const IndexableType() == const IndexableType(), true);
        expect(const CollectionType() == const CollectionType(), true);
        expect(const IterableType() == const IterableType(), true);
        expect(const AddableType() == const AddableType(), true);
        expect(const SubtractableType() == const SubtractableType(), true);
      });

      test('different TypeClass instances are not equal', () {
        expect(const OrderedType() == const EquatableType(), false);
        expect(const HashableType() == const IndexableType(), false);
        expect(const CollectionType() == const IterableType(), false);
        expect(const AddableType() == const SubtractableType(), false);
      });

      test('TypeClass is not equal to concrete Type', () {
        expect(const OrderedType() == (const NumberType() as Object), false);
        expect(const CollectionType() == (const ListType() as Object), false);
      });
    });

    group('TypeClass extends Type', () {
      test('all TypeClasses extend Type', () {
        expect(const OrderedType(), isA<Type>());
        expect(const EquatableType(), isA<Type>());
        expect(const HashableType(), isA<Type>());
        expect(const IndexableType(), isA<Type>());
        expect(const CollectionType(), isA<Type>());
        expect(const IterableType(), isA<Type>());
        expect(const AddableType(), isA<Type>());
        expect(const SubtractableType(), isA<Type>());
      });

      test('all TypeClasses extend TypeClass', () {
        expect(const OrderedType(), isA<TypeClass>());
        expect(const EquatableType(), isA<TypeClass>());
        expect(const HashableType(), isA<TypeClass>());
        expect(const IndexableType(), isA<TypeClass>());
        expect(const CollectionType(), isA<TypeClass>());
        expect(const IterableType(), isA<TypeClass>());
        expect(const AddableType(), isA<TypeClass>());
        expect(const SubtractableType(), isA<TypeClass>());
      });
    });

    group('TypeClass const constructors', () {
      test('const constructors create identical instances', () {
        expect(identical(const OrderedType(), const OrderedType()), true);
        expect(identical(const EquatableType(), const EquatableType()), true);
        expect(identical(const HashableType(), const HashableType()), true);
        expect(identical(const IndexableType(), const IndexableType()), true);
        expect(identical(const CollectionType(), const CollectionType()), true);
        expect(identical(const IterableType(), const IterableType()), true);
        expect(identical(const AddableType(), const AddableType()), true);
        expect(
          identical(const SubtractableType(), const SubtractableType()),
          true,
        );
      });
    });
  });
}
