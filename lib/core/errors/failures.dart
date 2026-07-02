abstract class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

class WrongPasswordFailure extends Failure {
  const WrongPasswordFailure() : super('Falsches Master-Passwort');
}

class CorruptedVaultFailure extends Failure {
  const CorruptedVaultFailure([String? detail])
      : super(detail == null
            ? 'Vault-Datei ist beschädigt oder wurde manipuliert'
            : 'Vault-Datei ist beschädigt oder wurde manipuliert: $detail');
}

class VaultNotFoundFailure extends Failure {
  const VaultNotFoundFailure() : super('Vault-Datei nicht gefunden');
}

class BiometricFailure extends Failure {
  const BiometricFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class SyncFailure extends Failure {
  const SyncFailure(super.message);
}

class CryptoFailure extends Failure {
  const CryptoFailure(super.message);
}
