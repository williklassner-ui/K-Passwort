import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Checks passwords against Have I Been Pwned using k-anonymity.
/// Only the first 5 chars of the SHA-1 hash are sent — never the password.
class HibpChecker {
  static const _baseUrl = 'https://api.pwnedpasswords.com/range/';

  static Future<int> checkPassword(String password) async {
    final hash = sha1.convert(utf8.encode(password)).toString().toUpperCase();
    final prefix = hash.substring(0, 5);
    final suffix = hash.substring(5);

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$prefix'),
        headers: {'Add-Padding': 'true'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return -1;

      final lines = response.body.split('\n');
      for (final line in lines) {
        final parts = line.split(':');
        if (parts.length == 2 && parts[0].trim() == suffix) {
          return int.tryParse(parts[1].trim()) ?? 0;
        }
      }
      return 0;
    } catch (_) {
      return -1; // -1 = check failed (offline or error)
    }
  }
}
