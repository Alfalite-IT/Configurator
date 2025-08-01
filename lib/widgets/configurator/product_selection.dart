import 'package:alfalite_configurator/blocs/product/product_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/configuration/configuration_bloc.dart';
import '../../models/product.dart';

class ProductSelection extends StatelessWidget {
  final bool isFirstProduct;

  const ProductSelection({
    super.key,
    required this.isFirstProduct,
  });

  @override
  Widget build(BuildContext context) {
    // Use Bloc for state management for better performance
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.status == ProductStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ProductStatus.failure) {
          return Center(child: Text('Error: ${state.error}'));
        }

        final location = isFirstProduct ? state.selectedLocation : state.selectedLocation2;
        final application = isFirstProduct ? state.selectedApplication : state.selectedApplication2;
        final product = isFirstProduct ? state.selectedProduct : state.selectedProduct2;
        final products = isFirstProduct ? state.filteredProducts : state.filteredProducts2;
        final availableApps = isFirstProduct ? state.availableApplications : state.availableApplications2;

        return _buildUI(
          context,
          location,
          application,
          product,
          products,
          availableApps,
          (val) {
            if (isFirstProduct) {
              context.read<ProductBloc>().add(LocationChanged(val!));
            } else {
              context.read<ProductBloc>().add(LocationChanged2(val!));
            }
          },
          (val) {
            if (isFirstProduct) {
              context.read<ProductBloc>().add(ApplicationChanged(val!));
            } else {
              context.read<ProductBloc>().add(ApplicationChanged2(val!));
            }
          },
          (val) {
            if (isFirstProduct) {
              context.read<ProductBloc>().add(ProductSelected(val));
            } else {
              context.read<ProductBloc>().add(ProductSelected2(val));
            }
          },
        );
      },
    );
  }

  Widget _buildUI(
    BuildContext context,
    String selectedLocation,
    String selectedApplication,
    Product? selectedProduct,
    List<Product> filteredProducts,
    List<String> availableApplications,
    ValueChanged<String?> onLocationChanged,
    ValueChanged<String?> onApplicationChanged,
    ValueChanged<Product?> onProductChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
                isFirstProduct
                    ? 'Product 1 Selection'
                    : 'Product 2 Selection',
                style: Theme.of(context).textTheme.titleMedium),
            if (!isFirstProduct) ...[
              const SizedBox(width: 10),
              BlocBuilder<ConfigurationBloc, ConfigurationState>(
                builder: (context, configState) {
                  final isLocked = configState.isComparisonLocked;
                  return IconButton(
                    splashRadius: 5.0,
                    icon: Icon(isLocked ? Icons.lock : Icons.lock_open),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      context
                          .read<ConfigurationBloc>()
                          .add(ToggleComparisonLock(!isLocked));
                    },
                  );
                },
              )
            ]
          ],
        ),
        const SizedBox(height: 10),
        _buildDropdown('Location', selectedLocation, ['All', 'Indoor', 'Outdoor'], onLocationChanged),
        const SizedBox(height: 10),
        _buildDropdown('Application', selectedApplication, availableApplications, onApplicationChanged),
        const SizedBox(height: 10),
        _buildProductDropdown(selectedProduct, filteredProducts, onProductChanged),
      ],
    );
  }

  Widget _buildDropdown(String label, String selectedValue, List<String> items, ValueChanged<String?> onChanged) {
    // DropdownButtonFormField can throw an exception if the value is not in items.
    final valueInItems = items.contains(selectedValue) ? selectedValue : items.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFF78400), fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: valueInItems,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }

  Widget _buildProductDropdown(Product? selectedProduct, List<Product> products, ValueChanged<Product?> onChanged) {
    final valueInItems = selectedProduct != null && products.contains(selectedProduct) ? selectedProduct : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Product', style: TextStyle(color: Color(0xFFF78400), fontSize: 16)),
        const SizedBox(height: 8),
        DropdownButtonFormField<Product>(
          value: valueInItems,
          items: products.map((product) => DropdownMenuItem(
            value: product,
            child: Text(product.name, overflow: TextOverflow.ellipsis),
          )).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(),
          isExpanded: true,
        ),
      ],
    );
  }
} 