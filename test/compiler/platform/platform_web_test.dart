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

    test('readLine throws RuntimeError', () {
      expect(
        () => console.readLine(),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('outWrite delegates to print', () {
      final List<String> prints = capturePrints(() => console.outWrite('test'));

      expect(prints, equals(['test']));
    });

    test('outWrite handles empty string', () {
      final List<String> prints = capturePrints(() => console.outWrite(''));

      expect(prints, equals(['']));
    });

    test('outWrite handles multiline string', () {
      final List<String> prints = capturePrints(
        () => console.outWrite('line1\nline2'),
      );

      expect(prints, equals(['line1\nline2']));
    });

    test('outWriteLn delegates to print', () {
      final List<String> prints = capturePrints(
        () => console.outWriteLn('test'),
      );

      expect(prints, equals(['test']));
    });

    test('outWriteLn handles empty string', () {
      final List<String> prints = capturePrints(() => console.outWriteLn(''));

      expect(prints, equals(['']));
    });

    test('outWriteLn handles multiline string', () {
      final List<String> prints = capturePrints(
        () => console.outWriteLn('line1\nline2'),
      );

      expect(prints, equals(['line1\nline2']));
    });

    test('outWrite handles special characters', () {
      final List<String> prints = capturePrints(
        () => console.outWrite('tab\there\u0000null'),
      );

      expect(prints, equals(['tab\there\u0000null']));
    });

    test('outWrite handles unicode characters', () {
      final List<String> prints = capturePrints(
        () => console.outWrite('\u{1F600} emoji \u{2603} snowman'),
      );

      expect(prints, equals(['\u{1F600} emoji \u{2603} snowman']));
    });

    test('outWrite handles single character', () {
      final List<String> prints = capturePrints(() => console.outWrite('x'));

      expect(prints, equals(['x']));
    });

    test('outWriteLn handles special characters', () {
      final List<String> prints = capturePrints(
        () => console.outWriteLn('tab\there\u0000null'),
      );

      expect(prints, equals(['tab\there\u0000null']));
    });

    test('outWriteLn handles unicode characters', () {
      final List<String> prints = capturePrints(
        () => console.outWriteLn('\u{1F600} emoji \u{2603} snowman'),
      );

      expect(prints, equals(['\u{1F600} emoji \u{2603} snowman']));
    });

    test('outWriteLn handles single character', () {
      final List<String> prints = capturePrints(() => console.outWriteLn('a'));

      expect(prints, equals(['a']));
    });

    test('errorWrite delegates to print', () {
      final List<String> prints = capturePrints(
        () => console.errorWrite('test'),
      );

      expect(prints, equals(['test']));
    });

    test('errorWrite handles empty string', () {
      final List<String> prints = capturePrints(() => console.errorWrite(''));

      expect(prints, equals(['']));
    });

    test('errorWrite handles multiline string', () {
      final List<String> prints = capturePrints(
        () => console.errorWrite('line1\nline2'),
      );

      expect(prints, equals(['line1\nline2']));
    });

    test('errorWriteLn delegates to print', () {
      final List<String> prints = capturePrints(
        () => console.errorWriteLn('test'),
      );

      expect(prints, equals(['test']));
    });

    test('errorWriteLn handles empty string', () {
      final List<String> prints = capturePrints(() => console.errorWriteLn(''));

      expect(prints, equals(['']));
    });

    test('errorWriteLn handles multiline string', () {
      final List<String> prints = capturePrints(
        () => console.errorWriteLn('line1\nline2'),
      );

      expect(prints, equals(['line1\nline2']));
    });

    test('errorWrite handles special characters', () {
      final List<String> prints = capturePrints(
        () => console.errorWrite('tab\there\u0000null'),
      );

      expect(prints, equals(['tab\there\u0000null']));
    });

    test('errorWrite handles unicode characters', () {
      final List<String> prints = capturePrints(
        () => console.errorWrite('\u{1F600} emoji \u{2603} snowman'),
      );

      expect(prints, equals(['\u{1F600} emoji \u{2603} snowman']));
    });

    test('errorWrite handles single character', () {
      final List<String> prints = capturePrints(() => console.errorWrite('y'));

      expect(prints, equals(['y']));
    });

    test('errorWriteLn handles special characters', () {
      final List<String> prints = capturePrints(
        () => console.errorWriteLn('tab\there\u0000null'),
      );

      expect(prints, equals(['tab\there\u0000null']));
    });

    test('errorWriteLn handles unicode characters', () {
      final List<String> prints = capturePrints(
        () => console.errorWriteLn('\u{1F600} emoji \u{2603} snowman'),
      );

      expect(prints, equals(['\u{1F600} emoji \u{2603} snowman']));
    });

    test('errorWriteLn handles single character', () {
      final List<String> prints = capturePrints(
        () => console.errorWriteLn('z'),
      );

      expect(prints, equals(['z']));
    });

    test('outWrite handles very long string', () {
      final String longString = 'a' * 10000;
      final List<String> prints = capturePrints(
        () => console.outWrite(longString),
      );

      expect(prints, equals([longString]));
    });

    test('outWriteLn handles very long string', () {
      final String longString = 'b' * 10000;
      final List<String> prints = capturePrints(
        () => console.outWriteLn(longString),
      );

      expect(prints, equals([longString]));
    });

    test('errorWrite handles very long string', () {
      final String longString = 'c' * 10000;
      final List<String> prints = capturePrints(
        () => console.errorWrite(longString),
      );

      expect(prints, equals([longString]));
    });

    test('errorWriteLn handles very long string', () {
      final String longString = 'd' * 10000;
      final List<String> prints = capturePrints(
        () => console.errorWriteLn(longString),
      );

      expect(prints, equals([longString]));
    });

    test('outWrite handles whitespace-only string', () {
      final List<String> prints = capturePrints(
        () => console.outWrite('   \t\n   '),
      );

      expect(prints, equals(['   \t\n   ']));
    });

    test('outWriteLn handles whitespace-only string', () {
      final List<String> prints = capturePrints(
        () => console.outWriteLn('   \t\n   '),
      );

      expect(prints, equals(['   \t\n   ']));
    });

    test('errorWrite handles whitespace-only string', () {
      final List<String> prints = capturePrints(
        () => console.errorWrite('   \t\n   '),
      );

      expect(prints, equals(['   \t\n   ']));
    });

    test('errorWriteLn handles whitespace-only string', () {
      final List<String> prints = capturePrints(
        () => console.errorWriteLn('   \t\n   '),
      );

      expect(prints, equals(['   \t\n   ']));
    });

    test('multiple consecutive outWrite calls', () {
      final List<String> prints = capturePrints(() {
        console.outWrite('first');
        console.outWrite('second');
        console.outWrite('third');
      });

      expect(prints, equals(['first', 'second', 'third']));
    });

    test('multiple consecutive outWriteLn calls', () {
      final List<String> prints = capturePrints(() {
        console.outWriteLn('first');
        console.outWriteLn('second');
        console.outWriteLn('third');
      });

      expect(prints, equals(['first', 'second', 'third']));
    });

    test('multiple consecutive errorWrite calls', () {
      final List<String> prints = capturePrints(() {
        console.errorWrite('first');
        console.errorWrite('second');
        console.errorWrite('third');
      });

      expect(prints, equals(['first', 'second', 'third']));
    });

    test('multiple consecutive errorWriteLn calls', () {
      final List<String> prints = capturePrints(() {
        console.errorWriteLn('first');
        console.errorWriteLn('second');
        console.errorWriteLn('third');
      });

      expect(prints, equals(['first', 'second', 'third']));
    });

    test('mixed outWrite and errorWrite calls', () {
      final List<String> prints = capturePrints(() {
        console.outWrite('out1');
        console.errorWrite('err1');
        console.outWriteLn('out2');
        console.errorWriteLn('err2');
      });

      expect(prints, equals(['out1', 'err1', 'out2', 'err2']));
    });

    test('outWrite handles string with carriage return', () {
      final List<String> prints = capturePrints(
        () => console.outWrite('line1\rline2'),
      );

      expect(prints, equals(['line1\rline2']));
    });

    test('outWriteLn handles string with carriage return', () {
      final List<String> prints = capturePrints(
        () => console.outWriteLn('line1\rline2'),
      );

      expect(prints, equals(['line1\rline2']));
    });

    test('errorWrite handles string with carriage return', () {
      final List<String> prints = capturePrints(
        () => console.errorWrite('line1\rline2'),
      );

      expect(prints, equals(['line1\rline2']));
    });

    test('errorWriteLn handles string with carriage return', () {
      final List<String> prints = capturePrints(
        () => console.errorWriteLn('line1\rline2'),
      );

      expect(prints, equals(['line1\rline2']));
    });

    test('outWrite handles string with only newlines', () {
      final List<String> prints = capturePrints(
        () => console.outWrite('\n\n\n'),
      );

      expect(prints, equals(['\n\n\n']));
    });

    test('errorWrite handles string with only newlines', () {
      final List<String> prints = capturePrints(
        () => console.errorWrite('\n\n\n'),
      );

      expect(prints, equals(['\n\n\n']));
    });

    test('readLine error contains correct function name', () {
      expect(
        () => console.readLine(),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"console.read"'),
          ),
        ),
      );
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

    test('fromPath throws RuntimeError', () {
      expect(
        () => platform.fromPath('test'),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('fromPath throws with empty path', () {
      expect(
        () => platform.fromPath(''),
        throwsA(isA<UnimplementedFunctionWebError>()),
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

    test('write throws with empty content', () {
      expect(
        () => platform.write(File('dummy'), ''),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('rename throws with empty name', () {
      expect(
        () => platform.rename(File('dummy'), ''),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('fromPath throws with whitespace-only path', () {
      expect(
        () => platform.fromPath('   '),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('fromPath throws with path containing special characters', () {
      expect(
        () => platform.fromPath('/path/with spaces/and\ttabs'),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('exists throws RuntimeError', () {
      expect(
        () => platform.exists(File('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('read throws RuntimeError', () {
      expect(
        () => platform.read(File('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('write throws RuntimeError', () {
      expect(
        () => platform.write(File('dummy'), 'content'),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('length throws RuntimeError', () {
      expect(
        () => platform.length(File('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('create throws RuntimeError', () {
      expect(
        () => platform.create(File('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('delete throws RuntimeError', () {
      expect(
        () => platform.delete(File('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('path throws RuntimeError', () {
      expect(
        () => platform.path(File('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('name throws RuntimeError', () {
      expect(
        () => platform.name(File('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('rename throws RuntimeError', () {
      expect(
        () => platform.rename(File('dummy'), 'new'),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('extension throws RuntimeError', () {
      expect(
        () => platform.extension(File('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('copy throws RuntimeError', () {
      expect(
        () => platform.copy(File('a'), File('b')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('move throws RuntimeError', () {
      expect(
        () => platform.move(File('a'), File('b')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('parent throws RuntimeError', () {
      expect(
        () => platform.parent(File('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('fromPath throws with very long path', () {
      final String longPath = '/very/long/path/${'a' * 10000}';
      expect(
        () => platform.fromPath(longPath),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('fromPath throws with unicode path', () {
      expect(
        () => platform.fromPath('/path/\u{1F600}/file.txt'),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('write throws with very long content', () {
      final String longContent = 'content' * 10000;
      expect(
        () => platform.write(File('dummy'), longContent),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('rename throws with unicode name', () {
      expect(
        () => platform.rename(File('dummy'), '\u{1F600}_file.txt'),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('fromPath error contains exact function name', () {
      expect(
        () => platform.fromPath('test'),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.fromPath"'),
          ),
        ),
      );
    });

    test('exists error contains exact function name', () {
      expect(
        () => platform.exists(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.exists"'),
          ),
        ),
      );
    });

    test('read error contains exact function name', () {
      expect(
        () => platform.read(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.read"'),
          ),
        ),
      );
    });

    test('write error contains exact function name', () {
      expect(
        () => platform.write(File('dummy'), 'content'),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.write"'),
          ),
        ),
      );
    });

    test('length error contains exact function name', () {
      expect(
        () => platform.length(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.length"'),
          ),
        ),
      );
    });

    test('create error contains exact function name', () {
      expect(
        () => platform.create(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.create"'),
          ),
        ),
      );
    });

    test('delete error contains exact function name', () {
      expect(
        () => platform.delete(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.delete"'),
          ),
        ),
      );
    });

    test('path error contains exact function name', () {
      expect(
        () => platform.path(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.path"'),
          ),
        ),
      );
    });

    test('name error contains exact function name', () {
      expect(
        () => platform.name(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.name"'),
          ),
        ),
      );
    });

    test('rename error contains exact function name', () {
      expect(
        () => platform.rename(File('dummy'), 'new'),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.rename"'),
          ),
        ),
      );
    });

    test('extension error contains exact function name', () {
      expect(
        () => platform.extension(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.extension"'),
          ),
        ),
      );
    });

    test('copy error contains exact function name', () {
      expect(
        () => platform.copy(File('a'), File('b')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.copy"'),
          ),
        ),
      );
    });

    test('move error contains exact function name', () {
      expect(
        () => platform.move(File('a'), File('b')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.move"'),
          ),
        ),
      );
    });

    test('parent error contains exact function name', () {
      expect(
        () => platform.parent(File('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"file.parent"'),
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

    test('fromPath throws RuntimeError', () {
      expect(
        () => platform.fromPath('test'),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('fromPath throws with empty path', () {
      expect(
        () => platform.fromPath(''),
        throwsA(isA<UnimplementedFunctionWebError>()),
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

    test('rename throws with empty name', () {
      expect(
        () => platform.rename(Directory('dummy'), ''),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('fromPath throws with whitespace-only path', () {
      expect(
        () => platform.fromPath('   '),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('fromPath throws with path containing special characters', () {
      expect(
        () => platform.fromPath('/path/with spaces/and\ttabs'),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('exists throws RuntimeError', () {
      expect(
        () => platform.exists(Directory('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('create throws RuntimeError', () {
      expect(
        () => platform.create(Directory('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('delete throws RuntimeError', () {
      expect(
        () => platform.delete(Directory('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('copy throws RuntimeError', () {
      expect(
        () => platform.copy(Directory('a'), Directory('b')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('move throws RuntimeError', () {
      expect(
        () => platform.move(Directory('a'), Directory('b')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('rename throws RuntimeError', () {
      expect(
        () => platform.rename(Directory('dummy'), 'new'),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('path throws RuntimeError', () {
      expect(
        () => platform.path(Directory('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('name throws RuntimeError', () {
      expect(
        () => platform.name(Directory('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('parent throws RuntimeError', () {
      expect(
        () => platform.parent(Directory('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('list throws RuntimeError', () {
      expect(
        () => platform.list(Directory('dummy')),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('fromPath throws with very long path', () {
      final String longPath = '/very/long/path/${'a' * 10000}';
      expect(
        () => platform.fromPath(longPath),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('fromPath throws with unicode path', () {
      expect(
        () => platform.fromPath('/path/\u{1F600}/directory'),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('rename throws with unicode name', () {
      expect(
        () => platform.rename(Directory('dummy'), '\u{1F600}_directory'),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('fromPath error contains exact function name', () {
      expect(
        () => platform.fromPath('test'),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"directory.fromPath"'),
          ),
        ),
      );
    });

    test('exists error contains exact function name', () {
      expect(
        () => platform.exists(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"directory.exists"'),
          ),
        ),
      );
    });

    test('create error contains exact function name', () {
      expect(
        () => platform.create(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"directory.create"'),
          ),
        ),
      );
    });

    test('delete error contains exact function name', () {
      expect(
        () => platform.delete(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"directory.delete"'),
          ),
        ),
      );
    });

    test('copy error contains exact function name', () {
      expect(
        () => platform.copy(Directory('a'), Directory('b')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"directory.copy"'),
          ),
        ),
      );
    });

    test('move error contains exact function name', () {
      expect(
        () => platform.move(Directory('a'), Directory('b')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"directory.move"'),
          ),
        ),
      );
    });

    test('rename error contains exact function name', () {
      expect(
        () => platform.rename(Directory('dummy'), 'new'),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"directory.rename"'),
          ),
        ),
      );
    });

    test('path error contains exact function name', () {
      expect(
        () => platform.path(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"directory.path"'),
          ),
        ),
      );
    });

    test('name error contains exact function name', () {
      expect(
        () => platform.name(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"directory.name"'),
          ),
        ),
      );
    });

    test('parent error contains exact function name', () {
      expect(
        () => platform.parent(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"directory.parent"'),
          ),
        ),
      );
    });

    test('list error contains exact function name', () {
      expect(
        () => platform.list(Directory('dummy')),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"directory.list"'),
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

    test('getVariable throws RuntimeError', () {
      expect(
        () => platform.getVariable('HOME'),
        throwsA(isA<RuntimeError>()),
      );
    });

    test('getVariable throws with empty variable name', () {
      expect(
        () => platform.getVariable(''),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('getVariable throws with whitespace-only variable name', () {
      expect(
        () => platform.getVariable('   '),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('getVariable throws with special characters in variable name', () {
      expect(
        () => platform.getVariable('VAR_WITH-SPECIAL.CHARS'),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('getVariable throws with unicode variable name', () {
      expect(
        () => platform.getVariable('\u{1F600}_EMOJI_VAR'),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('getVariable throws with very long variable name', () {
      final String longName = 'VARIABLE_${'A' * 10000}';
      expect(
        () => platform.getVariable(longName),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('getVariable throws with numeric-only variable name', () {
      expect(
        () => platform.getVariable('12345'),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('getVariable throws with single character variable name', () {
      expect(
        () => platform.getVariable('X'),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('getVariable error contains exact function name', () {
      expect(
        () => platform.getVariable('HOME'),
        throwsA(
          isA<UnimplementedFunctionWebError>().having(
            (e) => e.toString(),
            'message',
            contains('"env.get"'),
          ),
        ),
      );
    });

    test('getVariable throws with variable name containing equals sign', () {
      expect(
        () => platform.getVariable('VAR=VALUE'),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });

    test('getVariable throws with newline in variable name', () {
      expect(
        () => platform.getVariable('VAR\nNAME'),
        throwsA(isA<UnimplementedFunctionWebError>()),
      );
    });
  });

  group('UnimplementedFunctionWebError', () {
    test('error message contains function name', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'test.function',
      );

      expect(error.toString(), contains('test.function'));
    });

    test('error message indicates web platform', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'test.function',
      );

      expect(error.toString(), contains('web platform'));
    });

    test('error message indicates not implemented', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'test.function',
      );

      expect(error.toString(), contains('not implemented'));
    });

    test('error is a RuntimeError', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'test.function',
      );

      expect(error, isA<RuntimeError>());
    });

    test('error with empty function name', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        '',
      );

      expect(error.toString(), contains('""'));
    });

    test('error with special characters in function name', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'module.function-name',
      );

      expect(error.toString(), contains('module.function-name'));
    });

    test('error with whitespace in function name', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'function with spaces',
      );

      expect(error.toString(), contains('function with spaces'));
    });

    test('error message has expected format', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'test.function',
      );

      expect(
        error.toString(),
        equals(
          'Runtime error: Function "test.function" is not implemented on the web platform',
        ),
      );
    });

    test('error preserves function name exactly', () {
      const String functionName = 'exact.function.name';
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        functionName,
      );

      expect(error.toString(), contains('"$functionName"'));
    });

    test('error with unicode function name', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        '\u{1F600}.emoji.function',
      );

      expect(error.toString(), contains('\u{1F600}.emoji.function'));
    });

    test('error with very long function name', () {
      final String longFunctionName = 'module.${'a' * 1000}.function';
      final UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        longFunctionName,
      );

      expect(error.toString(), contains(longFunctionName));
    });

    test('error with numeric function name', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        '12345.67890',
      );

      expect(error.toString(), contains('12345.67890'));
    });

    test('error with null-like string function name', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'null',
      );

      expect(error.toString(), contains('"null"'));
    });

    test('error with undefined-like string function name', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'undefined',
      );

      expect(error.toString(), contains('"undefined"'));
    });

    test('error with newline in function name', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'function\nname',
      );

      expect(error.toString(), contains('function\nname'));
    });

    test('error with tab in function name', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'function\tname',
      );

      expect(error.toString(), contains('function\tname'));
    });

    test('multiple errors have independent messages', () {
      const UnimplementedFunctionWebError error1 =
          UnimplementedFunctionWebError(
            'first.function',
          );
      const UnimplementedFunctionWebError error2 =
          UnimplementedFunctionWebError(
            'second.function',
          );

      expect(error1.toString(), isNot(equals(error2.toString())));
      expect(error1.toString(), contains('first.function'));
      expect(error2.toString(), contains('second.function'));
    });

    test('error with single character function name', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'f',
      );

      expect(error.toString(), contains('"f"'));
    });

    test('error with dots only function name', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        '...',
      );

      expect(error.toString(), contains('"..."'));
    });

    test('error extends RuntimeError correctly', () {
      const UnimplementedFunctionWebError error = UnimplementedFunctionWebError(
        'test.function',
      );

      expect(error, isA<RuntimeError>());
      expect(error.toString(), startsWith('Runtime error:'));
    });
  });
}
