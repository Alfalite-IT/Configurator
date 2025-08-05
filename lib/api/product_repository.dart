import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alfalite_configurator/models/product.dart';
import 'package:alfalite_configurator/config/environment.dart';
import 'package:alfalite_configurator/services/http_client_manager.dart';

class ProductRepository {
  final String _baseUrl = Environment.apiBaseUrl;

  Future<List<Product>> fetchProducts() async {
    final response = await HttpClientManager.instance.client.get(Uri.parse('$_baseUrl/products'));

    if (response.statusCode == 200) {
      final List<dynamic> productJson = json.decode(response.body);
      return productJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
} 