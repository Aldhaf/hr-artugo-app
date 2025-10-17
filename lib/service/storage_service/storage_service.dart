// lib/service/storage_service.dart
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService extends GetxService {
  final _secureStorage = const FlutterSecureStorage();

  static const _keyEmail = 'email';
  static const _keyPassword = 'password';

  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: _keyEmail, value: email);
    await _secureStorage.write(key: _keyPassword, value: password);
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keyEmail);
    await _secureStorage.delete(key: _keyPassword);
  }

  Future<Map<String, String?>> getCredentials() async {
    final email = await _secureStorage.read(key: _keyEmail);
    final password = await _secureStorage.read(key: _keyPassword);
    return {'email': email, 'password': password};
  }
}