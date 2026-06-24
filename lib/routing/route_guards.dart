import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';
import 'package:k_passwort/security/keystore/session_manager.dart';

class RouteGuard extends ChangeNotifier {
  RouteGuard(this._ref) {
    _ref.listen(sessionProvider, (_, __) => notifyListeners());
    _ref.listen(vaultProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(_, GoRouterState state) {
    final session = _ref.read(sessionProvider);
    final vault = _ref.read(vaultProvider);
    final path = state.uri.toString();

    final isOnboarding = path.startsWith('/onboarding');
    final isLock = path == Routes.lock;
    final isSwitchVault = path.startsWith(Routes.switchVault);

    // Vault not open: lock screen handles redirect to onboarding if no URI stored
    if (!vault.isOpen && !isOnboarding && !isLock && !isSwitchVault) {
      return Routes.lock;
    }

    // Vault open but session locked → lock screen
    if (vault.isOpen && session == SessionState.locked && !isLock) {
      return Routes.lock;
    }

    // Unlocked and on lock screen → vault
    if (session == SessionState.unlocked && isLock) {
      return Routes.vault;
    }

    return null;
  }
}

final routeGuardProvider = Provider<RouteGuard>((ref) => RouteGuard(ref));
