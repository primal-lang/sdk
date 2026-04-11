@Tags(['runtime', 'io'])
@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:primal/compiler/lowering/runtime_facade.dart';
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
            runtime.evaluateToTerm(runtime.mainExpression([])).native()
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

    test('directory.list returns empty list for empty directory', () {
      final Directory emptyDirectory = Directory(
        path.join(tempDir.path, 'empty'),
      );
      emptyDirectory.createSync();
      final RuntimeFacade runtime = getRuntime(
        'main = directory.list(directory.fromPath(${primalString(emptyDirectory.path)}))',
      );
      checkResult(runtime, '[]');
    });

    test('directory.create returns true when directory already exists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = directory.create(directory.fromPath(${primalString(existingDirectory.path)}))',
      );
      checkResult(runtime, true);
      expect(existingDirectory.existsSync(), isTrue);
    });

    test('directory.copy returns false for non-existing source', () {
      final Directory missingSource = Directory(
        path.join(tempDir.path, 'missing-source'),
      );
      final Directory destinationDirectory = Directory(
        path.join(tempDir.path, 'copy-destination'),
      );
      final RuntimeFacade runtime = getRuntime(
        'main = directory.copy(directory.fromPath(${primalString(missingSource.path)}), directory.fromPath(${primalString(destinationDirectory.path)}))',
      );
      checkResult(runtime, false);
    });

    test('directory.move returns false for non-existing source', () {
      final Directory missingSource = Directory(
        path.join(tempDir.path, 'missing-move-source'),
      );
      final Directory destinationDirectory = Directory(
        path.join(tempDir.path, 'move-destination'),
      );
      final RuntimeFacade runtime = getRuntime(
        'main = directory.move(directory.fromPath(${primalString(missingSource.path)}), directory.fromPath(${primalString(destinationDirectory.path)}))',
      );
      checkResult(runtime, false);
    });

    test('directory.rename returns false for non-existing directory', () {
      final Directory missingDirectory = Directory(
        path.join(tempDir.path, 'missing-rename'),
      );
      final RuntimeFacade runtime = getRuntime(
        'main = directory.rename(directory.fromPath(${primalString(missingDirectory.path)}), ${primalString('new-name')})',
      );
      checkResult(runtime, false);
    });

    test('directory.delete removes directory with nested content', () {
      final Directory directoryWithContent = Directory(
        path.join(tempDir.path, 'delete-recursive'),
      );
      directoryWithContent.createSync();
      final Directory nestedDirectory = Directory(
        path.join(directoryWithContent.path, 'nested'),
      );
      nestedDirectory.createSync();
      File(path.join(nestedDirectory.path, 'file.txt')).writeAsStringSync(
        'content',
      );
      final RuntimeFacade runtime = getRuntime(
        'main = directory.delete(directory.fromPath(${primalString(directoryWithContent.path)}))',
      );
      checkResult(runtime, true);
      expect(directoryWithContent.existsSync(), isFalse);
    });

    test('directory.copy preserves nested directory structure', () {
      final Directory sourceDirectory = Directory(
        path.join(tempDir.path, 'deep-source'),
      );
      sourceDirectory.createSync();
      final Directory level1 = Directory(
        path.join(sourceDirectory.path, 'level1'),
      );
      level1.createSync();
      final Directory level2 = Directory(path.join(level1.path, 'level2'));
      level2.createSync();
      File(path.join(level2.path, 'deep.txt')).writeAsStringSync('deep');

      final Directory destinationDirectory = Directory(
        path.join(tempDir.path, 'deep-copy'),
      );
      final RuntimeFacade runtime = getRuntime(
        'main = directory.copy(directory.fromPath(${primalString(sourceDirectory.path)}), directory.fromPath(${primalString(destinationDirectory.path)}))',
      );
      checkResult(runtime, true);
      expect(
        File(
          path.join(destinationDirectory.path, 'level1', 'level2', 'deep.txt'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          path.join(destinationDirectory.path, 'level1', 'level2', 'deep.txt'),
        ).readAsStringSync(),
        equals('deep'),
      );
    });

    group('edge cases', () {
      test('directory.fromPath with relative path resolves to absolute', () {
        final RuntimeFacade runtime = getRuntime(
          'main = directory.fromPath(${primalString('.')})',
        );
        final String result = runtime.executeMain();
        expect(result.startsWith('"'), isTrue);
        expect(result.endsWith('"'), isTrue);
        expect(result.contains('/'), isTrue);
      });

      test('directory.fromPath with path containing spaces', () {
        final Directory directoryWithSpaces = Directory(
          path.join(tempDir.path, 'directory with spaces'),
        );
        directoryWithSpaces.createSync();
        final RuntimeFacade runtime = getRuntime(
          'main = directory.fromPath(${primalString(directoryWithSpaces.path)})',
        );
        checkResult(runtime, primalString(directoryWithSpaces.absolute.path));
      });

      test('directory.name for hidden directory', () {
        final Directory hiddenDirectory = Directory(
          path.join(tempDir.path, '.hidden'),
        );
        hiddenDirectory.createSync();
        final RuntimeFacade runtime = getRuntime(
          'main = directory.name(directory.fromPath(${primalString(hiddenDirectory.path)}))',
        );
        checkResult(runtime, primalString('.hidden'));
      });

      test('directory.name for directory with spaces', () {
        final Directory directoryWithSpaces = Directory(
          path.join(tempDir.path, 'name with spaces'),
        );
        directoryWithSpaces.createSync();
        final RuntimeFacade runtime = getRuntime(
          'main = directory.name(directory.fromPath(${primalString(directoryWithSpaces.path)}))',
        );
        checkResult(runtime, primalString('name with spaces'));
      });

      test('directory.list returns only files when no subdirectories', () {
        final Directory filesOnlyDirectory = Directory(
          path.join(tempDir.path, 'files-only'),
        );
        filesOnlyDirectory.createSync();
        File(path.join(filesOnlyDirectory.path, 'a.txt')).writeAsStringSync(
          'a',
        );
        File(path.join(filesOnlyDirectory.path, 'b.txt')).writeAsStringSync(
          'b',
        );
        final RuntimeFacade runtime = getRuntime(
          'main = directory.list(directory.fromPath(${primalString(filesOnlyDirectory.path)}))',
        );
        final List<dynamic> children =
            runtime.evaluateToTerm(runtime.mainExpression([])).native()
                as List<dynamic>;
        expect(children.length, equals(2));
        expect(children.every((child) => child is File), isTrue);
      });

      test('directory.list returns only directories when no files', () {
        final Directory directoriesOnlyDirectory = Directory(
          path.join(tempDir.path, 'directories-only'),
        );
        directoriesOnlyDirectory.createSync();
        Directory(
          path.join(directoriesOnlyDirectory.path, 'sub1'),
        ).createSync();
        Directory(
          path.join(directoriesOnlyDirectory.path, 'sub2'),
        ).createSync();
        final RuntimeFacade runtime = getRuntime(
          'main = directory.list(directory.fromPath(${primalString(directoriesOnlyDirectory.path)}))',
        );
        final List<dynamic> children =
            runtime.evaluateToTerm(runtime.mainExpression([])).native()
                as List<dynamic>;
        expect(children.length, equals(2));
        expect(children.every((child) => child is Directory), isTrue);
      });

      test('directory.copy overwrites existing destination', () {
        final Directory sourceDirectory = Directory(
          path.join(tempDir.path, 'copy-source-overwrite'),
        );
        sourceDirectory.createSync();
        File(path.join(sourceDirectory.path, 'new.txt')).writeAsStringSync(
          'new content',
        );

        final Directory destinationDirectory = Directory(
          path.join(tempDir.path, 'copy-destination-overwrite'),
        );
        destinationDirectory.createSync();
        File(path.join(destinationDirectory.path, 'old.txt')).writeAsStringSync(
          'old content',
        );

        final RuntimeFacade runtime = getRuntime(
          'main = directory.copy(directory.fromPath(${primalString(sourceDirectory.path)}), directory.fromPath(${primalString(destinationDirectory.path)}))',
        );
        checkResult(runtime, true);
        expect(
          File(path.join(destinationDirectory.path, 'new.txt')).existsSync(),
          isTrue,
        );
        expect(
          File(
            path.join(destinationDirectory.path, 'new.txt'),
          ).readAsStringSync(),
          equals('new content'),
        );
      });

      test('directory.copy to nested non-existing path', () {
        final Directory sourceDirectory = Directory(
          path.join(tempDir.path, 'copy-source-nested'),
        );
        sourceDirectory.createSync();
        File(path.join(sourceDirectory.path, 'data.txt')).writeAsStringSync(
          'data',
        );

        final Directory destinationDirectory = Directory(
          path.join(tempDir.path, 'nested', 'path', 'destination'),
        );
        final RuntimeFacade runtime = getRuntime(
          'main = directory.copy(directory.fromPath(${primalString(sourceDirectory.path)}), directory.fromPath(${primalString(destinationDirectory.path)}))',
        );
        checkResult(runtime, true);
        expect(destinationDirectory.existsSync(), isTrue);
        expect(
          File(
            path.join(destinationDirectory.path, 'data.txt'),
          ).readAsStringSync(),
          equals('data'),
        );
      });

      test('directory.move preserves file content', () {
        final Directory sourceDirectory = Directory(
          path.join(tempDir.path, 'move-source-content'),
        );
        sourceDirectory.createSync();
        File(path.join(sourceDirectory.path, 'content.txt')).writeAsStringSync(
          'preserved content',
        );

        final Directory destinationDirectory = Directory(
          path.join(tempDir.path, 'move-destination-content'),
        );
        final RuntimeFacade runtime = getRuntime(
          'main = directory.move(directory.fromPath(${primalString(sourceDirectory.path)}), directory.fromPath(${primalString(destinationDirectory.path)}))',
        );
        checkResult(runtime, true);
        expect(sourceDirectory.existsSync(), isFalse);
        expect(
          File(
            path.join(destinationDirectory.path, 'content.txt'),
          ).readAsStringSync(),
          equals('preserved content'),
        );
      });

      test('directory.rename with name containing spaces', () {
        final Directory sourceDirectory = Directory(
          path.join(tempDir.path, 'rename-spaces'),
        );
        sourceDirectory.createSync();
        final RuntimeFacade runtime = getRuntime(
          'main = directory.rename(directory.fromPath(${primalString(sourceDirectory.path)}), ${primalString('name with spaces')})',
        );
        checkResult(runtime, true);
        expect(
          Directory(path.join(tempDir.path, 'name with spaces')).existsSync(),
          isTrue,
        );
      });

      test('directory.parent returns parent directory', () {
        final Directory nestedDirectory = Directory(
          path.join(tempDir.path, 'parent-test', 'child'),
        );
        nestedDirectory.createSync(recursive: true);
        final RuntimeFacade runtime = getRuntime(
          'main = directory.path(directory.parent(directory.fromPath(${primalString(nestedDirectory.path)})))',
        );
        checkResult(
          runtime,
          primalString(nestedDirectory.parent.absolute.path),
        );
      });

      test('directory.parent of parent navigates up hierarchy', () {
        final Directory deepDirectory = Directory(
          path.join(tempDir.path, 'level1', 'level2', 'level3'),
        );
        deepDirectory.createSync(recursive: true);
        final RuntimeFacade runtime = getRuntime(
          'main = directory.path(directory.parent(directory.parent(directory.fromPath(${primalString(deepDirectory.path)}))))',
        );
        checkResult(
          runtime,
          primalString(deepDirectory.parent.parent.absolute.path),
        );
      });

      test('directory.create with deeply nested path', () {
        final Directory deeplyNestedDirectory = Directory(
          path.join(tempDir.path, 'a', 'b', 'c', 'd', 'e'),
        );
        final RuntimeFacade runtime = getRuntime(
          'main = directory.create(directory.fromPath(${primalString(deeplyNestedDirectory.path)}))',
        );
        checkResult(runtime, true);
        expect(deeplyNestedDirectory.existsSync(), isTrue);
      });

      test('directory.exists returns false for file path', () {
        final File file = File(path.join(tempDir.path, 'not-a-directory.txt'));
        file.writeAsStringSync('content');
        final RuntimeFacade runtime = getRuntime(
          'main = directory.exists(directory.fromPath(${primalString(file.path)}))',
        );
        checkResult(runtime, false);
      });

      test('directory.list includes hidden files', () {
        final Directory directoryWithHidden = Directory(
          path.join(tempDir.path, 'hidden-test'),
        );
        directoryWithHidden.createSync();
        File(path.join(directoryWithHidden.path, '.hidden')).writeAsStringSync(
          'hidden',
        );
        File(
          path.join(directoryWithHidden.path, 'visible.txt'),
        ).writeAsStringSync(
          'visible',
        );
        final RuntimeFacade runtime = getRuntime(
          'main = directory.list(directory.fromPath(${primalString(directoryWithHidden.path)}))',
        );
        final List<dynamic> children =
            runtime.evaluateToTerm(runtime.mainExpression([])).native()
                as List<dynamic>;
        expect(children.length, equals(2));
      });

      test('directory.delete on empty directory', () {
        final Directory emptyDirectory = Directory(
          path.join(tempDir.path, 'empty-delete'),
        );
        emptyDirectory.createSync();
        final RuntimeFacade runtime = getRuntime(
          'main = directory.delete(directory.fromPath(${primalString(emptyDirectory.path)}))',
        );
        checkResult(runtime, true);
        expect(emptyDirectory.existsSync(), isFalse);
      });

      test('directory.copy preserves file content', () {
        final Directory sourceDirectory = Directory(
          path.join(tempDir.path, 'copy-content-source'),
        );
        sourceDirectory.createSync();
        File(path.join(sourceDirectory.path, 'data.txt')).writeAsStringSync(
          'specific content to verify',
        );

        final Directory destinationDirectory = Directory(
          path.join(tempDir.path, 'copy-content-destination'),
        );
        final RuntimeFacade runtime = getRuntime(
          'main = directory.copy(directory.fromPath(${primalString(sourceDirectory.path)}), directory.fromPath(${primalString(destinationDirectory.path)}))',
        );
        checkResult(runtime, true);
        expect(
          File(
            path.join(destinationDirectory.path, 'data.txt'),
          ).readAsStringSync(),
          equals('specific content to verify'),
        );
      });

      test('directory.copy does not modify source', () {
        final Directory sourceDirectory = Directory(
          path.join(tempDir.path, 'copy-no-modify-source'),
        );
        sourceDirectory.createSync();
        File(path.join(sourceDirectory.path, 'original.txt')).writeAsStringSync(
          'original',
        );

        final Directory destinationDirectory = Directory(
          path.join(tempDir.path, 'copy-no-modify-destination'),
        );
        final RuntimeFacade runtime = getRuntime(
          'main = directory.copy(directory.fromPath(${primalString(sourceDirectory.path)}), directory.fromPath(${primalString(destinationDirectory.path)}))',
        );
        checkResult(runtime, true);
        expect(sourceDirectory.existsSync(), isTrue);
        expect(
          File(path.join(sourceDirectory.path, 'original.txt')).existsSync(),
          isTrue,
        );
        expect(
          File(
            path.join(sourceDirectory.path, 'original.txt'),
          ).readAsStringSync(),
          equals('original'),
        );
      });
    });
  });
}
