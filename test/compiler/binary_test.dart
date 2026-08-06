@Tags(['binary'])
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path_lib;
import 'package:primal/main/main_cli.dart';
import 'package:test/test.dart';
import '../helpers/temp_helpers.dart';
import '../helpers/test_line_helpers.dart';

/// Smoke tests for the compiled binary produced by `scripts/build_desktop.sh`.
///
/// The rest of the suite runs the CLI under `dart run`, which is a JIT of the
/// same sources. These run the shipped artifact instead, so that anything only
/// ahead-of-time compilation can break — a tree-shaken symbol, a snapshot that
/// will not start — is caught before the binary is uploaded as a release asset.
/// The coverage is deliberately the documented contract rather than a second
/// pass over what `cli_test.dart` already checks.
///
/// Nothing runs unless [binaryVariable] names the binary to test, which the
/// build workflow points at what it has just compiled:
///
/// ```
/// bash scripts/build_desktop.sh
/// PRIMAL_BINARY=bin/primal-linux-x86-64 dart test test/compiler/binary_test.dart
/// ```
///
/// Deliberately not defaulted to the artifacts committed in `bin/`. Those are
/// the assets of the last release rather than a build of the current sources,
/// so the version assertion below would fail against them for the whole stretch
/// of a release between the version being bumped and the new binaries being
/// committed.
void main() {
  final String? configured = Platform.environment[binaryVariable];

  if (configured == null || configured.isEmpty) {
    return;
  }

  final File binary = File(configured);

  if (!binary.existsSync()) {
    // Reported rather than skipped: a build step aimed at the wrong path has to
    // say so, instead of passing having run nothing.
    test('the configured binary exists', () {
      fail('$binaryVariable points at "$configured", which does not exist.');
    });

    return;
  }

  group('compiled binary', () {
    late Directory tempDir;
    late String executable;
    Directory? executableDirectory;

    // The Windows artifact is deliberately built without a .exe extension,
    // because the installer downloads it under that name and adds the extension
    // itself. Copying does the same thing the installer does, so what runs here
    // is the shape a user ends up with. Done once for the group rather than per
    // test: the file is several megabytes, and deleting an executable straight
    // after the process using it exited is its own source of flakiness.
    setUpAll(() {
      if (!Platform.isWindows) {
        executable = binary.absolute.path;

        return;
      }

      final Directory directory = Directory.systemTemp.createTempSync(
        'primal_binary_exe_',
      );
      final String copy = path_lib.join(directory.path, 'primal.exe');
      binary.copySync(copy);

      executableDirectory = directory;
      executable = copy;
    });

    tearDownAll(() {
      final Directory? directory = executableDirectory;

      if (directory != null && directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });

    setUp(() {
      tempDir = createTempTestDirectory('primal_binary_test_');
    });

    File writeProgram(String name, String source) {
      final File file = File(path_lib.join(tempDir.path, name));
      file.writeAsStringSync(source);

      return file;
    }

    // The binary writes UTF-8, but Process.run decodes with systemEncoding,
    // which is a legacy code page on Windows. Decoding explicitly keeps the
    // output intact on every platform. The home directory is pointed at the
    // temporary one for the same reason cli_test.dart does it: nothing here
    // should read or write the real one.
    Future<ProcessResult> run(List<String> arguments) {
      return Process.run(
        executable,
        arguments,
        environment: <String, String>{
          'HOME': tempDir.path,
          'XDG_CONFIG_HOME': tempDir.path,
        },
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
    }

    test('--version prints the version it was built from', () async {
      final ProcessResult result = await run(<String>['--version']);

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString().trim(), equals(version));
    });

    test('--help prints the usage text', () async {
      final ProcessResult result = await run(<String>['--help']);

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains('Usage: primal'));
    });

    test('runs a sample program from the repository', () async {
      final ProcessResult result = await run(<String>[
        'test/resources/samples/factorial.prm',
      ]);

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString().trim(), equals('120'));
    });

    test('runs a program written outside the repository', () async {
      final File program = writeProgram('main.prm', 'main() = 42');

      final ProcessResult result = await run(<String>[program.path]);

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString().trim(), equals('42'));
    });

    test('passes arguments through to main', () async {
      final File program = writeProgram('args.prm', 'main(x) = x');

      final ProcessResult result = await run(<String>[program.path, 'hello']);

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString().trim(), equals(primalString('hello')));
    });

    test('exits 1 for a file that does not exist', () async {
      final ProcessResult result = await run(<String>[
        path_lib.join(tempDir.path, 'absent.prm'),
      ]);

      expect(result.exitCode, equals(1));
      expect(result.stderr.toString(), isNotEmpty);
    });

    test('exits 2 for a wrong invocation', () async {
      final ProcessResult result = await run(<String>['--test']);

      expect(result.exitCode, equals(2));
      expect(
        result.stderr.toString(),
        contains('--test requires exactly one file argument'),
      );
    });

    test('--test exits 0 when every test passes', () async {
      final File program = writeProgram(
        'pass.prm',
        'test_addition() = assert_equal(1 + 1, 2)\n',
      );

      final ProcessResult result = await run(<String>['--test', program.path]);

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), contains(passLine('test_addition')));
    });

    test('--test exits 1 when a test fails', () async {
      final File program = writeProgram(
        'fail.prm',
        'test_addition() = assert_equal(1 + 1, 3)\n',
      );

      final ProcessResult result = await run(<String>['--test', program.path]);

      expect(result.exitCode, equals(1));
      expect(result.stdout.toString(), contains(failLine('test_addition')));
    });

    test('starts the REPL and exits on :quit', () async {
      final Process process = await Process.start(
        executable,
        <String>[],
        environment: <String, String>{
          'HOME': tempDir.path,
          'XDG_CONFIG_HOME': tempDir.path,
        },
      );

      // Killed however this ends. A REPL that stopped honouring :quit would
      // otherwise be left running: it does not exit on a closed stdin, it spins
      // reprinting its prompt, so nothing else here would ever stop it.
      addTearDown(process.kill);

      process.stdin.writeln(':quit');
      await process.stdin.close();

      // Both pipes are consumed concurrently. Draining one to completion while
      // the other fills would block the process against a full buffer, and a
      // spinning REPL fills one quickly.
      final Future<String> pendingOutput = process.stdout
          .transform(utf8.decoder)
          .join();
      final Future<String> pendingError = process.stderr
          .transform(utf8.decoder)
          .join();

      final int exitCode = await process.exitCode.timeout(
        const Duration(seconds: 30),
      );
      final String output = await pendingOutput;
      final String errorOutput = await pendingError;

      expect(exitCode, equals(0), reason: errorOutput);
      // The banner carries the version, which is the cheapest proof that the
      // REPL got far enough to be reading input rather than exiting early.
      expect(output, contains(version));
    });

    // The REPL used to read a closed stdin as an unending run of blank lines
    // and spin reprinting its prompt, so 'primal < file' never came back and
    // burned a core until it was killed.
    test('the REPL ends when its input is closed', () async {
      final Process process = await Process.start(
        executable,
        <String>[],
        environment: <String, String>{
          'HOME': tempDir.path,
          'XDG_CONFIG_HOME': tempDir.path,
        },
      );

      addTearDown(process.kill);

      // Closed without writing anything: the first read is already the end.
      await process.stdin.close();

      final Future<String> pendingOutput = process.stdout
          .transform(utf8.decoder)
          .join();
      final Future<String> pendingError = process.stderr
          .transform(utf8.decoder)
          .join();

      final int exitCode = await process.exitCode.timeout(
        const Duration(seconds: 30),
      );
      final String output = await pendingOutput;
      final String errorOutput = await pendingError;

      expect(exitCode, equals(0), reason: errorOutput);
      // The banner and one prompt, rather than a prompt per read forever.
      expect(output.length, lessThan(4096));
    });
  });
}

/// Environment variable naming the binary to test.
const String binaryVariable = 'PRIMAL_BINARY';
