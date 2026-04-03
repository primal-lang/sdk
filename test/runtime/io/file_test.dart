@Tags(['runtime', 'io'])
@TestOn('vm')
library;

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';
import '../../helpers/temp_helpers.dart';

void main() {
  group('File', () {
    late Directory tempDir;
    late File existingFile;

    setUp(() {
      tempDir = createTempTestDirectory('primal_file_test_');
      existingFile = File(path.join(tempDir.path, 'file1.txt'));
      existingFile.parent.createSync(recursive: true);
      existingFile.writeAsStringSync('Hello, world!');
    });

    test('file.fromPath', () {
      final Runtime runtime = getRuntime(
        'main = file.fromPath(${primalString(existingFile.path)})',
      );
      checkResult(runtime, primalString(existingFile.absolute.path));
    });

    test('file.exists returns true for existing file', () {
      final Runtime runtime = getRuntime(
        'main = file.exists(file.fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, true);
    });

    test('file.exists returns false for non-existing file', () {
      final File missingFile = File(path.join(tempDir.path, 'missing.txt'));
      final Runtime runtime = getRuntime(
        'main = file.exists(file.fromPath(${primalString(missingFile.path)}))',
      );
      checkResult(runtime, false);
    });

    test('file.read', () {
      final Runtime runtime = getRuntime(
        'main = file.read(file.fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, primalString('Hello, world!'));
    });

    test('file.write', () {
      const String value = '12345';
      final File targetFile = File(path.join(tempDir.path, 'written.txt'));
      final Runtime runtime = getRuntime(
        'main = file.write(file.fromPath(${primalString(targetFile.path)}), ${primalString(value)})',
      );
      checkResult(runtime, true);
      expect(targetFile.readAsStringSync(), equals(value));
    });

    test('file.length', () {
      final Runtime runtime = getRuntime(
        'main = file.length(file.fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, 13);
    });

    test('file.create', () {
      final File createdFile = File(
        path.join(tempDir.path, 'nested', 'created.txt'),
      );
      final Runtime runtime = getRuntime(
        'main = file.create(file.fromPath(${primalString(createdFile.path)}))',
      );
      checkResult(runtime, true);
      expect(createdFile.existsSync(), isTrue);
    });

    test('file.delete returns true for existing file', () {
      final File deletableFile = File(path.join(tempDir.path, 'delete-me.txt'));
      deletableFile.writeAsStringSync('remove');
      final Runtime runtime = getRuntime(
        'main = file.delete(file.fromPath(${primalString(deletableFile.path)}))',
      );
      checkResult(runtime, true);
      expect(deletableFile.existsSync(), isFalse);
    });

    test('file.delete returns false for non-existing file', () {
      final File missingFile = File(path.join(tempDir.path, 'missing.txt'));
      final Runtime runtime = getRuntime(
        'main = file.delete(file.fromPath(${primalString(missingFile.path)}))',
      );
      checkResult(runtime, false);
    });

    test('file.path', () {
      final Runtime runtime = getRuntime(
        'main = file.path(file.fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, primalString(existingFile.absolute.path));
    });

    test('file.name', () {
      final Runtime runtime = getRuntime(
        'main = file.name(file.fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, primalString('file1.txt'));
    });

    test('file.extension', () {
      final Runtime runtime = getRuntime(
        'main = file.extension(file.fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, primalString('txt'));
    });

    test('file.copy', () {
      final File destinationFile = File(path.join(tempDir.path, 'copy.txt'));
      final Runtime runtime = getRuntime(
        'main = file.copy(file.fromPath(${primalString(existingFile.path)}), file.fromPath(${primalString(destinationFile.path)}))',
      );
      checkResult(runtime, true);
      expect(destinationFile.readAsStringSync(), equals('Hello, world!'));
    });

    test('file.move', () {
      final File sourceFile = File(path.join(tempDir.path, 'move-source.txt'));
      sourceFile.writeAsStringSync('move');
      final File destinationFile = File(path.join(tempDir.path, 'move.txt'));
      final Runtime runtime = getRuntime(
        'main = file.move(file.fromPath(${primalString(sourceFile.path)}), file.fromPath(${primalString(destinationFile.path)}))',
      );
      checkResult(runtime, true);
      expect(sourceFile.existsSync(), isFalse);
      expect(destinationFile.readAsStringSync(), equals('move'));
    });

    test('file.parent', () {
      final Runtime runtime = getRuntime(
        'main = file.parent(file.fromPath(${primalString(existingFile.path)}))',
      );
      checkResult(runtime, primalString(existingFile.parent.absolute.path));
    });

    test('file.rename', () {
      final File sourceFile = File(path.join(tempDir.path, 'rename-me.txt'));
      sourceFile.writeAsStringSync('rename');
      final Runtime runtime = getRuntime(
        'main = file.rename(file.fromPath(${primalString(sourceFile.path)}), ${primalString('renamed.txt')})',
      );
      checkResult(runtime, true);
      expect(File(path.join(tempDir.path, 'renamed.txt')).existsSync(), isTrue);
    });
  });
}
