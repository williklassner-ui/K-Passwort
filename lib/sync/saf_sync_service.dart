import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:k_passwort/core/constants/app_constants.dart';
import 'package:k_passwort/data/storage/saf_storage.dart';

enum SyncStatus { idle, syncing, success, error, noVault }

class SyncStateNotifier extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => SyncStatus.idle;

  /// Read the current vault URI from secure storage.
  static Future<String?> getSavedVaultUri() async {
    const storage = FlutterSecureStorage();
    return storage.read(key: AppConstants.vaultUriStorageKey);
  }

  static Future<void> saveVaultUri(String uri) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: AppConstants.vaultUriStorageKey, value: uri);
  }

  /// Compare remote file timestamp with last-known timestamp.
  /// If remote is newer, returns the remote bytes; otherwise returns null.
  Future<Uint8List?> checkForRemoteUpdate(String uri) async {
    state = SyncStatus.syncing;
    try {
      final info = await SafStorage.getFileInfo(uri);
      if (info == null) {
        state = SyncStatus.error;
        return null;
      }
      // In a full implementation, compare with locally cached timestamp
      // For now, always read remote and let the KDBX merger decide
      final bytes = await SafStorage.readFile(uri);
      state = SyncStatus.success;
      return bytes;
    } catch (_) {
      state = SyncStatus.error;
      return null;
    }
  }
}

final syncStateProvider = NotifierProvider<SyncStateNotifier, SyncStatus>(
  SyncStateNotifier.new,
);
