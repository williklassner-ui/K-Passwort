import 'package:k_passwort/core/constants/app_constants.dart';
import 'package:k_passwort/core/utils/secure_random.dart';
import 'package:k_passwort/features/generator/domain/passphrase_wordlist.dart';

class PasswordGeneratorConfig {
  const PasswordGeneratorConfig({
    this.length = AppConstants.defaultPasswordLength,
    this.useUppercase = AppConstants.defaultUseUppercase,
    this.useLowercase = AppConstants.defaultUseLowercase,
    this.useNumbers = AppConstants.defaultUseNumbers,
    this.useSymbols = AppConstants.defaultUseSymbols,
    this.symbols = AppConstants.defaultSymbols,
    this.excludeAmbiguous = false,
  });

  final int length;
  final bool useUppercase;
  final bool useLowercase;
  final bool useNumbers;
  final bool useSymbols;
  final String symbols;
  final bool excludeAmbiguous;

  PasswordGeneratorConfig copyWith({
    int? length,
    bool? useUppercase,
    bool? useLowercase,
    bool? useNumbers,
    bool? useSymbols,
    String? symbols,
    bool? excludeAmbiguous,
  }) {
    return PasswordGeneratorConfig(
      length: length ?? this.length,
      useUppercase: useUppercase ?? this.useUppercase,
      useLowercase: useLowercase ?? this.useLowercase,
      useNumbers: useNumbers ?? this.useNumbers,
      useSymbols: useSymbols ?? this.useSymbols,
      symbols: symbols ?? this.symbols,
      excludeAmbiguous: excludeAmbiguous ?? this.excludeAmbiguous,
    );
  }
}

class PasswordGenerator {
  static const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const _numbers = '0123456789';
  static const _ambiguous = 'Il1O0';

  static String generate(PasswordGeneratorConfig config) {
    var charset = '';
    if (config.useUppercase) charset += _upper;
    if (config.useLowercase) charset += _lower;
    if (config.useNumbers) charset += _numbers;
    if (config.useSymbols) charset += config.symbols;

    if (config.excludeAmbiguous) {
      charset = charset.split('').where((c) => !_ambiguous.contains(c)).join();
    }

    if (charset.isEmpty) return '';

    final result = StringBuffer();
    // Ensure at least one character from each enabled group
    final groups = <String>[];
    if (config.useUppercase) groups.add(_upper);
    if (config.useLowercase) groups.add(_lower);
    if (config.useNumbers) groups.add(_numbers);
    if (config.useSymbols) groups.add(config.symbols);

    for (final group in groups) {
      if (result.length < config.length) {
        result.write(group[SecureRandom.nextInt(group.length)]);
      }
    }

    while (result.length < config.length) {
      result.write(charset[SecureRandom.nextInt(charset.length)]);
    }

    // Shuffle
    final chars = result.toString().split('');
    for (var i = chars.length - 1; i > 0; i--) {
      final j = SecureRandom.nextInt(i + 1);
      final tmp = chars[i];
      chars[i] = chars[j];
      chars[j] = tmp;
    }

    return chars.join();
  }

  /// Generates a diceware-style passphrase by drawing [wordCount] words
  /// uniformly (CSPRNG) from [kPassphraseWordlist] (2048 words → 11 bits of
  /// entropy each; the default 6 words ≈ 66 bits).
  static String generatePassphrase({
    int wordCount = AppConstants.defaultPassphraseWords,
    String separator = AppConstants.defaultPassphraseSeparator,
  }) {
    final words = List.generate(wordCount, (_) => _wordlistSample());
    return words.join(separator);
  }

  static String _wordlistSample() =>
      kPassphraseWordlist[SecureRandom.nextInt(kPassphraseWordlist.length)];
}
