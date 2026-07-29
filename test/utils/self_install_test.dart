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
  });
}
