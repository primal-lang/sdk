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
///
/// The two self-install tests need the network: they fetch the published
/// installer, and `--update` also asks GitHub for the current release and
/// downloads it. They are the only tests in the suite that do, and both run
/// against a copy of the binary rather than the binary itself, since the
/// installer replaces and deletes what it is aimed at.
///
/// What they read of that installer's output belongs to it rather than to this
/// repository: it is deployed at https://primal-lang.org/install.sh and its
/// wording is not something a change here can grep for. The assertions are kept
/// to the lines that name what the installer did, which are the last thing it
/// would reword.
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
    // should read or write the real one, and it is what keeps the PATH entry
    // the installer writes out of the real shell profile.
    Future<ProcessResult> runAt(String binaryPath, List<String> arguments) {
      return Process.run(
        binaryPath,
        arguments,
        environment: <String, String>{
          'HOME': tempDir.path,
          'XDG_CONFIG_HOME': tempDir.path,
        },
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
    }

    Future<ProcessResult> run(List<String> arguments) =>
        runAt(executable, arguments);

    // A throwaway installation for the tests that let the installer loose on
    // one. Both self-install flags act on the directory the running executable
    // resolves to, so aiming either at the artifact itself would overwrite the
    // build under test with the last released one, or delete it before the
    // workflow uploads it. Named the way the installer resolves its target, so
    // that it acts on this file instead of installing a second one beside it.
    File installCopy() {
      // Deliberately not under the per-test temporary directory, which is
      // deleted the moment the test ends. This copy is executed, and deleting
      // an executable straight after the process using it exited is the same
      // source of flakiness setUpAll avoids above, so its directory is removed
      // best-effort instead of taking the test down with it.
      final Directory directory = Directory.systemTemp.createTempSync(
        'primal_binary_install_',
      );

      addTearDown(() {
        try {
          if (directory.existsSync()) {
            directory.deleteSync(recursive: true);
          }
        } on FileSystemException {
          // A temporary directory the operating system is still holding open,
          // left for it to reap.
        }
      });

      final File copy = File(
        path_lib.join(
          directory.path,
          Platform.isWindows ? 'primal.exe' : 'primal',
        ),
      );

      // copySync carries the executable bit across with the file, so there is
      // nothing left for the caller to chmod.
      binary.copySync(copy.path);

      return copy;
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

    // The self-install flags below are the only part of the CLI that cannot be
    // covered under 'dart run' at all: runSelfInstall refuses to aim the
    // installer at the Dart SDK's own bin directory, so self_install_test.dart
    // can only reach them with the real download and the real shell replaced by
    // fakes. A compiled binary is the one place the whole path runs.

    test('--update rejects being combined with another argument', () async {
      final ProcessResult result = await run(<String>['--update', 'extra']);

      expect(result.exitCode, equals(2));
      expect(
        result.stderr.toString(),
        contains('--update cannot be combined with other arguments'),
      );
    });

    test('--uninstall rejects being combined with another argument', () async {
      final ProcessResult result = await run(<String>['--uninstall', 'extra']);

      expect(result.exitCode, equals(2));
      expect(
        result.stderr.toString(),
        contains('--uninstall cannot be combined with other arguments'),
      );
    });

    // Fetches the installer, asks GitHub for the current release and downloads
    // it, so it is given far longer than the suite default.
    test(
      '--update brings the installation up to the released version',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        final File installed = installCopy();

        final ProcessResult result = await runAt(installed.path, <String>[
          '--update',
        ]);

        // The installer prints through the inherited stdio of the process that
        // started it, so its rail is what ends up here to explain a failure.
        final String output =
            result.stdout.toString() + result.stderr.toString();

        expect(result.exitCode, equals(0), reason: output);
        // Asserted rather than taking the exit code for the whole story: the
        // installer resolves the release before it decides what to do, so a
        // lookup that never happened would otherwise pass as an update.
        expect(output, contains('Latest release'), reason: output);
        // Which of the two it lands on is the version this binary was built
        // from against the one currently published, and both are correct. A
        // release branch is ahead of the published release and downloads it; a
        // binary built from a released version has nothing to do. Naming both
        // is what keeps a run that quietly did neither from passing.
        expect(
          output,
          anyOf(contains('Already up to date'), contains('updated in')),
          reason: output,
        );

        // Left running is the contract that holds either way, so it is checked
        // rather than which version answers.
        final ProcessResult updated = await runAt(installed.path, <String>[
          '--version',
        ]);

        expect(updated.exitCode, equals(0), reason: updated.stderr.toString());
        expect(
          updated.stdout.toString().trim(),
          matches(RegExp(r'^\d+\.\d+\.\d+')),
        );
      },
    );

    // Declared last: it is the one test here that destroys the installation it
    // was given. That installation is a copy, so the artifact under test
    // survives it and nothing below would be affected either way, but the order
    // says what the test does without having to read it.
    test(
      '--uninstall removes the installation it was run from',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        final File installed = installCopy();

        final ProcessResult result = await runAt(installed.path, <String>[
          '--uninstall',
        ]);

        final String output =
            result.stdout.toString() + result.stderr.toString();

        expect(result.exitCode, equals(0), reason: output);
        // Only that the uninstall path ran to its end rather than stopping
        // somewhere in the middle: the installer closes with this line whether
        // or not it found anything to remove, so it says nothing about the
        // removal itself.
        expect(output, contains('Primal SDK uninstalled'), reason: output);
        // Which is what the removal is read from. The file was put there by
        // installCopy moments earlier, so it going missing is the installer
        // having taken it.
        expect(installed.existsSync(), isFalse, reason: output);
      },
    );
  });
}

/// Environment variable naming the binary to test.
const String binaryVariable = 'PRIMAL_BINARY';
