import 'dart:math';

import 'package:alfalite_configurator/models/configuration_result.dart';
import 'package:alfalite_configurator/models/product.dart';
import 'package:flutter/foundation.dart';

class CalculationParams {
  final Product product;
  final String units;
  final Map<String, double> params;

  CalculationParams({
    required this.product,
    required this.units,
    required this.params,
  });
}

ConfigurationResult _calculateConfigurationIsolate(CalculationParams calcParams) {
  final product = calcParams.product;
  final units = calcParams.units;
  final params = calcParams.params;
  final tileWidthMm = product.width;
  final tileHeightMm = product.height;
  int tilesH = 0;
  int tilesV = 0;
  bool wasCappedH = false;
  bool wasCappedV = false;
  double? cappedWidth;
  double? cappedHeight;
  double? cappedDiagonal;
  double? cappedSurface;

  if (params.containsKey('tiles_horizontal') &&
      params.containsKey('tiles_vertical')) {
    tilesH = params['tiles_horizontal']!.toInt();
    tilesV = params['tiles_vertical']!.toInt();
    if (tilesH > 100) {
      tilesH = 100;
      wasCappedH = true;
    }
    if (tilesV > 100) {
      tilesV = 100;
      wasCappedV = true;
    }
  } else if (params.containsKey('width') && params.containsKey('height')) {
    final widthMm = _convertToMm(params['width']!, units);
    final heightMm = _convertToMm(params['height']!, units);
    tilesH = (widthMm / tileWidthMm).ceil();
    tilesV = (heightMm / tileHeightMm).ceil();

    if (tilesH > 100) {
      wasCappedH = true;
      tilesH = 100;
      cappedWidth = _convertFromMm(100 * tileWidthMm, units);
    }
    if (tilesV > 100) {
      wasCappedV = true;
      tilesV = 100;
      cappedHeight = _convertFromMm(100 * tileHeightMm, units);
    }
  } else if (params.containsKey('tiles_horizontal') &&
      params.containsKey('height')) {
    tilesH = params['tiles_horizontal']!.toInt();
    if (tilesH > 100) {
      tilesH = 100;
      wasCappedH = true;
    }
    final heightMm = _convertToMm(params['height']!, units);
    tilesV = (heightMm / tileHeightMm).ceil();
    if (tilesV > 100) {
      wasCappedV = true;
      tilesV = 100;
      cappedHeight = _convertFromMm(100 * tileHeightMm, units);
    }
  } else if (params.containsKey('tiles_vertical') &&
      params.containsKey('width')) {
    tilesV = params['tiles_vertical']!.toInt();
    if (tilesV > 100) {
      tilesV = 100;
      wasCappedV = true;
    }
    final widthMm = _convertToMm(params['width']!, units);
    tilesH = (widthMm / tileWidthMm).ceil();
    if (tilesH > 100) {
      wasCappedH = true;
      tilesH = 100;
      cappedWidth = _convertFromMm(100 * tileWidthMm, units);
    }
  } else if (params.containsKey('diagonal') &&
      params.containsKey('aspect_ratio')) {
    final diagonalMm = _convertToMm(params['diagonal']!, units);
    final aspectRatio = params['aspect_ratio']!;
    final heightMm = sqrt(pow(diagonalMm, 2) / (pow(aspectRatio, 2) + 1));
    final widthMm = heightMm * aspectRatio;

    int provTilesH = (widthMm / tileWidthMm).ceil();
    int provTilesV = (heightMm / tileHeightMm).ceil();

    double scaleFactor = 1.0;
    if (provTilesH > 100) {
      scaleFactor = max(scaleFactor, provTilesH / 100.0);
    }
    if (provTilesV > 100) {
      scaleFactor = max(scaleFactor, provTilesV / 100.0);
    }

    if (scaleFactor > 1.0) {
      if (provTilesH / 100.0 == scaleFactor) wasCappedH = true;
      if (provTilesV / 100.0 == scaleFactor) wasCappedV = true;

      final newWidthMm = widthMm / scaleFactor;
      final newHeightMm = heightMm / scaleFactor;
      tilesH = (newWidthMm / tileWidthMm).ceil();
      tilesV = (newHeightMm / tileHeightMm).ceil();
      final newDiagonalMm = sqrt(pow(newWidthMm, 2) + pow(newHeightMm, 2));
      cappedDiagonal = _convertFromMm(newDiagonalMm, units);
    } else {
      tilesH = provTilesH;
      tilesV = provTilesV;
    }
  } else if (params.containsKey('surface') &&
      params.containsKey('aspect_ratio')) {
    final surfaceValue = params['surface']!;
    final aspectRatio = params['aspect_ratio']!;
    double surfaceMm2;
    if (units == 'ft') {
      surfaceMm2 = surfaceValue * 304.8 * 304.8;
    } else {
      surfaceMm2 = surfaceValue * 1000 * 1000;
    }
    final heightMm = sqrt(surfaceMm2 / aspectRatio);
    final widthMm = heightMm * aspectRatio;

    int provTilesH = (widthMm / tileWidthMm).ceil();
    int provTilesV = (heightMm / tileHeightMm).ceil();

    double scaleFactor = 1.0;
    if (provTilesH > 100) {
      scaleFactor = max(scaleFactor, provTilesH / 100.0);
    }
    if (provTilesV > 100) {
      scaleFactor = max(scaleFactor, provTilesV / 100.0);
    }

    if (scaleFactor > 1.0) {
      if (provTilesH / 100.0 == scaleFactor) wasCappedH = true;
      if (provTilesV / 100.0 == scaleFactor) wasCappedV = true;

      final newSurfaceMm2 = surfaceMm2 / pow(scaleFactor, 2);
      final newHeightMm = sqrt(newSurfaceMm2 / aspectRatio);
      final newWidthMm = newHeightMm * aspectRatio;
      tilesH = (newWidthMm / tileWidthMm).ceil();
      tilesV = (newHeightMm / tileHeightMm).ceil();

      if (units == 'ft') {
        cappedSurface = newSurfaceMm2 / (304.8 * 304.8);
      } else {
        cappedSurface = newSurfaceMm2 / (1000 * 1000);
      }
    } else {
      tilesH = provTilesH;
      tilesV = provTilesV;
    }
  }

  if (tilesH == 0 && tilesV == 0) {
    if (params.containsKey('tiles_horizontal')) {
      tilesH = params['tiles_horizontal']!.toInt();
      tilesV = 1;
    } else if (params.containsKey('tiles_vertical')) {
      tilesV = params['tiles_vertical']!.toInt();
      tilesH = 1;
    } else if (params.containsKey('width')) {
      final widthMm = _convertToMm(params['width']!, units);
      tilesH = (widthMm / tileWidthMm).ceil();
      tilesV = 1;
    } else if (params.containsKey('height')) {
      final heightMm = _convertToMm(params['height']!, units);
      tilesV = (heightMm / tileHeightMm).ceil();
      tilesH = 1;
    }
  }

  if (tilesH <= 0) tilesH = 1;
  if (tilesV <= 0) tilesV = 1;

  int totalTiles = tilesH * tilesV;
  double widthM = (tilesH * product.width) / 1000.0;
  double heightM = (tilesV * product.height) / 1000.0;
  int resolutionW = tilesH * product.horizontal;
  int resolutionH = tilesV * product.vertical;
  double surfaceArea = widthM * heightM;
  double diagonalMeters = sqrt(pow(widthM, 2) + pow(heightM, 2));
  int commonDivisor = _gcd(resolutionW, resolutionH);
  String aspectRatioString =
      '${resolutionW ~/ commonDivisor}:${resolutionH ~/ commonDivisor}';

  double maxPower = totalTiles * product.consumption;
  double avgPower = maxPower * 0.35;
  double totalWeight = totalTiles * product.weight;
  String optViewDistance =
      '${(product.pixelPitch).toStringAsFixed(1)}m / ${(product.pixelPitch * 3.28).toStringAsFixed(1)}ft';

  return ConfigurationResult(
    productId: product.id,
    productName: product.name,
    resolution: '${resolutionW}x$resolutionH',
    width: widthM,
    height: heightM,
    diagonal: diagonalMeters,
    aspectRatio: aspectRatioString,
    surface: surfaceArea,
    maxPower: '${maxPower.toStringAsFixed(2)} kW',
    avgPower: '${avgPower.toStringAsFixed(2)} kW',
    weight: '${totalWeight.toStringAsFixed(2)} kg',
    optViewDistance: optViewDistance,
    brightness: '${product.brightness} nits',
    totalTiles: totalTiles.toString(),
    tilesHorizontal: tilesH,
    tilesVertical: tilesV,
    wasCappedH: wasCappedH,
    wasCappedV: wasCappedV,
    cappedWidth: cappedWidth,
    cappedHeight: cappedHeight,
    cappedDiagonal: cappedDiagonal,
    cappedSurface: cappedSurface,
    refreshRate: product.refreshRate,
    contrast: product.contrast,
    visionAngle: product.visionAngle,
    redundancy: product.redundancy,
    totalWeight: totalWeight,
    curvedVersion: product.curvedVersion,
    opticalMultilayerInjection: product.opticalMultilayerInjection,
  );
}

int _gcd(int a, int b) {
  return b == 0 ? a : _gcd(b, a % b);
}

double _convertToMm(double value, String fromUnits) {
  if (fromUnits == 'ft') {
    return value * 304.8;
  }
  return value * 1000;
}

double _convertFromMm(double value, String toUnits) {
  if (toUnits == 'ft') {
    return value / 304.8;
  }
  return value / 1000;
}

class CalculationService {
  Future<ConfigurationResult> calculate({
    required Product product,
    required String units,
    required Map<String, double> params,
  }) async {
    return compute(
        _calculateConfigurationIsolate,
        CalculationParams(
          product: product,
          units: units,
          params: params,
        ));
  }
} 