import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:alfalite_configurator/blocs/product/product_bloc.dart';
import 'package:alfalite_configurator/blocs/configuration/configuration_bloc.dart';
import 'package:alfalite_configurator/models/product.dart';
import 'package:alfalite_configurator/models/configuration_result.dart';
import 'package:alfalite_configurator/config/environment.dart';
import 'package:alfalite_configurator/services/http_client_manager.dart';
import 'result_card.dart';
import 'results_grid.dart';
import 'package:alfalite_configurator/widgets/results/screen_preview.dart';

class ResultsPanel extends StatelessWidget {
  final bool isWide;
  final ScrollController scrollController;
  final String resultsUnit;
  final Function(String) onUnitsChanged;
  final ui.Image? screenBackgroundImage;
  final ui.Image? maleImage;
  final ui.Image? femaleImage;
  final AnimationController? arrowAnimationController;

  const ResultsPanel({
    super.key,
    required this.isWide,
    required this.scrollController,
    required this.resultsUnit,
    required this.onUnitsChanged,
    this.screenBackgroundImage,
    this.maleImage,
    this.femaleImage,
    this.arrowAnimationController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigurationBloc, ConfigurationState>(
      builder: (context, configState) {
        final hasResult = configState.result != null;
        final isComparing = configState.isComparing;

        if (!hasResult && !isComparing) {
          return const Center(
              child: Text('Configure a product to see results.'));
        }

        if (isComparing) {
          return _buildComparisonResults(context, configState: configState);
        } else {
          return _buildSingleResult(context, configState: configState);
        }
      },
    );
  }

  Widget _buildSingleResult(BuildContext context,
      {required ConfigurationState configState}) {
    final double imageHeight = isWide ? 90 : 150;
    final double previewHeight = isWide ? 140 : 250;
    final double spacing = isWide ? 10 : 20;

    final result = configState.result;
    final product = configState.product;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Results',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: spacing),
            _buildResultsUnitToggle(context),
            SizedBox(height: spacing),
            _buildProductImage(product, height: imageHeight),
            SizedBox(height: spacing),
            if (result != null)
              ResultsGrid(
                result: result,
                resultsUnit: resultsUnit,
                isWide: isWide,
              ),
            SizedBox(height: spacing),
            const Center(
              child: Text(
                'Screen Preview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            if (result != null)
              ScreenPreview(
                result: result,
                isComparing: false,
                selectedProduct: product,
                screenBackgroundImage: screenBackgroundImage,
                maleImage: maleImage,
                femaleImage: femaleImage,
                viewportHeight: previewHeight,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonResults(BuildContext context,
      {required ConfigurationState configState}) {
    final double verticalSpacing = isWide ? 8 : 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Comparison Results',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: verticalSpacing),
        _buildResultsUnitToggle(context),
        SizedBox(height: verticalSpacing),
        LayoutBuilder(
          builder: (context, constraints) {
            final productColumn1 = _buildProductColumn(context,
                isFirst: true, configState: configState);
            final productColumn2 = _buildProductColumn(context,
                isFirst: false, configState: configState);

            if (constraints.maxWidth > 1020) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: productColumn1),
                  const SizedBox(width: 20),
                  Expanded(child: productColumn2),
                ],
              );
            } else {
              return Stack(
                alignment: Alignment.centerRight,
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 500, child: productColumn1),
                        const VerticalDivider(width: 20, thickness: 1),
                        SizedBox(width: 500, child: productColumn2),
                      ],
                    ),
                  ),
                  _buildHorizontalArrowIndicator(context),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildProductColumn(BuildContext context,
      {required bool isFirst, required ConfigurationState configState}) {
    final double imageHeight = isWide ? 90 : 150;
    final double previewHeight = isWide ? 140 : 250;
    final double spacing = isWide ? 10 : 20;

    final product = isFirst ? configState.product : configState.product2;
    final result = isFirst ? configState.result : configState.result2;

    if (product == null || result == null) {
      return SizedBox(
          width: isWide ? null : 500,
          child: const Center(child: Text('No result')));
    }

    return Column(
      children: [
        _buildProductImage(product, height: imageHeight),
        SizedBox(height: spacing),
        ResultsGrid(
          result: result,
          resultsUnit: resultsUnit,
          isWide: isWide,
        ),
        SizedBox(height: spacing),
        const Center(
          child: Text(
            'Screen Preview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        ScreenPreview(
          result: result,
          isComparing: configState.isComparing,
          selectedProduct: configState.product,
          selectedProduct2: configState.product2,
          result2: configState.result2,
          screenBackgroundImage: screenBackgroundImage,
          maleImage: maleImage,
          femaleImage: femaleImage,
          viewportHeight: previewHeight,
        ),
      ],
    );
  }

  Widget _buildHorizontalArrowIndicator(BuildContext context) {
    final state = context.watch<ConfigurationBloc>().state;
    final isComparing = state.isComparing;
    final showRightArrow = state.showRightArrow;
    
    if (arrowAnimationController == null || !isComparing || !showRightArrow) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: FadeTransition(
            opacity: arrowAnimationController!,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios, size: 30, color: Color(0xFFFC7100)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsUnitToggle(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 40,
        child: ToggleButtons(
          onPressed: (index) {
            final newUnit = ['m', 'ft', 'in'][index];
            onUnitsChanged(newUnit);
          },
          isSelected: [
            resultsUnit == 'm',
            resultsUnit == 'ft',
            resultsUnit == 'in',
          ],
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.black,
          fillColor: Theme.of(context).primaryColor,
          color: Colors.white,
          constraints: const BoxConstraints(minHeight: 40.0, minWidth: 80.0),
          children: const [
            Text('Meters'),
            Text('Feet'),
            Text('Inches'),
          ],
        ),
      ),
    );
  }
}

class _ProductColumnState extends Equatable {
  final Product product;
  final ConfigurationResult result;
  final bool isComparing;
  final Product? selectedProduct1;
  final Product? selectedProduct2;
  final ConfigurationResult? result2;
  final ui.Image? backgroundImage;

  const _ProductColumnState(
    this.product,
    this.result, {
    required this.isComparing,
    this.selectedProduct1,
    this.selectedProduct2,
    this.result2,
    this.backgroundImage,
  });

  @override
  List<Object?> get props => [
        product,
        result,
        isComparing,
        selectedProduct1,
        selectedProduct2,
        result2,
        backgroundImage,
      ];
}

Widget _buildProductImage(Product? product, {required double height}) {
  if (product == null || product.image.isEmpty) {
    return Container(
      height: height,
      color: Colors.grey[800],
      child: const Center(
        child: Text('Image not available',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  final String imageUrl = Environment.getServerUrl(product.image);

  return FutureBuilder<Uint8List?>(
    future: _loadImageWithHttpClient(imageUrl),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          height: height,
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      if (snapshot.hasError || !snapshot.hasData) {
        return Container(
          height: height,
          color: Colors.grey[800],
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Error loading image',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }

      return Image.memory(
        snapshot.data!,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            color: Colors.grey[800],
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Error loading image',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<Uint8List?> _loadImageWithHttpClient(String imageUrl) async {
  try {
    final response = await HttpClientManager.instance.client.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  } catch (e) {
    print('Error loading image: $e');
    return null;
  }
}

class _ScreenPreviewState extends Equatable {
  final ConfigurationResult? result;
  final bool isComparing;
  final Product? selectedProduct;
  final Product? selectedProduct2;
  final ConfigurationResult? result2;
  final ui.Image? backgroundImage;

  const _ScreenPreviewState(this.result, this.isComparing, this.selectedProduct,
      this.selectedProduct2, this.result2, this.backgroundImage);

  @override
  List<Object?> get props => [
        result,
        isComparing,
        selectedProduct,
        selectedProduct2,
        result2,
        backgroundImage
      ];
}

class _ResultsPanelState extends Equatable {
  final bool isComparing;
  final bool hasResult;

  const _ResultsPanelState(
      {required this.isComparing, required this.hasResult});

  @override
  List<Object?> get props => [isComparing, hasResult];
} 