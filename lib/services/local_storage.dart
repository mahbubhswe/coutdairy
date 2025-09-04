import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  static final GetStorage _storage = GetStorage();

  static Future<void> init() async {
    await GetStorage.init();
  }

  static GetStorage get getStorage => _storage;

  static void write(String key, dynamic value) {
    _storage.write(key, value);
  }

  static dynamic read(String key) {
    return _storage.read(key);
  }
}
