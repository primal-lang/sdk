@Tags(['unit'])
@TestOn('vm')
library;

import 'package:primal/compiler/warnings/semantic_warning.dart';
import 'package:primal/utils/console.dart';
import 'package:test/test.dart';

void main() {
  late Console console;

  setUp(() => console = Console());

  group('Console', () {
    test('print outputs message without error', () {
      expect(() => console.print('hello'), returnsNormally);
    });

    test('warning outputs formatted warning without error', () {
      const warning = SemanticWarning('test warning');
      expect(() => console.warning(warning), returnsNormally);
    });

    test('error outputs formatted error without error', () {
      expect(() => console.error(Exception('test')), returnsNormally);
    });
  });
}
