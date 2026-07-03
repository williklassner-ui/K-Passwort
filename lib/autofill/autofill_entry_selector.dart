import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/secure_text_field.dart';

/// Minimal Flutter UI shown inside the Android AutofillPickerActivity.
/// Communicates with AutofillBridgePlugin via MethodChannel.
class AutofillEntrySelector extends StatefulWidget {
  const AutofillEntrySelector({super.key});

  @override
  State<AutofillEntrySelector> createState() => _AutofillEntrySelectorState();
}

class _AutofillEntrySelectorState extends State<AutofillEntrySelector> {
  static const _channel = MethodChannel(CryptoConstants.autofillPickerChannel);

  List<Map<String, dynamic>> _entries = [];
  String? _domain;
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final context = await _channel.invokeMapMethod<String, dynamic>('getContext');
      final domain = context?['domain'] as String?;

      // In production: call getMatchingEntries on the vault service
      // This requires the vault to be open (biometric auth happens first)
      setState(() {
        _domain = domain;
        _loading = false;
        _entries = []; // Populated from actual vault
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _fill(String username, String password) async {
    await _channel.invokeMethod('fillCredentials', {
      'username': username,
      'password': password,
    });
  }

  Future<void> _cancel() async {
    await _channel.invokeMethod('cancel');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KPasswortColors.surface,
      appBar: AppBar(
        backgroundColor: KPasswortColors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('K-Passwort', style: AppTypography.titleMedium),
            if (_domain != null)
              Text(
                _domain!,
                style: AppTypography.bodySmall.copyWith(color: KPasswortColors.primary),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancel,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Eintrag suchen…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48, color: KPasswortColors.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text(
                              'Keine Einträge für $_domain',
                              style: AppTypography.bodyMedium.copyWith(
                                color: KPasswortColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, i) {
                          final e = _entries[i];
                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: KPasswortColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.lock_outline_rounded,
                                  color: KPasswortColors.primary, size: 20),
                            ),
                            title: Text(e['title'] ?? '', style: AppTypography.titleSmall),
                            subtitle: Text(e['username'] ?? '', style: AppTypography.bodySmall),
                            onTap: () => _fill(e['username'] ?? '', e['password'] ?? ''),
                          )
                              .animate(delay: (i * 40).ms)
                              .fadeIn()
                              .slideX(begin: 0.05);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
