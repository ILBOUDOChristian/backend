import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _tokenKey = 'auth_jwt_token';
  static const String _refreshTokenKey = 'auth_jwt_refresh_token';
  static const String _userBoxName = 'user_cache_box';
  static const String _postsBoxName = 'posts_cache_box';
  static const String _todosBoxName = 'todos_cache_box';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late Box<String> _userBox;
  late Box<String> _postsBox;
  late Box<String> _todosBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox<String>(_userBoxName);
    _postsBox = await Hive.openBox<String>(_postsBoxName);
    _todosBox = await Hive.openBox<String>(_todosBoxName);
  }

  // -- Tokens JWT securises ----------------------------------------------
  Future<void> saveTokens({required String token, String? refreshToken}) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    if (refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _userBox.clear();
  }

  // -- Cache utilisateur -------------------------------------------------
  Future<void> saveUserJson(Map<String, dynamic> userMap) async {
    await _userBox.put('current_user', jsonEncode(userMap));
  }

  Map<String, dynamic>? getUserJson() {
    final raw = _userBox.get('current_user');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // -- Cache Posts -------------------------------------------------------
  Future<void> cachePosts(List<Map<String, dynamic>> postsList) async {
    await _postsBox.put('cached_posts_list', jsonEncode(postsList));
  }

  List<Map<String, dynamic>> getCachedPosts() {
    final raw = _postsBox.get('cached_posts_list');
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  // -- Cache Todos -------------------------------------------------------
  Future<void> cacheTodos(List<Map<String, dynamic>> todosList) async {
    await _todosBox.put('cached_todos_list', jsonEncode(todosList));
  }

  List<Map<String, dynamic>> getCachedTodos() {
    final raw = _todosBox.get('cached_todos_list');
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }
}
