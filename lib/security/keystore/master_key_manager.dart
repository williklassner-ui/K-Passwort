import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:k_passwort/core/constants/app_constants.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';
import 'package:k_passwort/core/errors/failures.dart';
import 'package:k_passwort/core/utils/secure_random.dart';
import 'package:k_passwort/security/crypto/argon2_kdf.dart';
import 'package:k_passwort/security/crypto/secure_key.dart';
import 'package:k_passwort/security/keystore/android_keystore.dart';

/// Owns the in-memory master key. Never persists it in plaintext.
/// The key is derived at unlock time and zeroed on lock.
class MasterKeyManager {
  MasterKeyManager(this._storage);

  final FlutterSecureStorage _storage;
  SecureKey? _masterKey;

  bool get isUnlocked => _masterKey != null;

  /// Access the current master key — throws if locked.
  SecureKey get masterKey {
    if (_masterKey == null) throw StateError('Vault is locked');
    return _masterKey!;
  }

  /// Derive master key from password (+ optional key-file bytes).
  /// Saves Argon2 salt to secure storage.
  Future<void> unlockWithPassword({
    required String password,
    Uint8List? keyFileBytes,
  }) async {
    final salt = await _getOrCreateSalt();
    final compositePassword = _buildCompositePassword(password, keyFileBytes);
    final key = await Argon2Kdf.derive(password: compositePassword, salt: salt);

    // Zero the composite password immediately
    compositePassword.fillRange(0, compositePassword.length, 0);

    _masterKey?.dispose();
    _masterKey = key;
  }

  /// Unlock via biometric (unwraps key from Android Keystore).
  Future<void> unlockWithBiometric() async {
    final wrappedKey = await _storage.read(key: AppConstants.wrappedKeyStorageKey);
    final iv = await _storage.read(key: AppConstants.wrappedKeyIvStorageKey);

    if (wrappedKey == null || iv == null) {
      throw const BiometricFailure('Kein biometrischer Schlüssel gespeichert');
    }

    _masterKey?.dispose();
    _masterKey = await AndroidKeystore.unwrapKey(wrappedKey: wrappedKey, iv: iv);
  }

  /// Enable biometric unlock: wraps current master key with Android Keystore.
  Future<void> enableBiometric() async {
    if (_masterKey == null) throw StateError('Must be unlocked first');

    await AndroidKeystore.generateKey();
    final wrapped = await AndroidKeystore.wrapKey(_masterKey!);

    await _storage.write(key: AppConstants.wrappedKeyStorageKey, value: wrapped['wrappedKey']);
    await _storage.write(key: AppConstants.wrappedKeyIvStorageKey, value: wrapped['iv']);
  }

  Future<void> disableBiometric() async {
    await AndroidKeystore.deleteKey();
    await _storage.delete(key: AppConstants.wrappedKeyStorageKey);
    await _storage.delete(key: AppConstants.wrappedKeyIvStorageKey);
  }

  Future<bool> isBiometricEnabled() async {
    final key = await _storage.read(key: AppConstants.wrappedKeyStorageKey);
    return key != null;
  }

  void lock() {
    _masterKey?.dispose();
    _masterKey = null;
  }

  Future<Uint8List> _getOrCreateSalt() async {
    final stored = await _storage.read(key: AppConstants.argon2SaltStorageKey);
    if (stored != null) {
      return Uint8List.fromList(stored.codeUnits);
    }
    final salt = SecureRandom.bytes(CryptoConstants.saltLength);
    await _storage.write(
      key: AppConstants.argon2SaltStorageKey,
      value: String.fromCharCodes(salt),
    );
    return salt;
  }

  /// Composite password = SHA-256(password) ++ SHA-256(keyFile) like KeePass.
  String _buildCompositePassword(String password, Uint8List? keyFileBytes) {
    // Simplified: use password + keyFile concatenated (KDBX handles the composite key)
    // In full KDBX implementation, the kdbx package handles this
    if (keyFileBytes == null) return password;
    return password + String.fromCharCodes(keyFileBytes);
  }
}
