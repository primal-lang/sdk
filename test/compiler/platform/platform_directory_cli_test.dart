@Tags(['unit'])
@TestOn('vm')
library;

import 'dart:io';
import 'package:primal/compiler/platform/directory/platform_directory_cli.dart';
import 'package:test/test.dart';

void main() {
  late PlatformDirectoryCli platform;
  late Directory tempDir;

  setUp(() {
    platform = PlatformDirectoryCli();
    tempDir = Directory.systemTemp.createTempSync('primal_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PlatformDirectoryCli', () {
    test('fromPath creates a Directory object', () {
      final dir = platform.fromPath(tempDir.path);

      expect(dir, isA<Directory>());
      expect(dir.path, equals(tempDir.path));
    });

    test('exists returns true for existing directory', () {
      expect(platform.exists(tempDir), isTrue);
    });

    test('exists returns false for nonexistent directory', () {
      final dir = Directory('${tempDir.path}/nope');

      expect(platform.exists(dir), isFalse);
    });

    test('create creates a directory', () {
      final dir = Directory('${tempDir.path}/newdir');

      expect(platform.create(dir), isTrue);
      expect(dir.existsSync(), isTrue);
    });

    test('create creates nested directories', () {
      final dir = Directory('${tempDir.path}/a/b/c');

      expect(platform.create(dir), isTrue);
      expect(dir.existsSync(), isTrue);
    });

    test('delete removes a directory', () {
      final dir = Directory('${tempDir.path}/todelete')..createSync();

      expect(platform.delete(dir), isTrue);
      expect(dir.existsSync(), isFalse);
    });

    test('delete returns false for nonexistent directory', () {
      final dir = Directory('${tempDir.path}/nope');

      expect(platform.delete(dir), isFalse);
    });

    test('path returns absolute path', () {
      expect(platform.path(tempDir), contains(tempDir.path));
    });

    test('name returns directory name', () {
      final dir = Directory('${tempDir.path}/mydir')..createSync();

      expect(platform.name(dir), equals('mydir'));
    });

    test('parent returns parent directory', () {
      final dir = Directory('${tempDir.path}/child')..createSync();

      expect(platform.parent(dir).path, equals(tempDir.path));
    });

    test('rename renames a directory', () {
      final dir = Directory('${tempDir.path}/old')..createSync();

      expect(platform.rename(dir, 'new'), isTrue);
      expect(Directory('${tempDir.path}/new').existsSync(), isTrue);
      expect(dir.existsSync(), isFalse);
    });

    test('list returns directory contents', () {
      File('${tempDir.path}/a.txt').createSync();
      File('${tempDir.path}/b.txt').createSync();

      final contents = platform.list(tempDir);

      expect(contents.length, equals(2));
    });

    test('copy copies directory with contents', () {
      final source = Directory('${tempDir.path}/src')..createSync();
      File('${source.path}/file.txt').writeAsStringSync('data');
      final dest = Directory('${tempDir.path}/dst');

      expect(platform.copy(source, dest), isTrue);
      expect(File('${dest.path}/file.txt').readAsStringSync(), equals('data'));
    });

    test('copy recursively copies subdirectories', () {
      final source = Directory('${tempDir.path}/src2')..createSync();
      final subDir = Directory('${source.path}/sub')..createSync();
      File('${subDir.path}/nested.txt').writeAsStringSync('nested');
      final dest = Directory('${tempDir.path}/dst2');

      expect(platform.copy(source, dest), isTrue);
      expect(
        File('${dest.path}/sub/nested.txt').readAsStringSync(),
        equals('nested'),
      );
    });

    test('move moves a directory', () {
      final source = Directory('${tempDir.path}/mv_src')..createSync();
      File('${source.path}/f.txt').createSync();
      final dest = Directory('${tempDir.path}/mv_dst');

      expect(platform.move(source, dest), isTrue);
      expect(dest.existsSync(), isTrue);
      expect(source.existsSync(), isFalse);
    });
  });
}
