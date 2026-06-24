import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:k_passwort/security/crypto/secure_key.dart';

void main() {
  group('SecureKey', () {
    test('holds and returns bytes', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final key = SecureKey(bytes);
      expect(key.bytes, equals([1, 2, 3, 4]));
      expect(key.isDisposed, isFalse);
      key.dispose();
    });

    test('zeroes bytes on dispose', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final key = SecureKey(bytes);
      key.dispose();
      expect(key.isDisposed, isTrue);
      // The original Uint8List should be zeroed
      expect(bytes, equals([0, 0, 0, 0]));
    });

    test('throws on access after dispose', () {
      final key = SecureKey(Uint8List.fromList([1, 2, 3]));
      key.dispose();
      expect(() => key.bytes, throwsStateError);
    });

    test('copy creates independent key', () {
      final original = SecureKey(Uint8List.fromList([10, 20, 30]));
      final copy = original.copy();
      original.dispose();

      expect(copy.bytes, equals([10, 20, 30]));
      copy.dispose();
    });
  });
}
