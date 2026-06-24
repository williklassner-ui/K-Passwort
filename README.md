# K-Passwort

Premium Android Passwortmanager — sicher, privat, kein Server.

## Features

- **KDBX 4.x kompatibel** — öffne deine Vault in KeePass, KeePassXC oder Strongbox
- **AES-256 + Argon2id** — Verschlüsselung und KDF auf KeePass-Niveau
- **Key-File Support** — Zwei-Faktor: Passwort + Key-Datei
- **Biometrisches Entsperren** — via Android Keystore (TEE-gesichert)
- **Android Autofill** — automatisches Ausfüllen in Apps und Browser
- **Google Drive Sync** — ohne API oder Account, dateibasiert via SAF
- **AMOLED Dark UI** — Premium Material 3 Design, Inter + JetBrains Mono
- **HIBP Breach Check** — k-Anonymity Passwort-Prüfung
- **Passwortgenerator** — mit Passphrase-Support

## Sicherheitsarchitektur

```
Master-Passwort (+ optionale Key-Datei)
         │
         ▼ Argon2id (64MB RAM, 2 Iterationen)
    Master Key (32 Byte, nur im RAM)
         │
    KDBX 4.x Datei
    ├── AES-256-CBC Body
    ├── ChaCha20 Inner-Encryption (Passwörter)
    └── HMAC-SHA256 Header-Authentifizierung
```

- Master Key wird bei Sperre auf null gesetzt (zeroed)
- Biometrik wraps den Key im Android Keystore (hardware TEE)
- Screenshots blockiert via FLAG_SECURE
- Zwischenablage löscht sich nach 30 Sekunden automatisch

## Sync via Google Drive (ohne API)

1. Tresor-Speicherort auf einen Google Drive Ordner zeigen (File Picker)
2. Google Drive App synchronisiert die `.kdbx`-Datei automatisch
3. Auf einem zweiten Gerät dieselbe Datei öffnen
4. Kein K-Passwort Account nötig — deine Cloud-App übernimmt alles

## Build

```bash
# Voraussetzungen
flutter sdk >= 3.22.0
Android SDK >= API 26

# Setup
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Fonts herunterladen (Inter + JetBrains Mono)
# Lege die .ttf Dateien in assets/fonts/ ab

# Debug Build
flutter run

# Release Build
flutter build apk --release
flutter build appbundle --release
```

## Projektstruktur

```
lib/
├── security/       # Krypto-Kern: Argon2id, SecureKey, Android Keystore
├── data/           # KDBX Vault, SAF Storage, Repository
├── sync/           # Dateibasierter Sync via SAF URI
├── autofill/       # Android AutofillService Bridge
├── features/       # UI Features (onboarding, auth, vault, generator, settings)
├── routing/        # GoRouter mit Auth-Guard
└── ui/             # Theme, Animationen, wiederverwendbare Widgets
android/
├── autofill/       # KPasswortAutofillService.kt (native AutofillService)
├── crypto/         # BiometricCryptoHelper.kt (Android Keystore)
├── storage/        # SafPlugin.kt (Storage Access Framework)
└── clipboard/      # SecureClipboardPlugin.kt (Auto-Clear)
```

## Lizenzen

MIT License — © 2024 K-Passwort Contributors