import 'package:flutter/material.dart';

import 'package:alfalite_configurator/models/configuration_result.dart';
import 'package:alfalite_configurator/services/units_service.dart';
import 'package:alfalite_configurator/widgets/results/result_card.dart';

class ResultsGrid extends StatelessWidget {
  final ConfigurationResult result;
  final String resultsUnit;
  final bool isWide;

  const ResultsGrid({
    super.key,
    required this.result,
    required this.resultsUnit,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    double diagonalValue = result.diagonal;
    double surfaceValue = result.surface;
    double widthValue = result.width;
    double heightValue = result.height;
    String lengthUnit = 'm';
    String surfaceUnit = 'm²';

    if (resultsUnit == 'ft') {
      diagonalValue = UnitsService.convertMetersToFeet(result.diagonal);
      surfaceValue = UnitsService.convertSqMetersToSqFeet(result.surface);
      widthValue = UnitsService.convertMetersToFeet(result.width);
      heightValue = UnitsService.convertMetersToFeet(result.height);
      lengthUnit = 'ft';
      surfaceUnit = 'ft²';
    } else if (resultsUnit == 'in') {
      diagonalValue = UnitsService.convertMetersToInches(result.diagonal);
      surfaceValue = UnitsService.convertSqMetersToSqInches(result.surface);
      widthValue = UnitsService.convertMetersToInches(result.width);
      heightValue = UnitsService.convertMetersToInches(result.height);
      lengthUnit = 'in';
      surfaceUnit = 'in²';
    }

    final double roundedMetricDiagonal = double.parse(result.diagonal.toStringAsFixed(2));
    final double diagonalInches = UnitsService.convertMetersToInches(roundedMetricDiagonal);
    final double cardAspectRatio = isWide ? 4.2 : 3;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: cardAspectRatio,
      children: [
        _buildResultCard('Product Name', result.productName, isWide: isWide),
        _buildResultCard('Resolution', result.resolution, isWide: isWide),
        _buildResultCard('Dimensions', '${widthValue.toStringAsFixed(2)}x${heightValue.toStringAsFixed(2)} $lengthUnit', isWide: isWide),
        _buildResultCard('Diagonal', '${diagonalInches.toStringAsFixed(2)} in', isWide: isWide),
        _buildResultCard('Aspect Ratio', result.aspectRatio, isWide: isWide),
        _buildResultCard('Surface Area', '${surfaceValue.toStringAsFixed(2)} $surfaceUnit', isWide: isWide),
        _buildResultCard('Max Power', result.maxPower, isWide: isWide),
        _buildResultCard('Avg. Power', result.avgPower, isWide: isWide),
        _buildResultCard('Weight', result.weight, isWide: isWide),
        _buildResultCard('Opt. View Distance', result.optViewDistance, isWide: isWide),
        if (result.refreshRate != null)
          _buildResultCard('Refresh Rate', '${result.refreshRate} Hz', isWide: isWide),
        if (result.contrast != null)
          _buildResultCard('Contrast', result.contrast!, isWide: isWide),
        if (result.visionAngle != null && result.visionAngle!.isNotEmpty)
          _buildResultCard('Vision Angle', result.visionAngle!, tooltipMessage: 'Horizontal/Vertical', isWide: isWide),
        if (result.redundancy != null)
          _buildResultCard('Redundancy (Optional)', result.redundancy!, tooltipMessage: 'Receiving Card and Power supply', isWide: isWide),
        if (result.curvedVersion != null && result.curvedVersion!.isNotEmpty)
          _buildResultCard('Curved Version', result.curvedVersion!, isWide: isWide),
        if (result.opticalMultilayerInjection != null && result.opticalMultilayerInjection!.isNotEmpty)
          _buildResultCard('Optical Multilayer', result.opticalMultilayerInjection!,
              tooltipMessage: _getOpticalMultilayerTooltip(result.productId), isWide: isWide),
        _buildResultCard('Brightness', '${result.brightness}', isWide: isWide),
        _buildResultCard('Total Tiles', result.totalTiles.toString(), isWide: isWide),
      ],
    );
  }
}

Widget _buildResultCard(String label, String value, {bool isHighlight = false, String? tooltipMessage, bool isWide = false}) {
  return ResultCard(
    label: label,
    value: value,
    isHighlight: isHighlight,
    tooltipMessage: tooltipMessage,
    isWide: isWide,
  );
}

String? _getOpticalMultilayerTooltip(int productId) {
  if ((productId >= 2 && productId <= 10) || (productId >= 11 && productId <= 19)) {
    return 'ORIM';
  }
  if ((productId >= 32 && productId <= 35) || (productId >= 47 && productId <= 51)) {
    return 'Matix Alfa COB/Matix Alfa MIB';
  }
  return null;
} 