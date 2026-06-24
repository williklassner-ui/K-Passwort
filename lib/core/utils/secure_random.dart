import 'dart:math';
import 'dart:typed_data';

/// Cryptographically secure random number generation.
class SecureRandom {
  static final _random = Random.secure();

  static Uint8List bytes(int length) {
    final result = Uint8List(length);
    for (var i = 0; i < length; i++) {
      result[i] = _random.nextInt(256);
    }
    return result;
  }

  static int nextInt(int max) => _random.nextInt(max);
}
