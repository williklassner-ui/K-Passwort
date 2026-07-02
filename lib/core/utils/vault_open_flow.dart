import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/data/storage/saf_storage.dart';

/// Opens the SAF file picker directly, then navigates to the master-password
/// screen with the file already selected (skips the redundant file-pick step).
Future<void> pickAndOpenExistingVault(BuildContext context) async {
  final uri = await SafStorage.pickKdbxFile();
  if (uri == null) return;
  final info = await SafStorage.getFileInfo(uri);
  final name = (info?['name'] as String?) ?? 'vault.kdbx';
  if (!context.mounted) return;
  context.go(Uri(
    path: Routes.onboardingOpenVault,
    queryParameters: {'uri': uri, 'name': name},
  ).toString());
}
