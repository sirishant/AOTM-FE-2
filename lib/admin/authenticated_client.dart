import 'package:http/http.dart' as http;
import '../start/auth_storage_service.dart';

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final AuthStorageService _authStorage;

  AuthenticatedClient(this._inner, this._authStorage);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _authStorage.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return _inner.send(request);
  }
}