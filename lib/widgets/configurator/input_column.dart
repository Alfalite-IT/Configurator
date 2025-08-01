import 'package:flutter/material.dart';
import 'package:alfalite_configurator/blocs/configuration/configuration_bloc.dart';
import 'package:alfalite_configurator/blocs/product/product_bloc.dart';
import 'package:alfalite_configurator/widgets/configurator/parameter_sliders.dart';
import 'package:alfalite_configurator/widgets/configurator/configuration_mode_toggle.dart';
import 'package:alfalite_configurator/widgets/configurator/product_selection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InputColumn extends StatelessWidget {
  final bool isFirstProduct;
  final TextEditingController topValueController;
  final TextEditingController bottomValueController;

  const InputColumn({
    super.key,
    required this.isFirstProduct,
    required this.topValueController,
    required this.bottomValueController,
  });

  @override
  Widget build(BuildContext context) {
    if (isFirstProduct) {
      return _buildFirstProductColumn(context);
    } else {
      return _buildSecondProductColumn(context);
    }
  }

  Widget _buildFirstProductColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state.selectedProduct != null) {
              context
                  .read<ConfigurationBloc>()
                  .add(ProductChanged(state.selectedProduct!));
            }
          },
          child: const ProductSelection(isFirstProduct: true),
        ),
        const SizedBox(height: 16),
        const ConfigurationModeToggle(),
        const SizedBox(height: 16),
        ParameterSliders(
          topValueController: topValueController,
          bottomValueController: bottomValueController,
        )
      ],
    );
  }

  Widget _buildSecondProductColumn(BuildContext context) {
    return BlocBuilder<ConfigurationBloc, ConfigurationState>(
      builder: (context, configState) {
        final isLocked = configState.isComparisonLocked;

        final controls = GestureDetector(
          onTap: isLocked
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          const Text('Please Unlock Product 2 to make changes'),
                      backgroundColor: Theme.of(context).primaryColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              : null,
          child: AbsorbPointer(
            absorbing: isLocked,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const ConfigurationModeToggle(isLocked: false, isSecond: true),
                const SizedBox(height: 16),
                ParameterSliders(
                  topValueController: topValueController,
                  bottomValueController: bottomValueController,
                  isSecond: true,
                ),
              ],
            ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocListener<ProductBloc, ProductState>(
              listener: (context, state) {
                if (state.selectedProduct2 != null) {
                  context
                      .read<ConfigurationBloc>()
                      .add(Product2Changed(state.selectedProduct2!));
                }
              },
              child: const ProductSelection(isFirstProduct: false),
            ),
            controls,
          ],
        );
      },
    );
  }
} 