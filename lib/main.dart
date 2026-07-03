import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_passwort/app.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Apply screenshot-blocking preference from previous session
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('screenshot_blocked') ?? false) {
    const MethodChannel(CryptoConstants.secureScreenChannel)
        .invokeMethod('setSecureScreen', {'enabled': true});
  }

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI overlay style (status/nav bar) is set reactively in
  // app.dart based on the current theme mode.

  runApp(const ProviderScope(child: KPasswortApp()));
}

/// Entry point for the Autofill Picker Activity (minimal Flutter UI).
@pragma('vm:entry-point')
void autofillMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AutofillPickerApp()));
}
