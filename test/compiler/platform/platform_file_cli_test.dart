@Tags(['unit'])
@TestOn('vm')
library;

import 'dart:io';
import 'package:primal/compiler/platform/file/platform_file_cli.dart';
import 'package:test/test.dart';

void main() {
  late PlatformFileCli platform;
  late Directory tempDir;

  setUp(() {
    platform = PlatformFileCli();
    tempDir = Directory.systemTemp.createTempSync('primal_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PlatformFileCli', () {
    test('fromPath creates a File object', () {
      final File file = platform.fromPath('${tempDir.path}/test.txt');

      expect(file, isA<File>());
      expect(file.path, equals('${tempDir.path}/test.txt'));
    });

    test('create creates a file', () {
      final File file = File('${tempDir.path}/created.txt');

      expect(platform.create(file), isTrue);
      expect(file.existsSync(), isTrue);
    });

    test('exists returns false for nonexistent file', () {
      final File file = File('${tempDir.path}/nope.txt');

      expect(platform.exists(file), isFalse);
    });

    test('exists returns true for existing file', () {
      final File file = File('${tempDir.path}/yes.txt')..createSync();

      expect(platform.exists(file), isTrue);
    });

    test('write creates file and writes content', () {
      final File file = File('${tempDir.path}/write.txt');

      expect(platform.write(file, 'hello'), isTrue);
      expect(file.readAsStringSync(), equals('hello'));
    });

    test('read returns file content', () {
      final File file = File('${tempDir.path}/read.txt')
        ..writeAsStringSync('content');

      expect(platform.read(file), equals('content'));
    });

    test('length returns file size', () {
      final File file = File('${tempDir.path}/size.txt')
        ..writeAsStringSync('12345');

      expect(platform.length(file), equals(5));
    });

    test('delete removes a file', () {
      final File file = File('${tempDir.path}/del.txt')..createSync();

      expect(platform.delete(file), isTrue);
      expect(file.existsSync(), isFalse);
    });

    test('delete returns false for nonexistent file', () {
      final File file = File('${tempDir.path}/nope.txt');

      expect(platform.delete(file), isFalse);
    });

    test('path returns absolute path', () {
      final File file = File('${tempDir.path}/abs.txt')..createSync();

      expect(platform.path(file), contains(tempDir.path));
    });

    test('name returns filename', () {
      final File file = File('${tempDir.path}/myfile.txt');

      expect(platform.name(file), equals('myfile.txt'));
    });

    test('extension returns file extension without dot', () {
      final File file = File('${tempDir.path}/test.prm');

      expect(platform.extension(file), equals('prm'));
    });

    test('extension returns empty string for no extension', () {
      final File file = File('${tempDir.path}/noext');

      expect(platform.extension(file), equals(''));
    });

    test('rename renames a file', () {
      final File file = File('${tempDir.path}/old.txt')..createSync();

      expect(platform.rename(file, 'new.txt'), isTrue);
      expect(File('${tempDir.path}/new.txt').existsSync(), isTrue);
      expect(file.existsSync(), isFalse);
    });

    test('copy copies a file', () {
      final File source = File('${tempDir.path}/src.txt')
        ..writeAsStringSync('data');
      final File destination = File('${tempDir.path}/dst.txt');

      expect(platform.copy(source, destination), isTrue);
      expect(destination.readAsStringSync(), equals('data'));
      expect(source.existsSync(), isTrue);
    });

    test('move moves a file', () {
      final File source = File('${tempDir.path}/mv_src.txt')
        ..writeAsStringSync('data');
      final File destination = File('${tempDir.path}/mv_dst.txt');

      expect(platform.move(source, destination), isTrue);
      expect(destination.readAsStringSync(), equals('data'));
      expect(source.existsSync(), isFalse);
    });

    test('parent returns parent directory', () {
      final File file = File('${tempDir.path}/child.txt');

      expect(platform.parent(file).path, equals(tempDir.path));
    });
  });
}
