@Tags(['unit'])
library;

import 'package:primal/compiler/models/state.dart';
import 'package:primal/utils/list_iterator.dart';
import 'package:test/test.dart';

void main() {
  group('State', () {
    test('default process returns itself', () {
      final ListIterator<int> iterator = ListIterator([1, 2, 3]);
      final State<int, String> state = State(iterator, 'output');
      final State result = state.process(42);
      expect(result, same(state));
    });
  });
}
