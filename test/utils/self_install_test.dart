@Tags(['unit'])
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:primal/utils/console.dart';
import 'package:primal/utils/self_install.dart';
import 'package:test/test.dart';
import '../helpers/console_fakes.dart';

void main() {
  group('isSelfInstallRequest()', () {
    test('recognises --update', () {
      expect(isSelfInstallRequest(<String>['--update']), isTrue);
    });

    test('recognises --uninstall', () {
      expect(isSelfInstallRequest(<String>['--uninstall']), isTrue);
    });

    test('ignores an ordinary invocation', () {
      expect(isSelfInstallRequest(<String>[]), isFalse);
      expect(isSelfInstallRequest(<String>['program.prm']), isFalse);
      expect(isSelfInstallRequest(<String>['--watch', 'program.prm']), isFalse);
    });
  });

  group('runSelfInstall()', () {
    late FakePlatformConsole platformConsole;
    late Console console;
    late List<String> requestedUrls;
    late List<String> executables;
    late List<List<String>> argumentLists;

    setUp(() {
      platformConsole = FakePlatformConsole();
      console = Console(platformConsole);
      requestedUrls = <String>[];
      executables = <String>[];
      argumentLists = <List<String>>[];
    });

    Future<List<int>> download(String url) async {
      requestedUrls.add(url);

      return utf8.encode('#!/bin/bash\necho installer\n');
    }

    Future<int> Function(String, List<String>) recordCommand({int code = 0}) {
      return (String executable, List<String> arguments) async {
        executables.add(executable);
        argumentLists.add(arguments);

        return code;
      };
    }

    test('runs the installer against the executable directory', () async {
      final int code = await runSelfInstall(
        <String>['--update'],
        console: console,
        resolveExecutable: () => '/opt/primal/bin/primal',
        downloadScript: download,
        runCommand: recordCommand(),
      );

      expect(code, equals(0));
      expect(requestedUrls, equals(<String>[installerUrl]));
      expect(executables, equals(<String>['bash']));
      expect(argumentLists.single.first, endsWith('install.sh'));
      expect(
        argumentLists.single.sublist(1),
        equals(<String>['--install-dir', '/opt/primal/bin']),
      );
    });

    test('passes --uninstall through to the installer', () async {
      await runSelfInstall(
        <String>['--uninstall'],
        console: console,
        resolveExecutable: () => '/home/user/.local/bin/primal',
        downloadScript: download,
        runCommand: recordCommand(),
      );

      expect(
        argumentLists.single.sublist(1),
        equals(<String>[
          '--install-dir',
          '/home/user/.local/bin',
          '--uninstall',
        ]),
      );
    });

    test('returns the exit code of the installer', () async {
      final int code = await runSelfInstall(
        <String>['--update'],
        console: console,
        resolveExecutable: () => '/usr/local/bin/primal',
        downloadScript: download,
        runCommand: recordCommand(code: 7),
      );

      expect(code, equals(7));
    });

    test('hands the downloaded script to the shell', () async {
      String? contents;

      await runSelfInstall(
        <String>['--update'],
        console: console,
        resolveExecutable: () => '/usr/local/bin/primal',
        downloadScript: download,
        runCommand: (String executable, List<String> arguments) async {
          contents = File(arguments.first).readAsStringSync();

          return 0;
        },
      );

      expect(contents, contains('echo installer'));
    });

    test('removes the script once the installer has run', () async {
      late String scriptPath;

      await runSelfInstall(
        <String>['--update'],
        console: console,
        resolveExecutable: () => '/usr/local/bin/primal',
        downloadScript: download,
        runCommand: (String executable, List<String> arguments) async {
          scriptPath = arguments.first;

          return 0;
        },
      );

      expect(File(scriptPath).existsSync(), isFalse);
    });

    test('rejects being combined with another argument', () async {
      final int code = await runSelfInstall(
        <String>['--update', 'program.prm'],
        console: console,
        resolveExecutable: () => '/usr/local/bin/primal',
        downloadScript: download,
        runCommand: recordCommand(),
      );

      expect(code, equals(2));
      expect(requestedUrls, isEmpty);
      expect(executables, isEmpty);
      expect(
        platformConsole.errorLines.single,
        contains('--update cannot be combined with other arguments.'),
      );
    });

    test('refuses to run against the Dart VM', () async {
      final int code = await runSelfInstall(
        <String>['--update'],
        console: console,
        resolveExecutable: () => '/usr/lib/dart/bin/dart',
        downloadScript: download,
        runCommand: recordCommand(),
      );

      expect(code, equals(2));
      expect(requestedUrls, isEmpty);
      expect(executables, isEmpty);
      expect(platformConsole.errorLines.single, contains('dart run'));
    });

    test('reports a failed download without running anything', () async {
      final int code = await runSelfInstall(
        <String>['--update'],
        console: console,
        resolveExecutable: () => '/usr/local/bin/primal',
        downloadScript: (String url) async =>
            throw const SocketException('no route to host'),
        runCommand: recordCommand(),
      );

      expect(code, equals(1));
      expect(executables, isEmpty);
      expect(platformConsole.errorLines.single, contains(installerUrl));
    });

    test('reports a shell that cannot be started', () async {
      final int code = await runSelfInstall(
        <String>['--uninstall'],
        console: console,
        resolveExecutable: () => '/usr/local/bin/primal',
        downloadScript: download,
        runCommand: (String executable, List<String> arguments) async =>
            throw ProcessException(executable, arguments, 'not found', 2),
      );

      expect(code, equals(1));
      expect(platformConsole.errorLines.single, contains('bash'));
    });

    test('reports a temporary directory that cannot be created', () async {
      final int code = await runSelfInstall(
        <String>['--update'],
        console: console,
        resolveExecutable: () => '/usr/local/bin/primal',
        downloadScript: download,
        runCommand: recordCommand(),
        createWorkingDirectory: () =>
            throw const PathAccessException('/nope', OSError('denied', 13)),
      );

      // 1, not an escaped exception: an unhandled error here would exit 255
      // with a stack trace rather than the documented "could not run at all".
      expect(code, equals(1));
      expect(executables, isEmpty);
      expect(
        platformConsole.errorLines.single,
        contains('could not write the installer to a temporary file'),
      );
    });

    test('reports a script that cannot be written', () async {
      final Directory workingDirectory = Directory.systemTemp.createTempSync(
        'primal_installer_test_',
      );

      // The staged script cannot be written over a directory of the same name,
      // on any platform.
      Directory(
        '${workingDirectory.path}${Platform.pathSeparator}install.sh',
      ).createSync();

      try {
        final int code = await runSelfInstall(
          <String>['--update'],
          console: console,
          resolveExecutable: () => '/usr/local/bin/primal',
          downloadScript: download,
          runCommand: recordCommand(),
          createWorkingDirectory: () => workingDirectory,
        );

        expect(code, equals(1));
        expect(executables, isEmpty);
        // The staging message, not the shell one: the assertion has to say
        // which of the two clauses answered.
        expect(
          platformConsole.errorLines.single,
          contains('could not write the installer to a temporary file'),
        );
        // The cleanup still ran, on the failure path as much as on the happy
        // one.
        expect(workingDirectory.existsSync(), isFalse);
      } finally {
        if (workingDirectory.existsSync()) {
          workingDirectory.deleteSync(recursive: true);
        }
      }
    });
  });

  // Asserted on the function rather than through runSelfInstall(), because the
  // paths it is there to rewrite are only produced on Windows: a Windows
  // executable path handed to the fakes resolves its parent against the host's
  // separator and never reaches the shell as one.
  group('shellPath()', () {
    test('rewrites a Windows path to the form the shell reads', () {
      expect(
        shellPath(r'C:\Users\grego\AppData\Local\Temp\install.sh'),
        equals('/c/Users/grego/AppData/Local/Temp/install.sh'),
      );
    });

    test('lowercases the drive letter', () {
      expect(shellPath(r'D:\Tools\primal'), equals('/d/Tools/primal'));
    });

    test('rewrites a drive that is already separated by slashes', () {
      expect(
        shellPath('C:/Users/grego/.local/bin'),
        equals('/c/Users/grego/.local/bin'),
      );
    });

    test('leaves a POSIX path untouched', () {
      expect(
        shellPath('/opt/primal/bin/primal'),
        equals('/opt/primal/bin/primal'),
      );
      expect(
        shellPath('/home/user/.local/bin'),
        equals('/home/user/.local/bin'),
      );
    });
  });
}
