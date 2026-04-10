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
      final Directory directory = platform.fromPath(tempDir.path);

      expect(directory, isA<Directory>());
      expect(directory.path, equals(tempDir.path));
    });

    test('exists returns true for existing directory', () {
      expect(platform.exists(tempDir), isTrue);
    });

    test('exists returns false for nonexistent directory', () {
      final Directory directory = Directory('${tempDir.path}/nope');

      expect(platform.exists(directory), isFalse);
    });

    test('create creates a directory', () {
      final Directory directory = Directory('${tempDir.path}/newdir');

      expect(platform.create(directory), isTrue);
      expect(directory.existsSync(), isTrue);
    });

    test('create creates nested directories', () {
      final Directory directory = Directory('${tempDir.path}/a/b/c');

      expect(platform.create(directory), isTrue);
      expect(directory.existsSync(), isTrue);
    });

    test('delete removes a directory', () {
      final Directory directory = Directory('${tempDir.path}/todelete')
        ..createSync();

      expect(platform.delete(directory), isTrue);
      expect(directory.existsSync(), isFalse);
    });

    test('delete returns false for nonexistent directory', () {
      final Directory directory = Directory('${tempDir.path}/nope');

      expect(platform.delete(directory), isFalse);
    });

    test('path returns absolute path', () {
      expect(platform.path(tempDir), contains(tempDir.path));
    });

    test('name returns directory name', () {
      final Directory directory = Directory('${tempDir.path}/mydir')
        ..createSync();

      expect(platform.name(directory), equals('mydir'));
    });

    test('parent returns parent directory', () {
      final Directory directory = Directory('${tempDir.path}/child')
        ..createSync();

      expect(platform.parent(directory).path, equals(tempDir.path));
    });

    test('rename renames a directory', () {
      final Directory directory = Directory('${tempDir.path}/old')
        ..createSync();

      expect(platform.rename(directory, 'new'), isTrue);
      expect(Directory('${tempDir.path}/new').existsSync(), isTrue);
      expect(directory.existsSync(), isFalse);
    });

    test('list returns directory contents', () {
      File('${tempDir.path}/a.txt').createSync();
      File('${tempDir.path}/b.txt').createSync();

      final List<FileSystemEntity> contents = platform.list(tempDir);

      expect(contents.length, equals(2));
    });

    test('copy copies directory with contents', () {
      final Directory source = Directory('${tempDir.path}/src')..createSync();
      File('${source.path}/file.txt').writeAsStringSync('data');
      final Directory destination = Directory('${tempDir.path}/dst');

      expect(platform.copy(source, destination), isTrue);
      expect(
        File('${destination.path}/file.txt').readAsStringSync(),
        equals('data'),
      );
    });

    test('copy recursively copies subdirectories', () {
      final Directory source = Directory('${tempDir.path}/src2')..createSync();
      final Directory subDirectory = Directory('${source.path}/sub')
        ..createSync();
      File('${subDirectory.path}/nested.txt').writeAsStringSync('nested');
      final Directory destination = Directory('${tempDir.path}/dst2');

      expect(platform.copy(source, destination), isTrue);
      expect(
        File('${destination.path}/sub/nested.txt').readAsStringSync(),
        equals('nested'),
      );
    });

    test('copy copies empty directory', () {
      final Directory source = Directory('${tempDir.path}/empty_src')
        ..createSync();
      final Directory destination = Directory('${tempDir.path}/empty_dst');

      expect(platform.copy(source, destination), isTrue);
      expect(destination.existsSync(), isTrue);
      expect(destination.listSync(), isEmpty);
    });

    test('copy returns false for nonexistent source', () {
      final Directory source = Directory('${tempDir.path}/nonexistent_src');
      final Directory destination = Directory('${tempDir.path}/copy_dst');

      expect(platform.copy(source, destination), isFalse);
    });

    test('move moves a directory', () {
      final Directory source = Directory('${tempDir.path}/mv_src')
        ..createSync();
      File('${source.path}/f.txt').createSync();
      final Directory destination = Directory('${tempDir.path}/mv_dst');

      expect(platform.move(source, destination), isTrue);
      expect(destination.existsSync(), isTrue);
      expect(source.existsSync(), isFalse);
    });

    test('move returns false for nonexistent source', () {
      final Directory source = Directory('${tempDir.path}/nonexistent_mv');
      final Directory destination = Directory('${tempDir.path}/mv_dst_fail');

      expect(platform.move(source, destination), isFalse);
    });

    test('rename returns false for nonexistent directory', () {
      final Directory directory = Directory(
        '${tempDir.path}/nonexistent_rename',
      );

      expect(platform.rename(directory, 'newname'), isFalse);
    });

    test('delete removes directory with contents recursively', () {
      final Directory directory = Directory('${tempDir.path}/delete_recursive')
        ..createSync();
      final Directory subDirectory = Directory('${directory.path}/subdir')
        ..createSync();
      File('${directory.path}/file.txt').createSync();
      File('${subDirectory.path}/nested.txt').createSync();

      expect(platform.delete(directory), isTrue);
      expect(directory.existsSync(), isFalse);
    });

    test('list returns empty list for empty directory', () {
      final Directory emptyDirectory = Directory('${tempDir.path}/empty_list')
        ..createSync();

      final List<FileSystemEntity> contents = platform.list(emptyDirectory);

      expect(contents, isEmpty);
    });

    test('list returns files and subdirectories', () {
      final Directory directory = Directory('${tempDir.path}/mixed')
        ..createSync();
      File('${directory.path}/file.txt').createSync();
      Directory('${directory.path}/subdir').createSync();

      final List<FileSystemEntity> contents = platform.list(directory);

      expect(contents.length, equals(2));
      expect(contents.whereType<File>().length, equals(1));
      expect(contents.whereType<Directory>().length, equals(1));
    });

    test('path returns absolute path for relative directory', () {
      final Directory directory = Directory('.');

      final String result = platform.path(directory);

      expect(result, startsWith('/'));
    });

    test('name returns directory name for deeply nested path', () {
      final Directory directory = Directory('${tempDir.path}/a/b/c/deep')
        ..createSync(recursive: true);

      expect(platform.name(directory), equals('deep'));
    });

    test('parent returns correct parent for deeply nested directory', () {
      final Directory directory = Directory('${tempDir.path}/level1/level2')
        ..createSync(recursive: true);

      final Directory parentDirectory = platform.parent(directory);

      expect(parentDirectory.path, endsWith('level1'));
    });

    test('fromPath with empty string creates directory object', () {
      final Directory directory = platform.fromPath('');

      expect(directory, isA<Directory>());
      expect(directory.path, equals(''));
    });

    test('create returns true for already existing directory', () {
      final Directory directory = Directory('${tempDir.path}/already_exists')
        ..createSync();

      expect(platform.create(directory), isTrue);
      expect(directory.existsSync(), isTrue);
    });

    test('copy preserves file content across multiple files', () {
      final Directory source = Directory('${tempDir.path}/multi_src')
        ..createSync();
      File('${source.path}/a.txt').writeAsStringSync('content_a');
      File('${source.path}/b.txt').writeAsStringSync('content_b');
      final Directory destination = Directory('${tempDir.path}/multi_dst');

      expect(platform.copy(source, destination), isTrue);
      expect(
        File('${destination.path}/a.txt').readAsStringSync(),
        equals('content_a'),
      );
      expect(
        File('${destination.path}/b.txt').readAsStringSync(),
        equals('content_b'),
      );
    });

    test('move preserves file content', () {
      final Directory source = Directory('${tempDir.path}/mv_content_src')
        ..createSync();
      File('${source.path}/data.txt').writeAsStringSync('important_data');
      final Directory destination = Directory('${tempDir.path}/mv_content_dst');

      expect(platform.move(source, destination), isTrue);
      expect(
        File('${destination.path}/data.txt').readAsStringSync(),
        equals('important_data'),
      );
    });

    test('move moves empty directory', () {
      final Directory source = Directory('${tempDir.path}/mv_empty_src')
        ..createSync();
      final Directory destination = Directory('${tempDir.path}/mv_empty_dst');

      expect(platform.move(source, destination), isTrue);
      expect(destination.existsSync(), isTrue);
      expect(destination.listSync(), isEmpty);
      expect(source.existsSync(), isFalse);
    });

    test('list throws exception for nonexistent directory', () {
      final Directory nonexistent = Directory(
        '${tempDir.path}/nonexistent_list',
      );

      expect(
        () => platform.list(nonexistent),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('name returns correct name with special characters', () {
      final Directory directory = Directory(
        '${tempDir.path}/dir-with_special.chars',
      )..createSync();

      expect(platform.name(directory), equals('dir-with_special.chars'));
    });

    test('name returns correct name with spaces', () {
      final Directory directory = Directory('${tempDir.path}/dir with spaces')
        ..createSync();

      expect(platform.name(directory), equals('dir with spaces'));
    });

    test('rename with special characters in new name', () {
      final Directory directory = Directory('${tempDir.path}/original_name')
        ..createSync();

      expect(platform.rename(directory, 'new-name_with.special'), isTrue);
      expect(
        Directory('${tempDir.path}/new-name_with.special').existsSync(),
        isTrue,
      );
    });

    test('path returns absolute path for nonexistent directory', () {
      final Directory nonexistent = Directory('${tempDir.path}/does_not_exist');

      final String result = platform.path(nonexistent);

      expect(result, startsWith('/'));
      expect(result, contains('does_not_exist'));
    });

    test('parent of temp directory returns its parent', () {
      final Directory parentDirectory = platform.parent(tempDir);

      expect(parentDirectory.existsSync(), isTrue);
      expect(tempDir.path, startsWith(parentDirectory.path));
    });

    test('fromPath with path containing special characters', () {
      final String specialPath = '${tempDir.path}/path-with_special.chars';
      final Directory directory = platform.fromPath(specialPath);

      expect(directory, isA<Directory>());
      expect(directory.path, equals(specialPath));
    });

    test('fromPath with path containing spaces', () {
      final String pathWithSpaces = '${tempDir.path}/path with spaces';
      final Directory directory = platform.fromPath(pathWithSpaces);

      expect(directory, isA<Directory>());
      expect(directory.path, equals(pathWithSpaces));
    });

    test('copy deeply nested structure with multiple levels', () {
      final Directory source = Directory('${tempDir.path}/deep_src')
        ..createSync();
      final Directory level1 = Directory('${source.path}/level1')..createSync();
      final Directory level2 = Directory('${level1.path}/level2')..createSync();
      final Directory level3 = Directory('${level2.path}/level3')..createSync();
      File('${level3.path}/deep_file.txt').writeAsStringSync('deep_content');
      File(
        '${level1.path}/level1_file.txt',
      ).writeAsStringSync('level1_content');
      final Directory destination = Directory('${tempDir.path}/deep_dst');

      expect(platform.copy(source, destination), isTrue);
      expect(
        File(
          '${destination.path}/level1/level2/level3/deep_file.txt',
        ).readAsStringSync(),
        equals('deep_content'),
      );
      expect(
        File('${destination.path}/level1/level1_file.txt').readAsStringSync(),
        equals('level1_content'),
      );
    });

    test('copy to destination that already exists', () {
      final Directory source = Directory('${tempDir.path}/copy_exists_src')
        ..createSync();
      File('${source.path}/file.txt').writeAsStringSync('source_data');
      final Directory destination = Directory('${tempDir.path}/copy_exists_dst')
        ..createSync();

      expect(platform.copy(source, destination), isTrue);
      expect(
        File('${destination.path}/file.txt').readAsStringSync(),
        equals('source_data'),
      );
    });

    test('delete returns false when directory does not exist', () {
      final Directory nonexistent = Directory(
        '${tempDir.path}/truly_nonexistent',
      );

      expect(platform.delete(nonexistent), isFalse);
    });

    test('exists returns false for file path', () {
      final File file = File('${tempDir.path}/file_not_dir.txt')..createSync();
      final Directory directoryAtFilePath = Directory(file.path);

      expect(platform.exists(directoryAtFilePath), isFalse);
    });

    test('create returns true even when parent already exists', () {
      final Directory parent = Directory('${tempDir.path}/existing_parent')
        ..createSync();
      final Directory child = Directory('${parent.path}/child');

      expect(platform.create(child), isTrue);
      expect(child.existsSync(), isTrue);
    });

    test('list does not recursively list subdirectory contents', () {
      final Directory directory = Directory('${tempDir.path}/shallow_list')
        ..createSync();
      File('${directory.path}/file1.txt').createSync();
      final Directory subDirectory = Directory('${directory.path}/subdir')
        ..createSync();
      File('${subDirectory.path}/file2.txt').createSync();

      final List<FileSystemEntity> contents = platform.list(directory);

      expect(contents.length, equals(2));
    });

    test('move moves directory with deeply nested structure', () {
      final Directory source = Directory('${tempDir.path}/mv_deep_src')
        ..createSync();
      final Directory nested = Directory('${source.path}/a/b/c')
        ..createSync(recursive: true);
      File('${nested.path}/file.txt').writeAsStringSync('nested_data');
      final Directory destination = Directory('${tempDir.path}/mv_deep_dst');

      expect(platform.move(source, destination), isTrue);
      expect(destination.existsSync(), isTrue);
      expect(source.existsSync(), isFalse);
      expect(
        File('${destination.path}/a/b/c/file.txt').readAsStringSync(),
        equals('nested_data'),
      );
    });

    test('rename preserves directory contents', () {
      final Directory directory = Directory('${tempDir.path}/rename_content')
        ..createSync();
      File('${directory.path}/preserved.txt').writeAsStringSync('preserved');

      expect(platform.rename(directory, 'renamed_content'), isTrue);
      expect(
        File(
          '${tempDir.path}/renamed_content/preserved.txt',
        ).readAsStringSync(),
        equals('preserved'),
      );
    });

    test('name returns slash for root path', () {
      final Directory root = Directory('/');

      final String result = platform.name(root);

      expect(result, equals('/'));
    });

    test('path returns absolute path with original structure', () {
      final Directory directory = Directory('${tempDir.path}/subdir');

      final String result = platform.path(directory);

      expect(result, startsWith('/'));
      expect(result, contains('subdir'));
    });

    test('copy with mixed file types in source directory', () {
      final Directory source = Directory('${tempDir.path}/mixed_src')
        ..createSync();
      File('${source.path}/text.txt').writeAsStringSync('text');
      File('${source.path}/data.json').writeAsStringSync('{"key": "value"}');
      Directory('${source.path}/nested').createSync();
      final Directory destination = Directory('${tempDir.path}/mixed_dst');

      expect(platform.copy(source, destination), isTrue);
      expect(File('${destination.path}/text.txt').existsSync(), isTrue);
      expect(File('${destination.path}/data.json').existsSync(), isTrue);
      expect(Directory('${destination.path}/nested').existsSync(), isTrue);
    });

    test('fromPath with absolute path', () {
      final Directory directory = platform.fromPath('/tmp/absolute_path_test');

      expect(directory, isA<Directory>());
      expect(directory.path, equals('/tmp/absolute_path_test'));
    });

    test('fromPath with relative path', () {
      final Directory directory = platform.fromPath('relative/path');

      expect(directory, isA<Directory>());
      expect(directory.path, equals('relative/path'));
    });
  });
}
