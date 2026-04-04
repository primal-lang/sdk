@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Hash', () {
    test('hash.md5 hashes empty string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.md5("")');
      checkResult(runtime, '"d41d8cd98f00b204e9800998ecf8427e"');
    });

    test('hash.md5 hashes non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.md5("Hello")');
      checkResult(runtime, '"8b1a9953c4611296a827abf8c47804d7"');
    });

    test('hash.sha1 hashes empty string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha1("")');
      checkResult(runtime, '"da39a3ee5e6b4b0d3255bfef95601890afd80709"');
    });

    test('hash.sha1 hashes non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha1("Hello")');
      checkResult(runtime, '"f7ff9e8b7bb2e09b70935a5d785e0cc5d9d0abf0"');
    });

    test('hash.sha256 hashes empty string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha256("")');
      checkResult(
        runtime,
        '"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"',
      );
    });

    test('hash.sha256 hashes non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha256("Hello")');
      checkResult(
        runtime,
        '"185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969"',
      );
    });

    test('hash.sha512 hashes empty string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha512("")');
      checkResult(
        runtime,
        '"cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"',
      );
    });

    test('hash.sha512 hashes non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha512("Hello")');
      checkResult(
        runtime,
        '"3615f80c9d293ed7402687f94b22d58e529b8cc7916f8fac7fddf7fbd5af4cf777d3d795a7a00a16bf7e7f3fb9561ee9baae480da9fe7a18769e71886b03f315"',
      );
    });
  });

  group('Hash Type Errors', () {
    test('hash.md5 throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = hash.md5(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('hash.sha1 throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha1(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('hash.sha256 throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha256(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Hash Error Cases', () {
    test('hash.md5 throws InvalidArgumentTypesError for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = hash.md5(42)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test(
      'hash.sha256 throws InvalidArgumentTypesError for boolean argument',
      () {
        final RuntimeFacade runtime = getRuntime('main = hash.sha256(true)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'hash.sha512 throws InvalidArgumentTypesError for number argument',
      () {
        final RuntimeFacade runtime = getRuntime('main = hash.sha512(42)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );
  });
}
