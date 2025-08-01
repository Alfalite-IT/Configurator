import 'package:intl/intl.dart';

class ConfigurationResult {
  final String productName;
  final String resolution;
  final double width;
  final double height;
  final double diagonal;
  final String aspectRatio;
  final double surface;
  final String maxPower;
  final String avgPower;
  final String weight;
  final String optViewDistance;
  final String brightness;
  final String totalTiles;
  final int tilesHorizontal;
  final int tilesVertical;
  final bool wasCappedH;
  final bool wasCappedV;
  final double? cappedWidth;
  final double? cappedHeight;
  final double? cappedDiagonal;
  final double? cappedSurface;
  final double? refreshRate;
  final String? contrast;
  final String? visionAngle;
  final String? redundancy;
  final double totalWeight;
  final String? curvedVersion;
  final String? opticalMultilayerInjection;
  final int productId;

  ConfigurationResult({
    required this.productName,
    required this.resolution,
    required this.width,
    required this.height,
    required this.diagonal,
    required this.aspectRatio,
    required this.surface,
    required this.maxPower,
    required this.avgPower,
    required this.weight,
    required this.optViewDistance,
    required this.brightness,
    required this.totalTiles,
    required this.tilesHorizontal,
    required this.tilesVertical,
    this.wasCappedH = false,
    this.wasCappedV = false,
    this.cappedWidth,
    this.cappedHeight,
    this.cappedDiagonal,
    this.cappedSurface,
    this.refreshRate,
    this.contrast,
    this.visionAngle,
    this.redundancy,
    required this.totalWeight,
    this.curvedVersion,
    this.opticalMultilayerInjection,
    required this.productId,
  });

  Map<String, String> toMap() {
    final format = NumberFormat.decimalPattern('es_ES');
    return {
      'productName': productName,
      'resolution': resolution,
      'dimensions': '${width.toStringAsFixed(2)}x${height.toStringAsFixed(2)}',
      'diagonal': diagonal.toString(),
      'aspectRatio': aspectRatio,
      'surface': surface.toString(),
      'maxPower': maxPower,
      'avgPower': avgPower,
      'weight': weight,
      'optViewDistance': optViewDistance,
      'brightness': brightness,
      'totalTiles': totalTiles,
      'cappedWidth': cappedWidth?.toString() ?? '',
      'cappedHeight': cappedHeight?.toString() ?? '',
      'cappedDiagonal': cappedDiagonal?.toString() ?? '',
      'cappedSurface': cappedSurface?.toString() ?? '',
      'refreshRate': refreshRate?.toStringAsFixed(3).replaceAll('.', ',') ?? '',
      'contrast': contrast ?? '',
      'visionAngle': visionAngle ?? '',
      'redundancy': redundancy ?? '',
      'curvedVersion': curvedVersion ?? '',
      'opticalMultilayerInjection': opticalMultilayerInjection ?? '',
    };
  }
} 