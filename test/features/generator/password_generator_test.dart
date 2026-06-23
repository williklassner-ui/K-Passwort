import 'package:flutter_test/flutter_test.dart';
import 'package:k_passwort/features/generator/domain/password_generator.dart';

void main() {
  group('PasswordGenerator', () {
    test('generates password of correct length', () {
      for (final length in [8, 12, 20, 32, 64]) {
        final pw = PasswordGenerator.generate(
          PasswordGeneratorConfig(length: length),
        );
        expect(pw.length, equals(length));
      }
    });

    test('generates unique passwords', () {
      const config = PasswordGeneratorConfig(length: 20);
      final passwords = List.generate(100, (_) => PasswordGenerator.generate(config));
      final unique = passwords.toSet();
      expect(unique.length, greaterThan(95)); // Statistically, should be unique
    });

    test('uppercase only option', () {
      const config = PasswordGeneratorConfig(
        length: 50,
        useUppercase: true,
        useLowercase: false,
        useNumbers: false,
        useSymbols: false,
      );
      final pw = PasswordGenerator.generate(config);
      expect(pw.split('').every((c) => c == c.toUpperCase()), isTrue);
    });

    test('numbers only option', () {
      const config = PasswordGeneratorConfig(
        length: 20,
        useUppercase: false,
        useLowercase: false,
        useNumbers: true,
        useSymbols: false,
      );
      final pw = PasswordGenerator.generate(config);
      expect(pw.split('').every((c) => int.tryParse(c) != null), isTrue);
    });

    test('excludes ambiguous characters when enabled', () {
      const ambiguous = 'Il1O0';
      const config = PasswordGeneratorConfig(
        length: 200,
        excludeAmbiguous: true,
      );
      final pw = PasswordGenerator.generate(config);
      for (final c in ambiguous.split('')) {
        expect(pw.contains(c), isFalse, reason: 'Should not contain $c');
      }
    });

    test('generates passphrase with correct word count', () {
      for (final count in [3, 5, 7]) {
        final phrase = PasswordGenerator.generatePassphrase(wordCount: count);
        expect(phrase.split('-').length, equals(count));
      }
    });
  });
}
