import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class HttpClientManager {
  // A private constructor to prevent external instantiation.
  HttpClientManager._privateConstructor();

  // The single, static instance of this class.
  static final HttpClientManager _instance = HttpClientManager._privateConstructor();

  // The static method to access the instance.
  static HttpClientManager get instance => _instance;

  // The long-lived HTTP client.
  http.Client? _client;

  http.Client get client {
    if (_client == null) {
      final ioc = HttpClient();
      // Allow self-signed certificates in development
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        ioc.badCertificateCallback = (cert, host, port) => true;
      }
      _client = IOClient(ioc);
    }
    return _client!;
  }

  // Optional: A method to close the client when the app is disposed.
  void close() {
    _client?.close();
    _client = null;
  }
} 