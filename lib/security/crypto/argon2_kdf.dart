import 'dart:typed_data';
import 'package:pointycastle/pointycastle.dart';
import 'package:k_passwort/security/crypto/secure_key.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';

/// Argon2id key derivation — OWASP-recommended, memory-hard.
/// Parameters match KeePass KDBX 4 defaults.
class Argon2Kdf {
  static final _argon2 = Argon2BytesGenerator();

  /// Derive a 32-byte master key from [password] and [salt].
  static Future<SecureKey> derive({
    required String password,
    required Uint8List salt,
    int? memory,
    int? iterations,
    int? parallelism,
  }) async {
    final params = Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      salt,
      desiredKeyLength: CryptoConstants.keyLength,
      iterations: iterations ?? CryptoConstants.argon2Iterations,
      memory: memory ?? CryptoConstants.argon2Memory,
      lanes: parallelism ?? CryptoConstants.argon2Parallelism,
      version: Argon2Parameters.ARGON2_VERSION_13,
    );

    _argon2.init(params);

    final passwordBytes = Uint8List.fromList(password.codeUnits);
    final output = Uint8List(CryptoConstants.keyLength);
    _argon2.generateBytes(passwordBytes, output, 0, output.length);

    // Zero password bytes immediately
    passwordBytes.fillRange(0, passwordBytes.length, 0);

    return SecureKey(output);
  }
}
