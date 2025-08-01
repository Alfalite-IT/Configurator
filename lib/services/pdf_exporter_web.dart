import 'dart:html' as html;
import 'dart:typed_data';
import 'package:alfalite_configurator/models/configuration_result.dart';
import 'package:alfalite_configurator/models/product.dart';
import 'package:alfalite_configurator/services/pdf_generator.dart';
import 'package:alfalite_configurator/services/user_data.dart';

class PdfExporter {
  static final PdfGenerator _generator = PdfGenerator();

  static Future<String?> generateAndSaveSingleProductPdf(
      UserData userData, ConfigurationResult result) async {
    try {
      final bytes = await _generator.generateSingleProductPdf(userData, result);
      _openPdfInNewTab(bytes);
      return null; // Indicates success
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> generateAndSaveComparativePdf(
      Product product1,
      ConfigurationResult result1,
      Product product2,
      ConfigurationResult result2) async {
    try {
      final bytes = await _generator.generateComparativePdf(
          product1, result1, product2, result2);
      _openPdfInNewTab(bytes);
      return null; // Indicates success
    } catch (e) {
      return e.toString();
    }
  }

  static void _openPdfInNewTab(Uint8List bytes) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    // It's good practice to release the object URL after a short delay.
    Future.delayed(const Duration(seconds: 5), () {
      html.Url.revokeObjectUrl(url);
    });
  }
} 