@Tags(['runtime', 'io'])
@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:primal/compiler/semantic/lowerer.dart';
import 'package:primal/compiler/semantic/runtime_facade.dart';
import 'package:test/test.dart';

import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';
import '../../helpers/temp_helpers.dart';

void main() {
  group('Directory', () {
    late Directory tempDir;
    late Directory existingDirectory;
    late File childFile;
    late Directory childDirectory;

    setUp(() {
      tempDir = createTempTestDirectory('primal_directory_test_');
      existingDirectory = Directory(path.join(tempDir.path, 'source'));
      existingDirectory.createSync(recursive: true);

      childFile = File(path.join(existingDirectory.path, 'file1.txt'));
      childFile.writeAsStringSync('Hello, world!');

      childDirectory = Directory(path.join(existingDirectory.path, 'nested'));
      childDirectory.createSync();
    });

    test('directory.fromPath', () {
      final RuntimeFacade runtime = getRuntime(
        'main = directory.fromPath(${primalString(existingDirectory.path)})',
      );
      checkResult(runtime, primalString(existingDirectory.absolute.path));
    });

    test('directory.exists returns true for existing directory', () {
      final RuntimeFacade runtime = getRuntime(
        'main = directory.exists(directory.fromPath(${primalString(existingDirectory.path)}))',
      );
      checkResult(runtime, true);
    });

    test('directory.exists returns false for non-existing directory', () {
      final Directory missingDirectory = Directory(
        path.join(tempDir.path, 'missing'),
      );
      final RuntimeFacade runtime = getRuntime(
        'main = directory.exists(directory.fromPath(${primalString(missingDirectory.path)}))',
      );
      checkResult(runtime, false);
    });

    test('directory.create', () {
      final Directory createdDirectory = Directory(
        path.join(tempDir.path, 'created', 'child'),
      );
      final RuntimeFacade runtime = getRuntime(
        'main = directory.create(directory.fromPath(${primalString(createdDirectory.path)}))',
      );
      checkResult(runtime, true);
      expect(createdDirectory.existsSync(), isTrue);
    });

    test('directory.delete returns true for existing directory', () {
      final Directory deletableDirectory = Directory(
        path.join(tempDir.path, 'delete-me'),
      );
      deletableDirectory.createSync();
      final RuntimeFacade runtime = getRuntime(
        'main = directory.delete(directory.fromPath(${primalString(deletableDirectory.path)}))',
      );
      checkResult(runtime, true);
      expect(deletableDirectory.existsSync(), isFalse);
    });

    test('directory.delete returns false for non-existing directory', () {
      final Directory missingDirectory = Directory(
        path.join(tempDir.path, 'missing'),
      );
      final RuntimeFacade runtime = getRuntime(
        'main = directory.delete(directory.fromPath(${primalString(missingDirectory.path)}))',
      );
      checkResult(runtime, false);
    });

    test('directory.copy', () {
      final Directory destinationDirectory = Directory(
        path.join(tempDir.path, 'copy'),
      );
      final RuntimeFacade runtime = getRuntime(
        'main = directory.copy(directory.fromPath(${primalString(existingDirectory.path)}), directory.fromPath(${primalString(destinationDirectory.path)}))',
      );
      checkResult(runtime, true);
      expect(
        File(path.join(destinationDirectory.path, 'file1.txt')).existsSync(),
        isTrue,
      );
      expect(
        Directory(path.join(destinationDirectory.path, 'nested')).existsSync(),
        isTrue,
      );
    });

    test('directory.move', () {
      final Directory sourceDirectory = Directory(
        path.join(tempDir.path, 'move-source'),
      );
      sourceDirectory.createSync();
      File(path.join(sourceDirectory.path, 'file.txt')).writeAsStringSync(
        'move',
      );

      final Directory destinationDirectory = Directory(
        path.join(tempDir.path, 'move-target'),
      );
      final RuntimeFacade runtime = getRuntime(
        'main = directory.move(directory.fromPath(${primalString(sourceDirectory.path)}), directory.fromPath(${primalString(destinationDirectory.path)}))',
      );
      checkResult(runtime, true);
      expect(sourceDirectory.existsSync(), isFalse);
      expect(destinationDirectory.existsSync(), isTrue);
    });

    test('directory.rename', () {
      final Directory sourceDirectory = Directory(
        path.join(tempDir.path, 'rename-me'),
      );
      sourceDirectory.createSync();
      final RuntimeFacade runtime = getRuntime(
        'main = directory.rename(directory.fromPath(${primalString(sourceDirectory.path)}), ${primalString('renamed')})',
      );
      checkResult(runtime, true);
      expect(
        Directory(path.join(tempDir.path, 'renamed')).existsSync(),
        isTrue,
      );
    });

    test('directory.path', () {
      final RuntimeFacade runtime = getRuntime(
        'main = directory.path(directory.fromPath(${primalString(existingDirectory.path)}))',
      );
      checkResult(runtime, primalString(existingDirectory.absolute.path));
    });

    test('directory.name', () {
      final RuntimeFacade runtime = getRuntime(
        'main = directory.name(directory.fromPath(${primalString(existingDirectory.path)}))',
      );
      checkResult(runtime, primalString('source'));
    });

    test('directory.parent', () {
      final RuntimeFacade runtime = getRuntime(
        'main = directory.parent(directory.fromPath(${primalString(existingDirectory.path)}))',
      );
      checkResult(
        runtime,
        primalString(existingDirectory.parent.absolute.path),
      );
    });

    test(
      'directory.list returns files and directories without order assumptions',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = directory.list(directory.fromPath(${primalString(existingDirectory.path)}))',
        );
        final List<dynamic> children =
            const Lowerer()
                    .lowerExpression(runtime.mainExpression([]))
                    .evaluate()
                    .native()
                as List<dynamic>;
        final List<String> paths = children
            .map((child) => (child as FileSystemEntity).absolute.path)
            .toList();

        expect(
          paths,
          unorderedEquals([
            childFile.absolute.path,
            childDirectory.absolute.path,
          ]),
        );
      },
    );
  });
}
