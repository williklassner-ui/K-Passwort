import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';
import 'package:k_passwort/security/crypto/secure_key.dart';

class AndroidKeystore {
  static const _channel = MethodChannel(CryptoConstants.biometricChannel);

  static Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> generateKey() async {
    return await _channel.invokeMethod<bool>('generateKey') ?? false;
  }

  /// Wraps [masterKey] using the Android Keystore biometric-backed key.
  /// Returns a map with 'wrappedKey' and 'iv' (both Base64).
  static Future<Map<String, String>> wrapKey(SecureKey masterKey) async {
    final result = await _channel.invokeMapMethod<String, String>('wrapKey', {
      'keyBytes': masterKey.bytes,
    });
    return result ?? (throw PlatformException(code: 'WRAP_FAILED'));
  }

  /// Unwraps using biometric authentication.
  static Future<SecureKey> unwrapKey({
    required String wrappedKey,
    required String iv,
  }) async {
    final result = await _channel.invokeMethod<Uint8List>('unwrapKey', {
      'wrappedKey': wrappedKey,
      'iv': iv,
    });
    if (result == null) throw PlatformException(code: 'UNWRAP_FAILED');
    return SecureKey(result);
  }

  static Future<bool> deleteKey() async {
    return await _channel.invokeMethod<bool>('deleteKey') ?? false;
  }
}
