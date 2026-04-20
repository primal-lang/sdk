@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Hash', () {
    test('hash.md5 hashes empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5("")');
      checkResult(runtime, '"d41d8cd98f00b204e9800998ecf8427e"');
    });

    test('hash.md5 hashes non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5("Hello")');
      checkResult(runtime, '"8b1a9953c4611296a827abf8c47804d7"');
    });

    test('hash.sha1 hashes empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha1("")');
      checkResult(runtime, '"da39a3ee5e6b4b0d3255bfef95601890afd80709"');
    });

    test('hash.sha1 hashes non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha1("Hello")');
      checkResult(runtime, '"f7ff9e8b7bb2e09b70935a5d785e0cc5d9d0abf0"');
    });

    test('hash.sha256 hashes empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha256("")');
      checkResult(
        runtime,
        '"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"',
      );
    });

    test('hash.sha256 hashes non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha256("Hello")');
      checkResult(
        runtime,
        '"185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969"',
      );
    });

    test('hash.sha512 hashes empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha512("")');
      checkResult(
        runtime,
        '"cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"',
      );
    });

    test('hash.sha512 hashes non-empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha512("Hello")');
      checkResult(
        runtime,
        '"3615f80c9d293ed7402687f94b22d58e529b8cc7916f8fac7fddf7fbd5af4cf777d3d795a7a00a16bf7e7f3fb9561ee9baae480da9fe7a18769e71886b03f315"',
      );
    });
  });

  group('Hash Type Errors', () {
    test('hash.md5 throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('hash.sha1 throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha1(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('hash.sha256 throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha256(123)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Hash Error Cases', () {
    test('hash.md5 throws InvalidArgumentTypesError for number argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5(42)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.md5 throws InvalidArgumentTypesError for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5(true)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.md5 throws InvalidArgumentTypesError for list argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5([1, 2, 3])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha1 throws InvalidArgumentTypesError for boolean argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha1(false)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha1 throws InvalidArgumentTypesError for list argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha1(["a", "b"])',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test(
      'hash.sha256 throws InvalidArgumentTypesError for boolean argument',
      () {
        final RuntimeFacade runtime = getRuntime('main() = hash.sha256(true)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('hash.sha256 throws InvalidArgumentTypesError for list argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha256([])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test(
      'hash.sha512 throws InvalidArgumentTypesError for number argument',
      () {
        final RuntimeFacade runtime = getRuntime('main() = hash.sha512(42)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'hash.sha512 throws InvalidArgumentTypesError for boolean argument',
      () {
        final RuntimeFacade runtime = getRuntime('main() = hash.sha512(true)');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test('hash.sha512 throws InvalidArgumentTypesError for list argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha512([1])');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Hash Edge Cases', () {
    test('hash.md5 hashes whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5("   ")');
      checkResult(runtime, '"628631f07321b22d8c176c200c855e1b"');
    });

    test('hash.sha1 hashes whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha1("   ")');
      checkResult(runtime, '"088fb1a4ab057f4fcf7d487006499060c7fe5773"');
    });

    test('hash.sha256 hashes whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha256("   ")');
      checkResult(
        runtime,
        '"0aad7da77d2ed59c396c99a74e49f3a4524dcdbcb5163251b1433d640247aeb4"',
      );
    });

    test('hash.sha512 hashes whitespace-only string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha512("   ")');
      checkResult(
        runtime,
        '"856a307f2c7f3b6b52198a7d2bb3843ad397e09b0bbba9dd140af2da8e6bbd3f528952110a09ac77167ba77bf2c3e3a393d7b47432aba9827843e51adb22780f"',
      );
    });

    test('hash.md5 hashes string with newline', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5("a\\nb")');
      checkResult(runtime, '"8cdeb44417f3c26826595d5820cf5700"');
    });

    test('hash.sha1 hashes string with newline', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha1("a\\nb")');
      checkResult(runtime, '"fcd127ffa1016069006ad91f3f361248f9bdf272"');
    });

    test('hash.sha256 hashes string with tab character', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha256("a\\tb")');
      checkResult(
        runtime,
        '"894891f8b78a9945b0aa07e70d5f71f10b1f1990af127de561cc0ac36024c188"',
      );
    });

    test('hash.sha512 hashes string with tab character', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha512("a\\tb")');
      checkResult(
        runtime,
        '"14ddace147d821ef7dcbb65664117feb31f14e89a2b4d1d7bd0a643c4c46787abfc97a151d330df0a310bf702ae150980687b2f9c155506e0a80706c56deb211"',
      );
    });

    test('hash.md5 hashes unicode string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.md5("caf\\u00e9")',
      );
      checkResult(runtime, '"07117fe4a1ebd544965dc19573183da2"');
    });

    test('hash.sha256 hashes emoji string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha256("\\u{1F600}")',
      );
      checkResult(
        runtime,
        '"f0443a342c5ef54783a111b51ba56c938e474c32324d90c3a60c9c8e3a37e2d9"',
      );
    });

    test('hash.md5 hashes long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.md5("abcdefghijklmnopqrstuvwxyz0123456789")',
      );
      checkResult(runtime, '"6d2286301265512f019781cc0ce7a39f"');
    });

    test('hash.sha256 hashes long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha256("abcdefghijklmnopqrstuvwxyz0123456789")',
      );
      checkResult(
        runtime,
        '"011fc2994e39d251141540f87a69092b3f22a86767f7283de7eeedb3897bedf6"',
      );
    });

    test('hash.md5 hashes single character', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5("a")');
      checkResult(runtime, '"0cc175b9c0f1b6a831c399e269772661"');
    });

    test('hash.sha1 hashes single character', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha1("a")');
      checkResult(runtime, '"86f7e437faa5a7fce15d1ddcb9eaeaea377667b8"');
    });

    test('hash.sha256 hashes single character', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha256("a")');
      checkResult(
        runtime,
        '"ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"',
      );
    });

    test('hash.sha512 hashes single character', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha512("a")');
      checkResult(
        runtime,
        '"1f40fc92da241694750979ee6cf582f2d5d7d28e18335de05abc54d0560e0f5302860c652bf08d560252aa5e74210546f369fbbbce8c12cfc7957b2652fe9a75"',
      );
    });

    test('hash.sha256 hashes string with newline', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha256("a\\nb")');
      checkResult(
        runtime,
        '"7e18f737311b2dc3b2f269dd78396b0351f14fb66efa879f768cb23181883c78"',
      );
    });

    test('hash.sha512 hashes string with newline', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha512("a\\nb")');
      checkResult(
        runtime,
        '"377f7c6560b237d3b88f734faf092fe88f4b2067e048277223748881569ce7b2237c3e3a3fbeef319eea1ccab853b42ff2a7b8791308342ae383579f4420cba0"',
      );
    });

    test('hash.md5 hashes string with tab character', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5("a\\tb")');
      checkResult(runtime, '"6f7f0b434651658d5d07ec3764180020"');
    });

    test('hash.sha1 hashes string with tab character', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha1("a\\tb")');
      checkResult(runtime, '"89df1bfd2d7396f9661d8bc1e24ba7e05afc67b4"');
    });

    test('hash.sha1 hashes unicode string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha1("caf\\u00e9")',
      );
      checkResult(runtime, '"f424452a9673918c6f09b0cdd35b20be8e6ae7d7"');
    });

    test('hash.sha512 hashes unicode string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha512("caf\\u00e9")',
      );
      checkResult(
        runtime,
        '"0c9dac7fe613719170790f08a5f7b9f5ef876c7b57ff429074bf417969c2c54107d924daf5e706568afca4712d91da1cfdf77588d76403a845177e23e3aeb8ce"',
      );
    });

    test('hash.sha1 hashes emoji string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha1("\\u{1F600}")',
      );
      checkResult(runtime, '"9c533688a979a858cbd6a43c9f91aba624651f18"');
    });

    test('hash.md5 hashes emoji string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.md5("\\u{1F600}")',
      );
      checkResult(runtime, '"2a02eac39d716a70ecf37579185927b6"');
    });

    test('hash.sha512 hashes emoji string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha512("\\u{1F600}")',
      );
      checkResult(
        runtime,
        '"9b1ce8b6649e678e1cb7bca85afeaae750add5cfb0668d25ebba5e7f0038f1b6bdcc4bacd909049e752be2a3a3c0158c0f2bb5a33d8101b2ed5d74a66ece2425"',
      );
    });

    test('hash.sha1 hashes long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha1("abcdefghijklmnopqrstuvwxyz0123456789")',
      );
      checkResult(runtime, '"d2985049a677bbc4b4e8dea3b89c4820e5668e3a"');
    });

    test('hash.sha512 hashes long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha512("abcdefghijklmnopqrstuvwxyz0123456789")',
      );
      checkResult(
        runtime,
        '"a59b49216a0e3a20443b72c64bdae51d41b33ad08a86a4fb936378dd2f9cd3899809ec31e5259b3b4549388d026561362be71548d4393be76da7eeb01839470c"',
      );
    });

    test('hash.md5 hashes string with special characters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.md5("!@#\$%^&*()")',
      );
      checkResult(runtime, '"05b28d17a7b6e7024b6e5d8cc43a8bf7"');
    });

    test('hash.sha1 hashes string with special characters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha1("!@#\$%^&*()")',
      );
      checkResult(runtime, '"bf24d65c9bb05b9b814a966940bcfa50767c8a8d"');
    });

    test('hash.sha256 hashes string with special characters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha256("!@#\$%^&*()")',
      );
      checkResult(
        runtime,
        '"95ce789c5c9d18490972709838ca3a9719094bca3ac16332cfec0652b0236141"',
      );
    });

    test('hash.sha512 hashes string with special characters', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha512("!@#\$%^&*()")',
      );
      checkResult(
        runtime,
        '"138fad927473f694c3a02cca61008e52572bd19ce442f20e139b6f09157b97157fd71946fedfec2381b7e33618afe5f7c24a873ed1efe416978acfc434503614"',
      );
    });

    test('hash.md5 hashes numeric string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5("12345")');
      checkResult(runtime, '"827ccb0eea8a706c4c34a16891f84e7b"');
    });

    test('hash.sha1 hashes numeric string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha1("12345")');
      checkResult(runtime, '"8cb2237d0679ca88db6464eac60da96345513964"');
    });

    test('hash.sha256 hashes numeric string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha256("12345")');
      checkResult(
        runtime,
        '"5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5"',
      );
    });

    test('hash.sha512 hashes numeric string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha512("12345")');
      checkResult(
        runtime,
        '"3627909a29c31381a071ec27f7c9ca97726182aed29a7ddd2e54353322cfb30abb9e3a6df2ac2c20fe23436311d678564d0c8d305930575f60e2d3d048184d79"',
      );
    });

    test('hash.md5 hashes very long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.md5("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")',
      );
      checkResult(runtime, '"36a92cc94a9e0fa21f625f8bfb007adf"');
    });

    test('hash.sha256 hashes very long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha256("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")',
      );
      checkResult(
        runtime,
        '"2816597888e4a0d3a36b82b83316ab32680eb8f00f8cd3b904d681246d285a0e"',
      );
    });

    test('hash.md5 throws InvalidArgumentTypesError for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.md5({"a": 1})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha1 throws InvalidArgumentTypesError for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha1({"a": 1})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha256 throws InvalidArgumentTypesError for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha256({"a": 1})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha512 throws InvalidArgumentTypesError for map argument', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha512({"a": 1})',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha256 hashes unicode string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha256("caf\\u00e9")',
      );
      checkResult(
        runtime,
        '"850f7dc43910ff890f8879c0ed26fe697c93a067ad93a7d50f466a7028a9bf4e"',
      );
    });

    test('hash.sha1 hashes very long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha1("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")',
      );
      checkResult(runtime, '"7f9000257a4918d7072655ea468540cdcbd42e0c"');
    });

    test('hash.sha512 hashes very long string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha512("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")',
      );
      checkResult(
        runtime,
        '"70ff99fd241905992cc3fff2f6e3f562c8719d689bfe0e53cbc75e53286d82d8767aed0959b8c63aadf55b5730babee75ea082e88414700d7507b988c44c47bc"',
      );
    });

    test('hash.md5 rejects carriage return escape', () {
      expect(
        () => getRuntime('main() = hash.md5("a\\rb")'),
        throwsA(isA<InvalidEscapeSequenceError>()),
      );
    });

    test('hash.sha256 rejects carriage return escape', () {
      expect(
        () => getRuntime('main() = hash.sha256("a\\rb")'),
        throwsA(isA<InvalidEscapeSequenceError>()),
      );
    });

    test('hash.md5 hashes mixed case string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5("AbCdEf")');
      checkResult(runtime, '"90469eb9b9ccaa40fa9c7d0c593a7201"');
    });

    test('hash.sha256 hashes mixed case string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha256("AbCdEf")',
      );
      checkResult(
        runtime,
        '"5d2e1239e21be8587a9198ad643db7f758aaa5009a7128e3fe40ab0d8213e0db"',
      );
    });
  });

  group('Hash Output Format', () {
    test('hash.md5 returns 32-character hex string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5("test")');
      final String result = runtime.executeMain();
      // Remove surrounding quotes
      final String hash = result.substring(1, result.length - 1);
      expect(hash.length, equals(32));
      expect(RegExp(r'^[a-f0-9]+$').hasMatch(hash), isTrue);
    });

    test('hash.sha1 returns 40-character hex string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha1("test")');
      final String result = runtime.executeMain();
      final String hash = result.substring(1, result.length - 1);
      expect(hash.length, equals(40));
      expect(RegExp(r'^[a-f0-9]+$').hasMatch(hash), isTrue);
    });

    test('hash.sha256 returns 64-character hex string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha256("test")');
      final String result = runtime.executeMain();
      final String hash = result.substring(1, result.length - 1);
      expect(hash.length, equals(64));
      expect(RegExp(r'^[a-f0-9]+$').hasMatch(hash), isTrue);
    });

    test('hash.sha512 returns 128-character hex string', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha512("test")');
      final String result = runtime.executeMain();
      final String hash = result.substring(1, result.length - 1);
      expect(hash.length, equals(128));
      expect(RegExp(r'^[a-f0-9]+$').hasMatch(hash), isTrue);
    });
  });

  group('Hash Determinism', () {
    test('hash.md5 produces same output for same input', () {
      final RuntimeFacade runtime1 = getRuntime('main() = hash.md5("hello")');
      final RuntimeFacade runtime2 = getRuntime('main() = hash.md5("hello")');
      expect(runtime1.executeMain(), equals(runtime2.executeMain()));
    });

    test('hash.sha256 produces same output for same input', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main() = hash.sha256("hello")',
      );
      final RuntimeFacade runtime2 = getRuntime(
        'main() = hash.sha256("hello")',
      );
      expect(runtime1.executeMain(), equals(runtime2.executeMain()));
    });

    test('hash.md5 produces different output for different inputs', () {
      final RuntimeFacade runtime1 = getRuntime('main() = hash.md5("hello")');
      final RuntimeFacade runtime2 = getRuntime('main() = hash.md5("world")');
      expect(runtime1.executeMain(), isNot(equals(runtime2.executeMain())));
    });

    test('hash.sha256 produces different output for different inputs', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main() = hash.sha256("hello")',
      );
      final RuntimeFacade runtime2 = getRuntime(
        'main() = hash.sha256("world")',
      );
      expect(runtime1.executeMain(), isNot(equals(runtime2.executeMain())));
    });
  });

  group('Hash Composition', () {
    test('hash.md5 works with string concatenation result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.md5(str.concat("hello", " world"))',
      );
      checkResult(runtime, '"5eb63bbbe01eeed093cb22bb8f5acdc3"');
    });

    test('hash.sha256 works with string concatenation result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha256(str.concat("hello", " world"))',
      );
      checkResult(
        runtime,
        '"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"',
      );
    });

    test('hash.md5 can be chained (hash of hash)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.md5(hash.md5("hello"))',
      );
      checkResult(runtime, '"69a329523ce1ec88bf63061863d9cb14"');
    });

    test('hash.sha256 can be chained (hash of hash)', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha256(hash.sha256("hello"))',
      );
      checkResult(
        runtime,
        '"d7914fe546b684688bb95f4f888a92dfc680603a75f23eb823658031fff766d9"',
      );
    });

    test('different hash functions can be composed', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = hash.sha256(hash.md5("hello"))',
      );
      checkResult(
        runtime,
        '"4914e23374bb211e3dca0df7636fefffc7fedd94f1340ae81c7d6c07b7113e9b"',
      );
    });
  });

  group('Hash Additional Error Cases', () {
    test('hash.md5 throws InvalidArgumentTypesError for float argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.md5(3.14)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha256 throws InvalidArgumentTypesError for float argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha256(2.718)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha512 throws InvalidArgumentTypesError for float argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha512(1.618)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('hash.sha1 throws InvalidArgumentTypesError for float argument', () {
      final RuntimeFacade runtime = getRuntime('main() = hash.sha1(0.5)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test(
      'hash.md5 throws InvalidArgumentTypesError for nested list argument',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = hash.md5([[1, 2], [3, 4]])',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );

    test(
      'hash.sha256 throws InvalidArgumentTypesError for empty list argument',
      () {
        final RuntimeFacade runtime = getRuntime('main() = hash.sha256([])');
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );
  });
}
