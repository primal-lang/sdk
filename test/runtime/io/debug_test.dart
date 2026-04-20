@Tags(['runtime', 'io'])
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

Future<ProcessResult> runDebugProgram({
  required String source,
}) async {
  final Directory tempDir = Directory.systemTemp.createTempSync(
    'primal_debug_test_',
  );
  addTearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  final Process process = await Process.start(
    Platform.resolvedExecutable,
    ['run', 'test/helpers/runtime_console_write_runner.dart', source],
    environment: {
      'HOME': tempDir.path,
      'XDG_CONFIG_HOME': tempDir.path,
    },
  );

  final Future<String> stdoutFuture = process.stdout
      .transform(
        utf8.decoder,
      )
      .join();
  final Future<String> stderrFuture = process.stderr
      .transform(
        utf8.decoder,
      )
      .join();

  await process.stdin.close();

  final String stdout = await stdoutFuture;
  final String stderr = await stderrFuture;
  final int exitCode = await process.exitCode;

  if (exitCode != 0) {
    fail('Process exited with code $exitCode: $stderr');
  }

  return ProcessResult(process.pid, exitCode, stdout, stderr);
}

void main() {
  group('Debug Basic Functionality', () {
    test('debug with number returns the number', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("value", 42)',
      );

      expect(result.stdout.toString(), equals('[debug] value: 42\n'));
      expect(result.stderr.toString().trim(), equals('42'));
    });

    test('debug with string returns the string', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("greeting", "hello world")',
      );

      expect(
        result.stdout.toString(),
        equals('[debug] greeting: hello world\n'),
      );
      expect(result.stderr.toString().trim(), equals('"hello world"'));
    });

    test('debug with boolean returns the boolean', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("flag", true)',
      );

      expect(result.stdout.toString(), equals('[debug] flag: true\n'));
      expect(result.stderr.toString().trim(), equals('true'));
    });

    test('debug with expression evaluates before printing', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("result", 1 + 2)',
      );

      expect(result.stdout.toString(), equals('[debug] result: 3\n'));
      expect(result.stderr.toString().trim(), equals('3'));
    });

    test('debug with list returns the list', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("items", [1, 2, 3])',
      );

      expect(result.stdout.toString(), equals('[debug] items: [1, 2, 3]\n'));
      expect(result.stderr.toString().trim(), equals('[1, 2, 3]'));
    });

    test('debug with map returns the map', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("user", {"name": "Alice", "age": 30})',
      );

      expect(
        result.stdout.toString(),
        equals('[debug] user: {name: Alice, age: 30}\n'),
      );
      expect(
        result.stderr.toString().trim(),
        equals('{"name": "Alice", "age": 30}'),
      );
    });
  });

  group('Debug Deep Evaluation', () {
    test('debug deep-reduces list elements', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("x", [1 + 2, 3 * 4])',
      );

      expect(result.stdout.toString(), equals('[debug] x: [3, 12]\n'));
      expect(result.stderr.toString().trim(), equals('[3, 12]'));
    });

    test('debug deep-reduces map values', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("x", {"sum": 1 + 2})',
      );

      expect(result.stdout.toString(), equals('[debug] x: {sum: 3}\n'));
      expect(result.stderr.toString().trim(), equals('{"sum": 3}'));
    });

    test('debug deep-reduces nested collections', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("x", [[1 + 2]])',
      );

      expect(result.stdout.toString(), equals('[debug] x: [[3]]\n'));
      expect(result.stderr.toString().trim(), equals('[[3]]'));
    });

    test('debug return value is usable in expressions', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = list.first(debug("x", [1 + 2]))',
      );

      expect(result.stdout.toString(), equals('[debug] x: [3]\n'));
      expect(result.stderr.toString().trim(), equals('3'));
    });
  });

  group('Debug Return Value Usage', () {
    test('debug return value used in arithmetic', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = num.add(debug("a", 5), debug("b", 10))',
      );

      expect(
        result.stdout.toString(),
        equals('[debug] a: 5\n[debug] b: 10\n'),
      );
      expect(result.stderr.toString().trim(), equals('15'));
    });

    test('debug return value used in list creation', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = [debug("first", 1), debug("second", 2)]',
      );

      expect(
        result.stdout.toString(),
        equals('[debug] first: 1\n[debug] second: 2\n'),
      );
      expect(result.stderr.toString().trim(), equals('[1, 2]'));
    });

    test('debug with function returns callable function', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("abs", num.abs)(-5)',
      );

      expect(
        result.stdout.toString(),
        equals('[debug] abs: num.abs(a: Number)\n'),
      );
      expect(result.stderr.toString().trim(), equals('5'));
    });

    test('debug with lambda returns callable lambda', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("inc", (x) -> x + 1)(5)',
      );

      expect(
        result.stdout.toString(),
        contains('[debug] inc: <lambda@'),
      );
      expect(result.stderr.toString().trim(), equals('6'));
    });

    test('closure preserves captured bindings after debug', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = let y = 10 in debug("f", (x) -> x + y)(5)',
      );

      expect(result.stdout.toString(), contains('[debug] f: <lambda@'));
      expect(result.stderr.toString().trim(), equals('15'));
    });
  });

  group('Debug Empty Collections', () {
    test('debug with empty list', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("empty list", [])',
      );

      expect(result.stdout.toString(), equals('[debug] empty list: []\n'));
      expect(result.stderr.toString().trim(), equals('[]'));
    });

    test('debug with empty map', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("empty map", {})',
      );

      expect(result.stdout.toString(), equals('[debug] empty map: {}\n'));
      expect(result.stderr.toString().trim(), equals('{}'));
    });

    test('debug with empty set', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("empty set", set.new([]))',
      );

      expect(result.stdout.toString(), equals('[debug] empty set: {}\n'));
    });
  });

  group('Debug Edge Cases', () {
    test('debug with empty label', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("", 1)',
      );

      expect(result.stdout.toString(), equals('[debug] : 1\n'));
      expect(result.stderr.toString().trim(), equals('1'));
    });

    test('debug with unicode label', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("\u7ed3\u679c", 1)',
      );

      expect(result.stdout.toString(), equals('[debug] \u7ed3\u679c: 1\n'));
      expect(result.stderr.toString().trim(), equals('1'));
    });

    test('nested debug calls', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("outer", debug("inner", 1))',
      );

      expect(
        result.stdout.toString(),
        equals('[debug] inner: 1\n[debug] outer: 1\n'),
      );
      expect(result.stderr.toString().trim(), equals('1'));
    });

    test('debug with infinity', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("inf", num.infinity())',
      );

      expect(result.stdout.toString(), equals('[debug] inf: Infinity\n'));
    });

    test('debug with negative number', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("neg", -42)',
      );

      expect(result.stdout.toString(), equals('[debug] neg: -42\n'));
      expect(result.stderr.toString().trim(), equals('-42'));
    });

    test('debug with decimal number', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("pi", 3.14)',
      );

      expect(result.stdout.toString(), equals('[debug] pi: 3.14\n'));
      expect(result.stderr.toString().trim(), equals('3.14'));
    });
  });

  group('Debug Higher-Order Usage', () {
    test('debug function passed via let binding', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = let f = debug in f("x", 1)',
      );

      expect(result.stdout.toString(), equals('[debug] x: 1\n'));
      expect(result.stderr.toString().trim(), equals('1'));
    });

    test('debug used in list.map', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = list.map([1, 2], (x) -> debug("item", x))',
      );

      expect(
        result.stdout.toString(),
        equals('[debug] item: 1\n[debug] item: 2\n'),
      );
      expect(result.stderr.toString().trim(), equals('[1, 2]'));
    });
  });

  group('Debug Recursive Function', () {
    test('debug in recursive function', () async {
      final ProcessResult result = await runDebugProgram(
        source: '''
factorial(n) = if (n <= 1)
                  debug("base case", 1)
               else
                  n * debug("factorial(" + to.string(n - 1) + ")", factorial(n - 1))

main() = factorial(4)
''',
      );

      expect(
        result.stdout.toString(),
        equals(
          '[debug] base case: 1\n'
          '[debug] factorial(1): 1\n'
          '[debug] factorial(2): 2\n'
          '[debug] factorial(3): 6\n',
        ),
      );
      expect(result.stderr.toString().trim(), equals('24'));
    });
  });

  group('Debug Intermediate Values', () {
    test('debug intermediate pipeline values', () async {
      final ProcessResult result = await runDebugProgram(
        source: '''
process(items) = let filtered = debug("after filter", list.filter(items, (x) -> x > 0)),
                     mapped = debug("after map", list.map(filtered, (x) -> x * 2))
                 in mapped

main() = process([-1, 2, -3, 4])
''',
      );

      expect(
        result.stdout.toString(),
        equals(
          '[debug] after filter: [2, 4]\n'
          '[debug] after map: [4, 8]\n',
        ),
      );
      expect(result.stderr.toString().trim(), equals('[4, 8]'));
    });
  });

  group('Debug Mixed Types in Collections', () {
    test('debug with mixed type list', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("mixed", [1, "two", true])',
      );

      expect(
        result.stdout.toString(),
        equals('[debug] mixed: [1, two, true]\n'),
      );
      expect(result.stderr.toString().trim(), equals('[1, "two", true]'));
    });

    test('debug with nested map', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("nested", {"outer": {"inner": 1}})',
      );

      expect(
        result.stdout.toString(),
        equals('[debug] nested: {outer: {inner: 1}}\n'),
      );
    });
  });

  group('Debug System Types', () {
    test('debug with file', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("f", file.fromPath("/tmp/test.txt"))',
      );

      expect(
        result.stdout.toString(),
        equals("[debug] f: File: '/tmp/test.txt'\n"),
      );
    });

    test('debug with directory', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("d", directory.fromPath("/tmp"))',
      );

      expect(
        result.stdout.toString(),
        equals("[debug] d: Directory: '/tmp'\n"),
      );
    });

    test('debug with timestamp has datetime format', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("t", time.now())',
      );

      // Timestamp format includes year-month-day
      expect(result.stdout.toString(), contains('[debug] t: '));
      expect(result.stdout.toString(), matches(RegExp(r'\d{4}-\d{2}-\d{2}')));
    });
  });

  group('Debug Collection Types', () {
    test('debug with stack', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("s", stack.new([1, 2, 3]))',
      );

      expect(result.stdout.toString(), equals('[debug] s: [1, 2, 3]\n'));
    });

    test('debug with queue', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("q", queue.new([1, 2, 3]))',
      );

      expect(result.stdout.toString(), equals('[debug] q: [1, 2, 3]\n'));
    });

    test('debug with vector', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("v", vector.new([1, 2, 3]))',
      );

      expect(result.stdout.toString(), equals('[debug] v: [1, 2, 3]\n'));
    });

    test('debug with set', () async {
      final ProcessResult result = await runDebugProgram(
        source: 'main() = debug("set", set.add(set.add(set.new([]), 1), 2))',
      );

      // Set output format
      expect(result.stdout.toString(), contains('[debug] set: {'));
    });
  });
}
