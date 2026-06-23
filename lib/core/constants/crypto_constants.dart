abstract class CryptoConstants {
  // Key size
  static const int keyLength = 32; // 256 bits

  // Argon2id parameters (KeePass KDBX 4 defaults, tuned for ~500ms on mid-range)
  static const int argon2Memory = 65536;      // 64 MB
  static const int argon2Iterations = 2;
  static const int argon2Parallelism = 2;

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
}
