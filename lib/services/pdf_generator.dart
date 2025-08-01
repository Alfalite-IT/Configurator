import 'dart:typed_data';
import 'package:alfalite_configurator/models/configuration_result.dart';
import 'package:alfalite_configurator/models/product.dart';
import 'package:alfalite_configurator/services/user_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  Future<Uint8List> generateComparativePdf(Product product1, ConfigurationResult result1, Product product2, ConfigurationResult result2) async {
    final result1Data = result1.toMap();
    final result2Data = result2.toMap();
    final doc = pw.Document();
    final data = <List<String>>[
      ['Resolution', result1Data['resolution']!, result2Data['resolution']!],
      ['Dimensions', result1Data['dimensions']!, result2Data['dimensions']!],
      ['Diagonal', result1Data['diagonal']!, result2Data['diagonal']!],
      ['Aspect Ratio', result1Data['aspectRatio']!, result2Data['aspectRatio']!],
      ['Surface Area', result1Data['surface']!, result2Data['surface']!],
      ['Max Power', result1Data['maxPower']!, result2Data['maxPower']!],
      ['Avg. Power', result1Data['avgPower']!, result2Data['avgPower']!],
      ['Weight', result1Data['weight']!, result2Data['weight']!],
      ['Optimal View Distance', result1Data['optViewDistance']!, result2Data['optViewDistance']!],
      ['Refresh Rate', '${result1Data['refreshRate'] ?? 'N/A'} Hz', '${result2Data['refreshRate'] ?? 'N/A'} Hz'],
      ['Contrast', result1Data['contrast'] ?? 'N/A', result2Data['contrast'] ?? 'N/A'],
      ['Vision Angle', result1Data['visionAngle']!.isNotEmpty ? result1Data['visionAngle']! : 'N/A', result2Data['visionAngle']!.isNotEmpty ? result2Data['visionAngle']! : 'N/A'],
      ['Curved Version', result1Data['curvedVersion'] ?? 'N/A', result2Data['curvedVersion'] ?? 'N/A'],
      ['Optical Multilayer Injection', result1Data['opticalMultilayerInjection'] ?? 'N/A', result2Data['opticalMultilayerInjection'] ?? 'N/A'],
      ['Redundancy (Optional)', result1Data['redundancy'] ?? 'N/A', result2Data['redundancy'] ?? 'N/A'],
      ['Brightness', result1Data['brightness']!, result2Data['brightness']!],
      ['Total Tiles', result1Data['totalTiles']!, result2Data['totalTiles']!],
    ];

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: ['Feature', product1.name, product2.name],
            data: data,
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerRight,
            },
          );
        },
      ),
    );
    return doc.save();
  }

  Future<Uint8List> generateSingleProductPdf(
      UserData userData, ConfigurationResult result) async {
    final logoImageBytes = (await rootBundle.load('assets/images/banner-pdf.png'))
        .buffer
        .asUint8List();
    final femaleFigureImageBytes =
        (await rootBundle.load('assets/images/female_figure.png'))
            .buffer
            .asUint8List();

    final pdf = pw.Document();
    final logoImage = pw.MemoryImage(logoImageBytes);
    final femaleFigureImage = pw.MemoryImage(femaleFigureImageBytes);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(logoImage, width: 150),
              pw.SizedBox(height: 20),
              pw.Text('Custom configuration',
                  style:
                      pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              buildPdfSectionTitle('Customer data'),
              buildPdfDataRow(
                  'Name:', '${userData.firstName} ${userData.lastName}'),
              buildPdfDataRow('Email:', userData.email),
              buildPdfDataRow('Address:', userData.address),
              buildPdfDataRow('City:', userData.city),
              buildPdfDataRow('Country:', userData.country),
              buildPdfDataRow('Company:', userData.company),
              buildPdfDataRow('Phone:', userData.phone),
              buildPdfDataRow('Project name:', userData.projectName),
              buildPdfDataRow('Assembly:', userData.assembly),
              buildPdfDataRow('Application:', userData.application),
              pw.SizedBox(height: 20),
              buildPdfSectionTitle('Configuration data'),
              buildPdfDataRow('Resolution:', result.resolution),
              buildPdfDataRow(
                  'Dimensions:',
                  '${result.width.toStringAsFixed(2)} x ${result.height.toStringAsFixed(2)} x 0.10 m'),
              buildPdfDataRow(
                  'Diagonal:', '${result.diagonal.toStringAsFixed(2)} m'),
              buildPdfDataRow('Aspect ratio:', result.aspectRatio),
              buildPdfDataRow('Surface:', '${result.surface.toStringAsFixed(2)} m2'),
              buildPdfDataRow('Max. power consumption:', result.maxPower),
              buildPdfDataRow('Avg. power consumption:', result.avgPower),
              buildPdfDataRow('Weight:', result.weight),
              buildPdfDataRow('Opt. view distance:', result.optViewDistance),
              buildPdfDataRow('Brightness:', result.brightness),
              buildPdfDataRow(
                  'Tiles horizontal:', result.tilesHorizontal.toString()),
              buildPdfDataRow('Tiles vertical:', result.tilesVertical.toString()),
              pw.SizedBox(height: 20),
              buildPdfSectionTitle('Products'),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                data: <List<String>>[
                  <String>['Product', 'Units'],
                  [result.productName, result.totalTiles],
                ],
              ),
              pw.SizedBox(height: 20),
              buildPdfSectionTitle('Example'),
              pw.SizedBox(
                height: 200,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Image(femaleFigureImage, height: 150),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.CustomPaint(
                          size: const PdfPoint(400, 200),
                          painter: (canvas, size) {
                            drawGrid(canvas, size, result.tilesHorizontal,
                                result.tilesVertical);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  static pw.Widget buildPdfSectionTitle(String title) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1.5)),
      ),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 2),
    );
  }

  static pw.Widget buildPdfDataRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }

  static void drawGrid(
      PdfGraphics canvas, PdfPoint size, int tilesHorizontal, int tilesVertical) {
    if (tilesHorizontal <= 0 || tilesVertical <= 0) return;

    final double tileWidth = size.x / tilesHorizontal;
    final double tileHeight = size.y / tilesVertical;
    canvas.setColor(PdfColors.black);
    canvas.setStrokeColor(PdfColors.black);
    canvas.setLineWidth(0.5);

    for (int i = 0; i <= tilesHorizontal; i++) {
      final double x = i * tileWidth;
      canvas.moveTo(x, 0);
      canvas.lineTo(x, size.y);
      canvas.strokePath();
    }

    for (int j = 0; j <= tilesVertical; j++) {
      final double y = j * tileHeight;
      canvas.moveTo(0, y);
      canvas.lineTo(size.x, y);
      canvas.strokePath();
    }
  }
} 