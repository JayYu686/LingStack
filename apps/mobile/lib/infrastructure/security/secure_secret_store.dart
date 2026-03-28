import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureSecretStore {
  const SecureSecretStore(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> writeSecret(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  Future<String?> readSecret(String key) {
    return _storage.read(key: key);
  }

  Future<void> deleteSecret(String key) {
    return _storage.delete(key: key);
  }
}
