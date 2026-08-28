@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';

import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Logic', () {
    group('Short-circuit behavior', () {
      test('bool_and skips the second argument when the first is false', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = bool_and(false, error_throw(-1, "Not evaluated"))',
        );
        checkResult(runtime, false);
      });

      test('bool_or skips the second argument when the first is true', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = bool_or(true, error_throw(-1, "Not evaluated"))',
        );
        checkResult(runtime, true);
      });
    });

    test('bool_and returns true when both are true', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_and(true, true)');
      checkResult(runtime, true);
    });

    test('bool_and returns false when first is false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_and(false, true)',
      );
      checkResult(runtime, false);
    });

    test('bool_and returns false when second is false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_and(true, false)',
      );
      checkResult(runtime, false);
    });

    test('bool_and returns false when both are false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_and(false, false)',
      );
      checkResult(runtime, false);
    });

    test('bool_or returns true when both are true', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_or(true, true)');
      checkResult(runtime, true);
    });

    test('bool_or returns true when first is true', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_or(true, false)');
      checkResult(runtime, true);
    });

    test('bool_or returns true when second is true', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_or(false, true)');
      checkResult(runtime, true);
    });

    test('bool_or returns false when both are false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_or(false, false)',
      );
      checkResult(runtime, false);
    });

    test('bool_xor returns false when both are true', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_xor(true, true)');
      checkResult(runtime, false);
    });

    test('bool_xor returns true when only first is true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_xor(true, false)',
      );
      checkResult(runtime, true);
    });

    test('bool_xor returns true when only second is true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_xor(false, true)',
      );
      checkResult(runtime, true);
    });

    test('bool_xor returns false when both are false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_xor(false, false)',
      );
      checkResult(runtime, false);
    });

    test('bool_not negates true to false', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_not(true)');
      checkResult(runtime, false);
    });

    test('bool_not negates false to true', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_not(false)');
      checkResult(runtime, true);
    });

    group('Strict evaluation', () {
      test('bool_andStrict returns false when left is false', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = bool_andStrict(false, false)',
        );
        checkResult(runtime, false);
      });

      test('bool_andStrict evaluates the second argument eagerly', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = bool_andStrict(false, error_throw(-1, "Boom"))',
        );
        expect(runtime.executeMain, throwsA(isA<CustomError>()));
      });

      test(
        'bool_orStrict returns true when left is false and right is true',
        () {
          final RuntimeFacade runtime = getRuntime(
            'main() = bool_orStrict(false, true)',
          );
          checkResult(runtime, true);
        },
      );

      test('bool_orStrict evaluates the second argument eagerly', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = bool_orStrict(true, error_throw(-1, "Boom"))',
        );
        expect(runtime.executeMain, throwsA(isA<CustomError>()));
      });
    });
  });

  group('Logic Type Errors', () {
    test('bool_and throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_and(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_and throws when first is boolean but second is number', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_and(true, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_and throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_and("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_and throws for list arguments', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_and([1], [2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_or throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_or(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_or throws when first is false but second is number', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_or(false, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_or throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_or("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_or throws for list arguments', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_or([1], [2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_andStrict throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_andStrict("a", "b")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_orStrict throws for list arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool_orStrict([1], [2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_not throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_not(1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_not throws for string argument', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_not("a")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_not throws for list argument', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_not([1])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_xor throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_xor("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_xor throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_xor(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_xor throws for list arguments', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_xor([1], [2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool_xor throws when first is boolean but second is number', () {
      final RuntimeFacade runtime = getRuntime('main() = bool_xor(true, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
