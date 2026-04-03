@Tags(['unit'])
@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/platform/console/platform_console_web.dart';
import 'package:primal/compiler/platform/directory/platform_directory_web.dart';
import 'package:primal/compiler/platform/environment/platform_environment_web.dart';
import 'package:primal/compiler/platform/file/platform_file_web.dart';
import 'package:test/test.dart';

List<String> capturePrints(void Function() action) {
  final List<String> prints = <String>[];

  runZoned(
    action,
    zoneSpecification: ZoneSpecification(
      print: (_, __, ___, String line) {
        prints.add(line);
      },
    ),
  );

  return prints;
}

void main() {
  group('PlatformConsoleWeb', () {
    late PlatformConsoleWeb console;

    setUp(() => console = PlatformConsoleWeb());

    test('readLine throws UnimplementedFunctionWebError', () {
      expect(
        () => console.readLine(),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('console.read'),
          ),
        ),
      );
    });

    test('outWrite delegates to print', () {
      final List<String> prints = capturePrints(() => console.outWrite('test'));

      expect(prints, equals(['test']));
    });

    test('outWriteLn delegates to print', () {
      final List<String> prints = capturePrints(
        () => console.outWriteLn('test'),
      );

      expect(prints, equals(['test']));
    });

    test('errorWrite delegates to print', () {
      final List<String> prints = capturePrints(
        () => console.errorWrite('test'),
      );

      expect(prints, equals(['test']));
    });

    test('errorWriteLn delegates to print', () {
      final List<String> prints = capturePrints(
        () => console.errorWriteLn('test'),
      );

      expect(prints, equals(['test']));
    });
  });

  group('PlatformFileWeb', () {
    late PlatformFileWeb platform;

    setUp(() => platform = PlatformFileWeb());

    test('fromPath throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.fromPath('test'),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.fromPath'),
          ),
        ),
      );
    });

    test('exists throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.exists(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.exists'),
          ),
        ),
      );
    });

    test('read throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.read(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.read'),
          ),
        ),
      );
    });

    test('write throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.write(File('dummy'), 'content'),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.write'),
          ),
        ),
      );
    });

    test('length throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.length(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.length'),
          ),
        ),
      );
    });

    test('create throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.create(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.create'),
          ),
        ),
      );
    });

    test('delete throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.delete(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.delete'),
          ),
        ),
      );
    });

    test('path throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.path(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.path'),
          ),
        ),
      );
    });

    test('name throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.name(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.name'),
          ),
        ),
      );
    });

    test('rename throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.rename(File('dummy'), 'new'),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.rename'),
          ),
        ),
      );
    });

    test('extension throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.extension(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.extension'),
          ),
        ),
      );
    });

    test('copy throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.copy(File('a'), File('b')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.copy'),
          ),
        ),
      );
    });

    test('move throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.move(File('a'), File('b')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.move'),
          ),
        ),
      );
    });

    test('parent throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.parent(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('file.parent'),
          ),
        ),
      );
    });
  });

  group('PlatformDirectoryWeb', () {
    late PlatformDirectoryWeb platform;

    setUp(() => platform = PlatformDirectoryWeb());

    test('fromPath throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.fromPath('test'),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('directory.fromPath'),
          ),
        ),
      );
    });

    test('exists throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.exists(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('directory.exists'),
          ),
        ),
      );
    });

    test('create throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.create(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('directory.create'),
          ),
        ),
      );
    });

    test('delete throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.delete(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('directory.delete'),
          ),
        ),
      );
    });

    test('copy throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.copy(Directory('a'), Directory('b')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('directory.copy'),
          ),
        ),
      );
    });

    test('move throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.move(Directory('a'), Directory('b')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('directory.move'),
          ),
        ),
      );
    });

    test('rename throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.rename(Directory('dummy'), 'new'),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('directory.rename'),
          ),
        ),
      );
    });

    test('path throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.path(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('directory.path'),
          ),
        ),
      );
    });

    test('name throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.name(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('directory.name'),
          ),
        ),
      );
    });

    test('parent throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.parent(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('directory.parent'),
          ),
        ),
      );
    });

    test('list throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.list(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('directory.list'),
          ),
        ),
      );
    });
  });

  group('PlatformEnvironmentWeb', () {
    late PlatformEnvironmentWeb platform;

    setUp(() => platform = PlatformEnvironmentWeb());

    test('getVariable throws UnimplementedFunctionWebError', () {
      expect(
        () => platform.getVariable('HOME'),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('env.get'),
          ),
        ),
      );
    });
  });
}
