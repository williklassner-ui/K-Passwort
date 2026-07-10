import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:k_passwort/core/constants/app_constants.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/data/repositories/vault_repository_impl.dart';
import 'package:k_passwort/security/keystore/master_key_manager.dart';

class AutofillPickerScreen extends StatefulWidget {
  const AutofillPickerScreen({super.key});

  @override
  State<AutofillPickerScreen> createState() => _AutofillPickerScreenState();
}

class _AutofillPickerScreenState extends State<AutofillPickerScreen> {
  static const _channel = MethodChannel('com.kpasswort/autofill_picker');

  String? _domain;
  List<VaultEntry> _entries = [];
  bool _loading = true;
  String? _error;

  late final VaultRepositoryImpl _repo;
  late final MasterKeyManager _keyManager;

  @override
  void initState() {
    super.initState();
    _repo = VaultRepositoryImpl();
    _keyManager = MasterKeyManager(const FlutterSecureStorage());
    _init();
  }

  Future<void> _init() async {
    try {
      final ctx = await _channel.invokeMapMethod<String, dynamic>('getContext');
      _domain = ctx?['domain'] as String?;

      final uri = await _getVaultUri();
      if (uri == null) {
        setState(() { _loading = false; _error = 'Kein Tresor konfiguriert'; });
        return;
      }

      if (!await _keyManager.isBiometricEnabled()) {
        setState(() { _loading = false; _error = 'Biometrische Entsperrung nicht eingerichtet'; });
        return;
      }

      final password = await _keyManager.unlockWithBiometric();
      if (password == null) {
        setState(() { _loading = false; _error = 'Biometrische Entsperrung fehlgeschlagen'; });
        return;
      }

      await _repo.open(vaultUri: uri, masterPassword: password);
      _filterEntries();
    } catch (e) {
      setState(() { _loading = false; _error = 'Fehler: $e'; });
    }
  }

  void _filterEntries() {
    final all = _repo.entries;
    final domain = _domain;
    final filtered = (domain != null && domain.isNotEmpty)
        ? all.where((e) => e.url.toLowerCase().contains(domain.toLowerCase())).toList()
        : all;
    setState(() {
      _entries = filtered.isNotEmpty ? filtered : all;
      _loading = false;
    });
  }

  Future<String?> _getVaultUri() async {
    const storage = FlutterSecureStorage();
    return storage.read(key: AppConstants.vaultUriStorageKey);
  }

  Future<void> _fill(VaultEntry entry) async {
    try {
      await _channel.invokeMethod('fillCredentials', {
        'username': entry.username,
        'password': entry.password,
      });
    } catch (_) {}
  }

  Future<void> _cancel() async {
    try {
      await _channel.invokeMethod('cancel');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_domain != null && _domain!.isNotEmpty ? _domain! : 'Eintrag wählen'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancel,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_entries.isEmpty) {
      return const Center(child: Text('Keine passenden Einträge'));
    }
    return ListView.builder(
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Dismissible(
          key: Key(entry.id),
          direction: DismissDirection.startToEnd,
          onDismissed: (_) => _fill(entry),
          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            child: const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Icon(Icons.check, color: Colors.white),
            ),
          ),
          child: ListTile(
            leading: const Icon(Icons.key_rounded),
            title: Text(entry.title),
            subtitle: entry.username.isNotEmpty ? Text(entry.username) : null,
            onTap: () => _fill(entry),
          ),
        );
      },
    );
  }
}
