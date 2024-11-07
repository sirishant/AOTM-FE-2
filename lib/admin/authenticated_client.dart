import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http/io_client.dart';
import '../start/auth_storage_service.dart';

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final AuthStorageService _authStorage;

  AuthenticatedClient(http.Client inner, this._authStorage)
      : _inner = IOClient(HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _authStorage.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return _inner.send(request);
  }
}