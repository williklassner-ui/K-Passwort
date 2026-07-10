import 'package:flutter/material.dart';
import 'package:k_passwort/features/autofill/presentation/autofill_picker_screen.dart';

@pragma('vm:entry-point')
void autofillMain() {
  runApp(const _AutofillPickerApp());
}

class _AutofillPickerApp extends StatelessWidget {
  const _AutofillPickerApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AutofillPickerScreen(),
    );
  }
}
