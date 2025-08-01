import 'dart:io';
import 'dart:typed_data';

import 'package:alfalite_configurator/models/configuration_result.dart';
import 'package:alfalite_configurator/models/product.dart';
import 'package:alfalite_configurator/services/pdf_generator.dart';
import 'package:alfalite_configurator/services/user_data.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PdfExporter {
  static final PdfGenerator _generator = PdfGenerator();

  static Future<String?> generateAndSaveSingleProductPdf(
      UserData userData, ConfigurationResult result) async {
    try {
      final bytes = await _generator.generateSingleProductPdf(userData, result);
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/Alfalite_Configuration.pdf");
      await file.writeAsBytes(bytes);
      final openResult = await OpenFile.open(file.path);

      if (openResult.type != ResultType.done) {
        return 'Could not open file: ${openResult.message}';
      }
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
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/comparative_table.pdf");
      await file.writeAsBytes(bytes);
      final openResult = await OpenFile.open(file.path);

      if (openResult.type != ResultType.done) {
        return 'Could not open file: ${openResult.message}';
      }
      return null; // Indicates success
    } catch (e) {
      return e.toString();
    }
  }
} 