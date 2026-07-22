abstract class AppConstants {
  static const String appName = 'K-Passwort';
  static const String kdbxExtension = '.kdbx';
  static const String defaultVaultName = 'vault.kdbx';

  // Secure storage keys
  static const String wrappedKeyStorageKey = 'kpasswort_wrapped_master_key';
  static const String wrappedKeyIvStorageKey = 'kpasswort_wrapped_key_iv';
  static const String vaultUriStorageKey = 'kpasswort_vault_uri';
  static const String settingsStorageKey = 'kpasswort_settings';
  static const String biometricEnabledKey = 'kpasswort_biometric_enabled';

  // Password generator defaults
  static const int defaultPasswordLength = 20;
  static const bool defaultUseUppercase = true;
  static const bool defaultUseLowercase = true;
  static const bool defaultUseNumbers = true;
  static const bool defaultUseSymbols = true;
  static const String defaultSymbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

  // Passphrase defaults — 6 words from a 2048-word list ≈ 66 bits of entropy.
  static const int defaultPassphraseWords = 6;
  static const String defaultPassphraseSeparator = '-';
}
