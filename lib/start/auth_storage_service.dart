import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  static const String _tokenKey = 'auth_token';
  final _storage = const FlutterSecureStorage();

  // Save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Retrieve token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Delete token (for logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Save expiry
  Future<void> saveExpiry(int expiry) async {
    await _storage.write(key: 'auth_expiry', value: expiry.toString());
  }

  // Retrieve expiry
  Future<int?> getExpiry() async {
    final expiry = await _storage.read(key: 'auth_expiry');
    return expiry != null ? int.parse(expiry) : null;
  }

  // Save role
  Future<void> saveRole(String role) async {
    await _storage.write(key: 'auth_role', value: role);
  }

  // Retrieve role
  Future<String?> getRole() async {
    return await _storage.read(key: 'auth_role');
  }

  // Save empId
  Future<void> saveEmpId(int empId) async {
    await _storage.write(key: 'auth_empId', value: empId.toString());
  }

  // Retrieve empId
  Future<int?> getEmpId() async {
    final empId = await _storage.read(key: 'auth_empId');
    return empId != null ? int.parse(empId) : null;
  }

  // Save workshopId
  Future<void> saveWorkshopId(int workshopId) async {
    await _storage.write(key: 'auth_workshopId', value: workshopId.toString());
  }

  // Retrieve workshopId
  Future<int?> getWorkshopId() async {
    final workshopId = await _storage.read(key: 'auth_workshopId');
    return workshopId != null ? int.parse(workshopId) : null;
  }

  // Clear all data
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}