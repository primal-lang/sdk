@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Type Mismatch Errors', () {
    test('number plus boolean', () {
      final RuntimeFacade runtime = getRuntime('main = 5 + true');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "+"'),
          ),
        ),
      );
    });

    test('string minus string', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" - "world"');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "-"'),
          ),
        ),
      );
    });

    test('string times number', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" * 3');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Actual: (String, Number)'),
          ),
        ),
      );
    });

    test('num.abs with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.abs("hello")');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "num.abs"'),
              contains('Expected: (Number)'),
              contains('Actual: (String)'),
            ),
          ),
        ),
      );
    });

    test('str.length with number', () {
      final RuntimeFacade runtime = getRuntime('main = str.length(42)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "str.length"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('list.length with number', () {
      final RuntimeFacade runtime = getRuntime('main = list.length(42)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "list.length"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('boolean greater than', () {
      final RuntimeFacade runtime = getRuntime('main = true > false');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Actual: (Boolean, Boolean)'),
          ),
        ),
      );
    });

    test('boolean minus number', () {
      final RuntimeFacade runtime = getRuntime('main = true - 5');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "-"'),
          ),
        ),
      );
    });

    test('string divided by number', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" / 2');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "/"'),
          ),
        ),
      );
    });

    test('boolean modulo number', () {
      final RuntimeFacade runtime = getRuntime('main = true % 3');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "%"'),
          ),
        ),
      );
    });

    test('string plus boolean', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" + true');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "+"'),
          ),
        ),
      );
    });

    test('str.concat with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = str.concat(5, 5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "str.concat"'),
              contains('Actual: (Number, Number)'),
            ),
          ),
        ),
      );
    });

    test('str.uppercase with number', () {
      final RuntimeFacade runtime = getRuntime('main = str.uppercase(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "str.uppercase"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('str.contains with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = str.contains(5, 5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "str.contains"'),
              contains('Actual: (Number, Number)'),
            ),
          ),
        ),
      );
    });

    test('list.first with number', () {
      final RuntimeFacade runtime = getRuntime('main = list.first(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "list.first"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('list.reverse with number', () {
      final RuntimeFacade runtime = getRuntime('main = list.reverse(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "list.reverse"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('list.map with non-list', () {
      final RuntimeFacade runtime = getRuntime('main = list.map(5, num.abs)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('function "list.map"'),
          ),
        ),
      );
    });

    test('list.filter with non-list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.filter("hello", num.abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('function "list.filter"'),
          ),
        ),
      );
    });

    test('map.keys with number', () {
      final RuntimeFacade runtime = getRuntime('main = map.keys(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "map.keys"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('map.values with number', () {
      final RuntimeFacade runtime = getRuntime('main = map.values(5)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('function "map.values"'),
              contains('Actual: (Number)'),
            ),
          ),
        ),
      );
    });

    test('number less than boolean', () {
      final RuntimeFacade runtime = getRuntime('main = 5 < true');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Actual: (Number, Boolean)'),
          ),
        ),
      );
    });

    test('number less equal boolean', () {
      final RuntimeFacade runtime = getRuntime('main = 5 <= true');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Actual: (Number, Boolean)'),
          ),
        ),
      );
    });

    test('number greater equal boolean', () {
      final RuntimeFacade runtime = getRuntime('main = 5 >= true');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Actual: (Number, Boolean)'),
          ),
        ),
      );
    });

    test('number and number', () {
      final RuntimeFacade runtime = getRuntime('main = 5 & 3');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "&"'),
          ),
        ),
      );
    });

    test('not number', () {
      final RuntimeFacade runtime = getRuntime('main = !5');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid argument types for function "!"'),
          ),
        ),
      );
    });
  });

  group('Arithmetic Type Mismatches', () {
    test('num.sin with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.sin("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.cos with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.cos("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.tan with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.tan("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.log with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.log("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.negative with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.negative("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.sign with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.sign("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.inc with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.inc("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.dec with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.dec("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.fraction with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.fraction("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.asDegrees with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.asDegrees("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.asRadians with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.asRadians("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.isEven with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.isEven("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.isOdd with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.isOdd("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.isZero with string', () {
      final RuntimeFacade runtime = getRuntime('main = num.isZero("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.isNegative with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.isNegative("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.isPositive with string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.isPositive("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.max with strings', () {
      final RuntimeFacade runtime = getRuntime('main = num.max("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.min with strings', () {
      final RuntimeFacade runtime = getRuntime('main = num.min("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.sum with strings', () {
      final RuntimeFacade runtime = getRuntime('main = num.sum("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.compare with strings', () {
      final RuntimeFacade runtime = getRuntime('main = num.compare("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.integerRandom with strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.integerRandom("a", "b")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('num.clamp with strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.clamp("a", "b", "c")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('String Type Mismatches', () {
    test('str.first with number', () {
      final RuntimeFacade runtime = getRuntime('main = str.first(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.last with number', () {
      final RuntimeFacade runtime = getRuntime('main = str.last(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.rest with number', () {
      final RuntimeFacade runtime = getRuntime('main = str.rest(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.init with number', () {
      final RuntimeFacade runtime = getRuntime('main = str.init(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main = str.isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main = str.isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.bytes with number', () {
      final RuntimeFacade runtime = getRuntime('main = str.bytes(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.at with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = str.at(5, 0)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.compare with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = str.compare(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.drop with booleans', () {
      final RuntimeFacade runtime = getRuntime('main = str.drop(true, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.take with booleans', () {
      final RuntimeFacade runtime = getRuntime('main = str.take(true, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.startsWith with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = str.startsWith(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.endsWith with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = str.endsWith(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.match with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = str.match(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.padLeft with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.padLeft(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.padRight with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.padRight(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('str.removeAt with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.removeAt(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('List Type Mismatches', () {
    test('list.isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main = list.isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.rest with number', () {
      final RuntimeFacade runtime = getRuntime('main = list.rest(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.init with number', () {
      final RuntimeFacade runtime = getRuntime('main = list.init(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.at with booleans', () {
      final RuntimeFacade runtime = getRuntime('main = list.at(true, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.concat with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = list.concat(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.drop with booleans', () {
      final RuntimeFacade runtime = getRuntime('main = list.drop(true, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.filled with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.filled(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.insertEnd with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = list.insertEnd(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.insertStart with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = list.insertStart(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.join with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = list.join(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.take with booleans', () {
      final RuntimeFacade runtime = getRuntime('main = list.take(true, true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.all with non-list', () {
      final RuntimeFacade runtime = getRuntime('main = list.all(5, num.abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.any with non-list', () {
      final RuntimeFacade runtime = getRuntime('main = list.any(5, num.abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.none with non-list', () {
      final RuntimeFacade runtime = getRuntime('main = list.none(5, num.abs)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.removeAt with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.sublist with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.indexOf with non-list', () {
      final RuntimeFacade runtime = getRuntime('main = list.indexOf(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.set with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.remove with non-list', () {
      final RuntimeFacade runtime = getRuntime('main = list.remove(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.swap with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap(true, true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.zip with non-list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip(5, 5, num.abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Map Type Mismatches', () {
    test('map.isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main = map.isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.removeAt with non-map', () {
      final RuntimeFacade runtime = getRuntime('main = map.removeAt(5, "key")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map.set with non-map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.set(5, "key", "val")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Queue Type Mismatches', () {
    test('queue.new with non-list', () {
      final RuntimeFacade runtime = getRuntime('main = queue.new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main = queue.isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main = queue.isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.reverse with number', () {
      final RuntimeFacade runtime = getRuntime('main = queue.reverse(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Stack Type Mismatches', () {
    test('stack.new with non-list', () {
      final RuntimeFacade runtime = getRuntime('main = stack.new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main = stack.isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main = stack.isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.reverse with number', () {
      final RuntimeFacade runtime = getRuntime('main = stack.reverse(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Set Type Mismatches', () {
    test('set.new with non-list', () {
      final RuntimeFacade runtime = getRuntime('main = set.new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main = set.isEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isNotEmpty with number', () {
      final RuntimeFacade runtime = getRuntime('main = set.isNotEmpty(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.intersection with non-sets', () {
      final RuntimeFacade runtime = getRuntime('main = set.intersection(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Timestamp Type Mismatches', () {
    test('time.day with number', () {
      final RuntimeFacade runtime = getRuntime('main = time.day(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.epoch with number', () {
      final RuntimeFacade runtime = getRuntime('main = time.epoch(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.fromIso with number', () {
      final RuntimeFacade runtime = getRuntime('main = time.fromIso(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.hour with number', () {
      final RuntimeFacade runtime = getRuntime('main = time.hour(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.minute with number', () {
      final RuntimeFacade runtime = getRuntime('main = time.minute(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.month with number', () {
      final RuntimeFacade runtime = getRuntime('main = time.month(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.second with number', () {
      final RuntimeFacade runtime = getRuntime('main = time.second(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.toIso with number', () {
      final RuntimeFacade runtime = getRuntime('main = time.toIso(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.year with number', () {
      final RuntimeFacade runtime = getRuntime('main = time.year(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.millisecond with number', () {
      final RuntimeFacade runtime = getRuntime('main = time.millisecond(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('time.compare with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = time.compare(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Vector Type Mismatches', () {
    test('vector.new with non-list', () {
      final RuntimeFacade runtime = getRuntime('main = vector.new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.new with non-numeric elements', () {
      final RuntimeFacade runtime = getRuntime('main = vector.new(["hello"])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.magnitude with non-vector', () {
      final RuntimeFacade runtime = getRuntime('main = vector.magnitude(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.normalize with non-vector', () {
      final RuntimeFacade runtime = getRuntime('main = vector.normalize(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.add with non-vectors', () {
      final RuntimeFacade runtime = getRuntime('main = vector.add(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.sub with non-vectors', () {
      final RuntimeFacade runtime = getRuntime('main = vector.sub(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.angle with non-vectors', () {
      final RuntimeFacade runtime = getRuntime('main = vector.angle(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('vector.angle with different lengths', () {
      final RuntimeFacade runtime = getRuntime(
        'main = vector.angle(vector.new([1, 2]), vector.new([1, 2, 3]))',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<IterablesWithDifferentLengthError>()),
      );
    });
  });

  group('Directory Type Mismatches', () {
    test('directory.name with number', () {
      final RuntimeFacade runtime = getRuntime('main = directory.name(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.path with number', () {
      final RuntimeFacade runtime = getRuntime('main = directory.path(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.parent with number', () {
      final RuntimeFacade runtime = getRuntime('main = directory.parent(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.exists with number', () {
      final RuntimeFacade runtime = getRuntime('main = directory.exists(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.create with number', () {
      final RuntimeFacade runtime = getRuntime('main = directory.create(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.delete with number', () {
      final RuntimeFacade runtime = getRuntime('main = directory.delete(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.list with number', () {
      final RuntimeFacade runtime = getRuntime('main = directory.list(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.fromPath with number', () {
      final RuntimeFacade runtime = getRuntime('main = directory.fromPath(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.copy with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = directory.copy(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.move with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = directory.move(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('directory.rename with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = directory.rename(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('File Type Mismatches', () {
    test('file.name with number', () {
      final RuntimeFacade runtime = getRuntime('main = file.name(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.path with number', () {
      final RuntimeFacade runtime = getRuntime('main = file.path(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.parent with number', () {
      final RuntimeFacade runtime = getRuntime('main = file.parent(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.exists with number', () {
      final RuntimeFacade runtime = getRuntime('main = file.exists(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.create with number', () {
      final RuntimeFacade runtime = getRuntime('main = file.create(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.delete with number', () {
      final RuntimeFacade runtime = getRuntime('main = file.delete(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.read with number', () {
      final RuntimeFacade runtime = getRuntime('main = file.read(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.extension with number', () {
      final RuntimeFacade runtime = getRuntime('main = file.extension(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.length with number', () {
      final RuntimeFacade runtime = getRuntime('main = file.length(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.fromPath with number', () {
      final RuntimeFacade runtime = getRuntime('main = file.fromPath(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.copy with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = file.copy(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.move with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = file.move(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.rename with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = file.rename(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('file.write with numbers', () {
      final RuntimeFacade runtime = getRuntime('main = file.write(5, 5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Environment Type Mismatches', () {
    test('env.get with number', () {
      final RuntimeFacade runtime = getRuntime('main = env.get(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Control Flow Type Mismatches', () {
    test('if with non-boolean condition', () {
      final RuntimeFacade runtime = getRuntime('main = if (5) "a" else "b"');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Logic Short-Circuit Type Mismatches', () {
    test('true and non-boolean', () {
      final RuntimeFacade runtime = getRuntime('main = true & 5');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('false or non-boolean', () {
      final RuntimeFacade runtime = getRuntime('main = false | 5');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('JSON Type Mismatches', () {
    test('json.decode with number', () {
      final RuntimeFacade runtime = getRuntime('main = json.decode(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Operator Sub Set Branches', () {
    test('set minus element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.new([1, 2, 3]) - 2',
      );
      checkResult(runtime, '{1, 3}');
    });

    test('element minus set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = 2 - set.new([1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
