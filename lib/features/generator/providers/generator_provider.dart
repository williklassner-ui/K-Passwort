import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_passwort/features/generator/domain/password_generator.dart';

class GeneratorNotifier extends Notifier<PasswordGeneratorConfig> {
  @override
  PasswordGeneratorConfig build() => const PasswordGeneratorConfig();

  void update(PasswordGeneratorConfig config) => state = config;
}

final generatorConfigProvider =
    NotifierProvider<GeneratorNotifier, PasswordGeneratorConfig>(GeneratorNotifier.new);

final generatedPasswordProvider = Provider<String>((ref) {
  final config = ref.watch(generatorConfigProvider);
  return PasswordGenerator.generate(config);
});
