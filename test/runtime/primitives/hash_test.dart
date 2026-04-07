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

    test('hash.md5 throws InvalidArgumentTypesError for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main = hash.md5(true)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.md5 throws InvalidArgumentTypesError for list argument', () {
      final RuntimeFacade runtime = getRuntime('main = hash.md5([1, 2, 3])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha1 throws InvalidArgumentTypesError for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha1(false)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha1 throws InvalidArgumentTypesError for list argument', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha1(["a", "b"])');
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

    test('hash.sha256 throws InvalidArgumentTypesError for list argument', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha256([])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

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

    test(
      'hash.sha512 throws InvalidArgumentTypesError for boolean argument',
      () {
        final RuntimeFacade runtime = getRuntime('main = hash.sha512(true)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('hash.sha512 throws InvalidArgumentTypesError for list argument', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha512([1])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Hash Edge Cases', () {
    test('hash.md5 hashes whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.md5("   ")');
      checkResult(runtime, '"628631f07321b22d8c176c200c855e1b"');
    });

    test('hash.sha1 hashes whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha1("   ")');
      checkResult(runtime, '"088fb1a4ab057f4fcf7d487006499060c7fe5773"');
    });

    test('hash.sha256 hashes whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha256("   ")');
      checkResult(
        runtime,
        '"0aad7da77d2ed59c396c99a74e49f3a4524dcdbcb5163251b1433d640247aeb4"',
      );
    });

    test('hash.sha512 hashes whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha512("   ")');
      checkResult(
        runtime,
        '"856a307f2c7f3b6b52198a7d2bb3843ad397e09b0bbba9dd140af2da8e6bbd3f528952110a09ac77167ba77bf2c3e3a393d7b47432aba9827843e51adb22780f"',
      );
    });

    test('hash.md5 hashes string with newline', () {
      final RuntimeFacade runtime = getRuntime('main = hash.md5("a\\nb")');
      checkResult(runtime, '"8cdeb44417f3c26826595d5820cf5700"');
    });

    test('hash.sha1 hashes string with newline', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha1("a\\nb")');
      checkResult(runtime, '"fcd127ffa1016069006ad91f3f361248f9bdf272"');
    });

    test('hash.sha256 hashes string with tab character', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha256("a\\tb")');
      checkResult(
        runtime,
        '"894891f8b78a9945b0aa07e70d5f71f10b1f1990af127de561cc0ac36024c188"',
      );
    });

    test('hash.sha512 hashes string with tab character', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha512("a\\tb")');
      checkResult(
        runtime,
        '"14ddace147d821ef7dcbb65664117feb31f14e89a2b4d1d7bd0a643c4c46787abfc97a151d330df0a310bf702ae150980687b2f9c155506e0a80706c56deb211"',
      );
    });

    test('hash.md5 hashes unicode string', () {
      final RuntimeFacade runtime = getRuntime('main = hash.md5("caf\\u00e9")');
      checkResult(runtime, '"07117fe4a1ebd544965dc19573183da2"');
    });

    test('hash.sha256 hashes emoji string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = hash.sha256("\\u{1F600}")',
      );
      checkResult(
        runtime,
        '"f0443a342c5ef54783a111b51ba56c938e474c32324d90c3a60c9c8e3a37e2d9"',
      );
    });

    test('hash.md5 hashes long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = hash.md5("abcdefghijklmnopqrstuvwxyz0123456789")',
      );
      checkResult(runtime, '"6d2286301265512f019781cc0ce7a39f"');
    });

    test('hash.sha256 hashes long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = hash.sha256("abcdefghijklmnopqrstuvwxyz0123456789")',
      );
      checkResult(
        runtime,
        '"011fc2994e39d251141540f87a69092b3f22a86767f7283de7eeedb3897bedf6"',
      );
    });

    test('hash.md5 hashes single character', () {
      final RuntimeFacade runtime = getRuntime('main = hash.md5("a")');
      checkResult(runtime, '"0cc175b9c0f1b6a831c399e269772661"');
    });

    test('hash.sha1 hashes single character', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha1("a")');
      checkResult(runtime, '"86f7e437faa5a7fce15d1ddcb9eaeaea377667b8"');
    });

    test('hash.sha256 hashes single character', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha256("a")');
      checkResult(
        runtime,
        '"ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"',
      );
    });

    test('hash.sha512 hashes single character', () {
      final RuntimeFacade runtime = getRuntime('main = hash.sha512("a")');
      checkResult(
        runtime,
        '"1f40fc92da241694750979ee6cf582f2d5d7d28e18335de05abc54d0560e0f5302860c652bf08d560252aa5e74210546f369fbbbce8c12cfc7957b2652fe9a75"',
      );
    });
  });
}
