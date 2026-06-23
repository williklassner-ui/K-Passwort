import 'dart:typed_data';
import 'package:pointycastle/pointycastle.dart';
import 'package:k_passwort/security/crypto/secure_key.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';

/// Key derivation using PBKDF2-SHA256 (pointycastle 3.x compatible).
/// Argon2id is used internally by the kdbx package for vault operations.
class Argon2Kdf {
  static Future<SecureKey> derive({
    required String password,
    required Uint8List salt,
    int? memory,
    int? iterations,
    int? parallelism,
  }) async {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(
      salt,
      (iterations ?? CryptoConstants.argon2Iterations) * 50000,
      CryptoConstants.keyLength,
    ));
    final passwordBytes = Uint8List.fromList(password.codeUnits);
    final output = pbkdf2.process(passwordBytes);
    passwordBytes.fillRange(0, passwordBytes.length, 0);
    return SecureKey(output);
  }
}
