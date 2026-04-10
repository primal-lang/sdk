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

    test('fromPath with trailing slash', () {
      final String pathWithSlash = '${tempDir.path}/trailing/';
      final Directory directory = platform.fromPath(pathWithSlash);

      expect(directory, isA<Directory>());
      expect(directory.path, equals(pathWithSlash));
    });

    test('fromPath with dot path', () {
      final Directory directory = platform.fromPath('.');

      expect(directory, isA<Directory>());
      expect(directory.path, equals('.'));
    });

    test('fromPath with parent reference path', () {
      final Directory directory = platform.fromPath('..');

      expect(directory, isA<Directory>());
      expect(directory.path, equals('..'));
    });

    test('fromPath with unicode characters', () {
      final String unicodePath = '${tempDir.path}/директория_名前';
      final Directory directory = platform.fromPath(unicodePath);

      expect(directory, isA<Directory>());
      expect(directory.path, equals(unicodePath));
    });

    test('exists returns true for directory just created', () {
      final Directory directory = Directory('${tempDir.path}/just_created');
      directory.createSync();

      expect(platform.exists(directory), isTrue);
    });

    test('exists returns false after directory is deleted', () {
      final Directory directory = Directory('${tempDir.path}/to_be_deleted')
        ..createSync();
      directory.deleteSync();

      expect(platform.exists(directory), isFalse);
    });

    test('create with path containing unicode characters', () {
      final Directory directory = Directory('${tempDir.path}/目录_каталог');

      expect(platform.create(directory), isTrue);
      expect(directory.existsSync(), isTrue);
    });

    test('create with very long path segment', () {
      final String longName = 'a' * 100;
      final Directory directory = Directory('${tempDir.path}/$longName');

      expect(platform.create(directory), isTrue);
      expect(directory.existsSync(), isTrue);
    });

    test('create deeply nested directories in one call', () {
      final Directory directory = Directory(
        '${tempDir.path}/l1/l2/l3/l4/l5/l6/l7/l8/l9/l10',
      );

      expect(platform.create(directory), isTrue);
      expect(directory.existsSync(), isTrue);
    });

    test('delete directory with only subdirectories', () {
      final Directory directory = Directory('${tempDir.path}/only_subdirs')
        ..createSync();
      Directory('${directory.path}/sub1').createSync();
      Directory('${directory.path}/sub2').createSync();
      Directory('${directory.path}/sub1/subsub').createSync();

      expect(platform.delete(directory), isTrue);
      expect(directory.existsSync(), isFalse);
    });

    test('delete directory with only files', () {
      final Directory directory = Directory('${tempDir.path}/only_files')
        ..createSync();
      File('${directory.path}/file1.txt').createSync();
      File('${directory.path}/file2.txt').createSync();

      expect(platform.delete(directory), isTrue);
      expect(directory.existsSync(), isFalse);
    });

    test('delete empty directory', () {
      final Directory directory = Directory('${tempDir.path}/empty_del')
        ..createSync();

      expect(platform.delete(directory), isTrue);
      expect(directory.existsSync(), isFalse);
    });

    test('copy source with many files', () {
      final Directory source = Directory('${tempDir.path}/many_files_src')
        ..createSync();
      for (int index = 0; index < 20; index++) {
        File(
          '${source.path}/file_$index.txt',
        ).writeAsStringSync('content_$index');
      }
      final Directory destination = Directory('${tempDir.path}/many_files_dst');

      expect(platform.copy(source, destination), isTrue);
      expect(destination.listSync().length, equals(20));
    });

    test('copy preserves subdirectory structure', () {
      final Directory source = Directory('${tempDir.path}/struct_src')
        ..createSync();
      Directory('${source.path}/a').createSync();
      Directory('${source.path}/b').createSync();
      Directory('${source.path}/a/c').createSync();
      File('${source.path}/a/c/file.txt').writeAsStringSync('data');
      final Directory destination = Directory('${tempDir.path}/struct_dst');

      expect(platform.copy(source, destination), isTrue);
      expect(Directory('${destination.path}/a').existsSync(), isTrue);
      expect(Directory('${destination.path}/b').existsSync(), isTrue);
      expect(Directory('${destination.path}/a/c').existsSync(), isTrue);
      expect(File('${destination.path}/a/c/file.txt').existsSync(), isTrue);
    });

    test('copy with unicode directory names', () {
      final Directory source = Directory('${tempDir.path}/源目录')..createSync();
      File('${source.path}/文件.txt').writeAsStringSync('内容');
      final Directory destination = Directory('${tempDir.path}/目标目录');

      expect(platform.copy(source, destination), isTrue);
      expect(
        File('${destination.path}/文件.txt').readAsStringSync(),
        equals('内容'),
      );
    });

    test('move to destination in different parent directory', () {
      final Directory parent1 = Directory('${tempDir.path}/parent1')
        ..createSync();
      final Directory parent2 = Directory('${tempDir.path}/parent2')
        ..createSync();
      final Directory source = Directory('${parent1.path}/source')
        ..createSync();
      File('${source.path}/file.txt').writeAsStringSync('data');
      final Directory destination = Directory('${parent2.path}/destination');

      expect(platform.move(source, destination), isTrue);
      expect(destination.existsSync(), isTrue);
      expect(source.existsSync(), isFalse);
      expect(
        File('${destination.path}/file.txt').readAsStringSync(),
        equals('data'),
      );
    });

    test('move directory with many files', () {
      final Directory source = Directory('${tempDir.path}/mv_many_src')
        ..createSync();
      for (int index = 0; index < 10; index++) {
        File('${source.path}/file_$index.txt').writeAsStringSync('content');
      }
      final Directory destination = Directory('${tempDir.path}/mv_many_dst');

      expect(platform.move(source, destination), isTrue);
      expect(destination.listSync().length, equals(10));
      expect(source.existsSync(), isFalse);
    });

    test('rename with unicode characters', () {
      final Directory directory = Directory('${tempDir.path}/rename_unicode')
        ..createSync();

      expect(platform.rename(directory, '新名字_новое'), isTrue);
      expect(
        Directory('${tempDir.path}/新名字_новое').existsSync(),
        isTrue,
      );
    });

    test('rename preserves nested structure', () {
      final Directory directory = Directory('${tempDir.path}/rename_nested')
        ..createSync();
      Directory('${directory.path}/sub1/sub2').createSync(recursive: true);
      File('${directory.path}/sub1/sub2/deep.txt').writeAsStringSync('deep');

      expect(platform.rename(directory, 'renamed_nested'), isTrue);
      expect(
        File(
          '${tempDir.path}/renamed_nested/sub1/sub2/deep.txt',
        ).readAsStringSync(),
        equals('deep'),
      );
    });

    test('rename directory to same name succeeds', () {
      final Directory directory = Directory('${tempDir.path}/same_name')
        ..createSync();
      final String originalName = platform.name(directory);

      expect(platform.rename(directory, originalName), isTrue);
      expect(Directory('${tempDir.path}/same_name').existsSync(), isTrue);
    });

    test('path returns consistent absolute path', () {
      final Directory directory = Directory('${tempDir.path}/consistent');

      final String result1 = platform.path(directory);
      final String result2 = platform.path(directory);

      expect(result1, equals(result2));
    });

    test('path for root directory', () {
      final Directory root = Directory('/');

      final String result = platform.path(root);

      expect(result, equals('/'));
    });

    test('name for directory with trailing slash in path', () {
      final Directory directory = Directory('${tempDir.path}/trailing_name/');

      final String result = platform.name(directory);

      expect(result, equals('trailing_name'));
    });

    test('name for single component path', () {
      final Directory directory = Directory('single');

      final String result = platform.name(directory);

      expect(result, equals('single'));
    });

    test('name with dot in directory name', () {
      final Directory directory = Directory('${tempDir.path}/name.with.dots')
        ..createSync();

      expect(platform.name(directory), equals('name.with.dots'));
    });

    test('parent of root returns root', () {
      final Directory root = Directory('/');

      final Directory parentDirectory = platform.parent(root);

      expect(parentDirectory.path, equals('/'));
    });

    test('parent returns correct type', () {
      final Directory directory = Directory('${tempDir.path}/type_test');

      final Directory parentDirectory = platform.parent(directory);

      expect(parentDirectory, isA<Directory>());
    });

    test('parent chain leads to root', () {
      final Directory directory = Directory('${tempDir.path}/a/b/c')
        ..createSync(recursive: true);

      Directory current = directory;
      int depth = 0;
      while (current.path != '/' && depth < 100) {
        current = platform.parent(current);
        depth++;
      }

      expect(current.path, equals('/'));
    });

    test('list returns correct types for mixed contents', () {
      final Directory directory = Directory('${tempDir.path}/type_list')
        ..createSync();
      File('${directory.path}/file.txt').createSync();
      Directory('${directory.path}/dir').createSync();

      final List<FileSystemEntity> contents = platform.list(directory);

      expect(contents.any((FileSystemEntity entity) => entity is File), isTrue);
      expect(
        contents.any((FileSystemEntity entity) => entity is Directory),
        isTrue,
      );
    });

    test('list returns entities with correct paths', () {
      final Directory directory = Directory('${tempDir.path}/path_list')
        ..createSync();
      File('${directory.path}/file.txt').createSync();

      final List<FileSystemEntity> contents = platform.list(directory);

      expect(contents.first.path, contains('file.txt'));
    });

    test('list directory with hidden files', () {
      final Directory directory = Directory('${tempDir.path}/hidden_list')
        ..createSync();
      File('${directory.path}/.hidden').createSync();
      File('${directory.path}/visible.txt').createSync();

      final List<FileSystemEntity> contents = platform.list(directory);

      expect(contents.length, equals(2));
    });

    test('list directory with unicode named files', () {
      final Directory directory = Directory('${tempDir.path}/unicode_list')
        ..createSync();
      File('${directory.path}/文件.txt').createSync();
      File('${directory.path}/файл.txt').createSync();

      final List<FileSystemEntity> contents = platform.list(directory);

      expect(contents.length, equals(2));
    });

    test('copy does not modify source directory', () {
      final Directory source = Directory('${tempDir.path}/no_modify_src')
        ..createSync();
      File('${source.path}/original.txt').writeAsStringSync('original');
      final Directory destination = Directory('${tempDir.path}/no_modify_dst');

      platform.copy(source, destination);

      expect(source.existsSync(), isTrue);
      expect(
        File('${source.path}/original.txt').readAsStringSync(),
        equals('original'),
      );
    });

    test('copy creates independent destination', () {
      final Directory source = Directory('${tempDir.path}/independent_src')
        ..createSync();
      File('${source.path}/data.txt').writeAsStringSync('original');
      final Directory destination = Directory(
        '${tempDir.path}/independent_dst',
      );

      platform.copy(source, destination);
      File('${destination.path}/data.txt').writeAsStringSync('modified');

      expect(
        File('${source.path}/data.txt').readAsStringSync(),
        equals('original'),
      );
      expect(
        File('${destination.path}/data.txt').readAsStringSync(),
        equals('modified'),
      );
    });

    test('exists with symbolic link to directory', () {
      final Directory target = Directory('${tempDir.path}/link_target')
        ..createSync();
      final Link link = Link('${tempDir.path}/dir_link')
        ..createSync(target.path);
      final Directory directoryAtLink = Directory(link.path);

      expect(platform.exists(directoryAtLink), isTrue);
    });

    test('exists returns false for broken symbolic link', () {
      final Directory target = Directory('${tempDir.path}/broken_target')
        ..createSync();
      final Link link = Link('${tempDir.path}/broken_link')
        ..createSync(target.path);
      target.deleteSync();
      final Directory directoryAtLink = Directory(link.path);

      expect(platform.exists(directoryAtLink), isFalse);
    });

    test('create in nonexistent parent creates entire path', () {
      final Directory directory = Directory(
        '${tempDir.path}/nonexistent_parent/child/grandchild',
      );

      expect(platform.create(directory), isTrue);
      expect(directory.existsSync(), isTrue);
      expect(
        Directory('${tempDir.path}/nonexistent_parent').existsSync(),
        isTrue,
      );
      expect(
        Directory('${tempDir.path}/nonexistent_parent/child').existsSync(),
        isTrue,
      );
    });

    test('move with source and destination in same directory', () {
      final Directory source = Directory('${tempDir.path}/same_parent_src')
        ..createSync();
      File('${source.path}/file.txt').createSync();
      final Directory destination = Directory(
        '${tempDir.path}/same_parent_dst',
      );

      expect(platform.move(source, destination), isTrue);
      expect(destination.existsSync(), isTrue);
      expect(source.existsSync(), isFalse);
    });

    test('rename with very long name', () {
      final Directory directory = Directory('${tempDir.path}/long_rename_src')
        ..createSync();
      final String longName = 'a' * 100;

      expect(platform.rename(directory, longName), isTrue);
      expect(Directory('${tempDir.path}/$longName').existsSync(), isTrue);
    });

    test('list preserves entity absolute paths', () {
      final Directory directory = Directory('${tempDir.path}/abs_path_list')
        ..createSync();
      File('${directory.path}/test.txt').createSync();

      final List<FileSystemEntity> contents = platform.list(directory);

      expect(contents.first.path, startsWith('/'));
    });

    test('fromPath preserves exact path string', () {
      const String exactPath = '/exact/path/to/directory';
      final Directory directory = platform.fromPath(exactPath);

      expect(directory.path, equals(exactPath));
    });

    test('copy with binary file content', () {
      final Directory source = Directory('${tempDir.path}/binary_src')
        ..createSync();
      final List<int> binaryData = List<int>.generate(
        256,
        (int index) => index,
      );
      File('${source.path}/binary.dat').writeAsBytesSync(binaryData);
      final Directory destination = Directory('${tempDir.path}/binary_dst');

      expect(platform.copy(source, destination), isTrue);
      expect(
        File('${destination.path}/binary.dat').readAsBytesSync(),
        equals(binaryData),
      );
    });

    test('copy with large file', () {
      final Directory source = Directory('${tempDir.path}/large_src')
        ..createSync();
      final String largeContent = 'x' * 100000;
      File('${source.path}/large.txt').writeAsStringSync(largeContent);
      final Directory destination = Directory('${tempDir.path}/large_dst');

      expect(platform.copy(source, destination), isTrue);
      expect(
        File('${destination.path}/large.txt').readAsStringSync(),
        equals(largeContent),
      );
    });

    test('move preserves binary file content', () {
      final Directory source = Directory('${tempDir.path}/mv_binary_src')
        ..createSync();
      final List<int> binaryData = List<int>.generate(
        256,
        (int index) => index,
      );
      File('${source.path}/binary.dat').writeAsBytesSync(binaryData);
      final Directory destination = Directory('${tempDir.path}/mv_binary_dst');

      expect(platform.move(source, destination), isTrue);
      expect(
        File('${destination.path}/binary.dat').readAsBytesSync(),
        equals(binaryData),
      );
    });

    test('delete directory with binary files', () {
      final Directory directory = Directory('${tempDir.path}/del_binary')
        ..createSync();
      final List<int> binaryData = List<int>.generate(
        256,
        (int index) => index,
      );
      File('${directory.path}/binary.dat').writeAsBytesSync(binaryData);

      expect(platform.delete(directory), isTrue);
      expect(directory.existsSync(), isFalse);
    });

    test('path preserves symbolic path components', () {
      final Directory directory = Directory('${tempDir.path}/./symbolic');

      final String result = platform.path(directory);

      expect(result, startsWith('/'));
    });

    test('multiple sequential operations on same directory', () {
      final Directory directory = Directory('${tempDir.path}/sequential');

      expect(platform.create(directory), isTrue);
      expect(platform.exists(directory), isTrue);
      expect(platform.path(directory), contains('sequential'));
      expect(platform.name(directory), equals('sequential'));
      expect(platform.list(directory), isEmpty);
      expect(platform.delete(directory), isTrue);
      expect(platform.exists(directory), isFalse);
    });

    test('create and delete same directory multiple times', () {
      final Directory directory = Directory('${tempDir.path}/recreate');

      expect(platform.create(directory), isTrue);
      expect(platform.delete(directory), isTrue);
      expect(platform.create(directory), isTrue);
      expect(platform.delete(directory), isTrue);
      expect(directory.existsSync(), isFalse);
    });
  });
}
