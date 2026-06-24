import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';
import 'package:k_passwort/data/models/vault_entry.dart';

/// Wraps SafPlugin.kt via MethodChannel.
class SafStorage {
  static const _channel = MethodChannel(CryptoConstants.safChannel);

  /// Shows the Android file picker to select an existing .kdbx file.
  /// Returns the SAF URI string, or null if cancelled.
  static Future<String?> pickKdbxFile() async {
    return _channel.invokeMethod<String>('pickKdbxFile');
  }

  /// Shows the Android file picker to select any file (for attachments).
  /// Returns a [VaultAttachment] with the file content, or null if cancelled.
  static Future<VaultAttachment?> pickAnyFile() async {
    final result = await _channel.invokeMapMethod<String, dynamic>('pickAnyFile');
    if (result == null) return null;
    final uri = result['uri'] as String;
    final name = result['name'] as String? ?? 'attachment';
    final mimeType = result['mimeType'] as String? ?? 'application/octet-stream';
    final bytes = await readFile(uri);
    if (bytes == null) return null;
    return VaultAttachment(name: name, mimeType: mimeType, bytes: bytes.toList());
  }

  /// Shows the Android file picker to create a new .kdbx file.
  static Future<String?> createKdbxFile(String name) async {
    return _channel.invokeMethod<String>('createKdbxFile', {'name': name});
  }

  /// Read file content from a SAF URI.
  static Future<Uint8List?> readFile(String uri) async {
    return _channel.invokeMethod<Uint8List>('readFile', {'uri': uri});
  }

  /// Write bytes to a SAF URI.
  static Future<bool> writeFile(String uri, Uint8List bytes) async {
    return await _channel.invokeMethod<bool>('writeFile', {
          'uri': uri,
          'bytes': bytes,
        }) ??
        false;
  }

  /// Get metadata about the file (name, lastModified, size).
  static Future<Map<String, dynamic>?> getFileInfo(String uri) async {
    return _channel.invokeMapMethod<String, dynamic>('getFileInfo', {'uri': uri});
  }

  /// Persist SAF permission across app restarts.
  static Future<bool> takePersistablePermission(String uri) async {
    return await _channel.invokeMethod<bool>(
          'takePersistablePermission',
          {'uri': uri},
        ) ??
        false;
  }
}
