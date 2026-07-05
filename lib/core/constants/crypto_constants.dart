abstract class CryptoConstants {
  // Key size
  static const int keyLength = 32; // 256 bits

  // Argon2id parameters for the biometric key-wrapping PBKDF2 derivation
  // (Argon2Kdf.derive() / master_key_manager.dart) — unrelated to the KDBX
  // vault's own KDF below.
  static const int argon2Memory = 65536;      // 64 MB
  static const int argon2Iterations = 2;
  static const int argon2Parallelism = 2;

  // Argon2id parameters for the KDBX vault's own KDF (kdbx_vault.dart
  // create()). The kdbx package's built-in default is only 1 MiB/2/1 —
  // far below OWASP's 19 MiB minimum. Real KeePass/KeePassXC defaults
  // (~1 GiB) are calibrated for desktop CPUs and would take ~50s on phone
  // hardware (confirmed via diagnostics). These values are mobile-scaled:
  // well above the OWASP minimum, but fast enough on a phone.
  static const int vaultArgon2MemoryKib = 262144; // 256 MiB
  static const int vaultArgon2Iterations = 3;
  static const int vaultArgon2Parallelism = 2;

  // AES-GCM
  static const int gcmIvLength = 12;          // 96 bits
  static const int gcmTagLength = 16;         // 128 bits

  // Salt
  static const int saltLength = 32;           // 256 bits

  // Clipboard auto-clear (ms)
  static const int clipboardClearDelayMs = 30000;

  // Session auto-lock (ms)
  static const int autoLockDelayMs = 30000;   // 30 seconds in background

  // KDBX channel name for MethodChannel
  static const String biometricChannel = 'com.kpasswort/biometric';
  static const String safChannel = 'com.kpasswort/saf';
  static const String clipboardChannel = 'com.kpasswort/clipboard';
  static const String autofillChannel = 'com.kpasswort/autofill';
  static const String autofillPickerChannel = 'com.kpasswort/autofill_picker';
  static const String secureScreenChannel = 'com.kpasswort/secure_screen';
}
