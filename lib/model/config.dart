class MeitouConfig {
  static Map<String, dynamic> _config = new Map();
  static dynamic getConfig(String key) {
    return _config[key];
  }

  static void setConfig(String key, value) {
    _config[key] = value;
  }

  static bool containsConfig(String key) {
    return _config.containsKey(key);
  }

  static bool removeConfig(String key) {
    _config.remove(key);
  }
}
