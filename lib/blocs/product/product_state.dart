part of 'product_bloc.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.availableApplications = const ['All'],
    this.selectedLocation = 'All',
    this.selectedApplication = 'All',
    this.selectedProduct,
    // Product 2
    this.selectedLocation2 = 'All',
    this.selectedApplication2 = 'All',
    this.selectedProduct2,
    this.filteredProducts2 = const [],
    this.availableApplications2 = const ['All'],
    this.error = '',
  });

  final ProductStatus status;
  final String error;
  final List<Product> allProducts;

  // Product 1 State
  final List<Product> filteredProducts;
  final List<String> availableApplications;
  final String selectedLocation;
  final String selectedApplication;
  final Product? selectedProduct;

  // Product 2 State
  final List<Product> filteredProducts2;
  final List<String> availableApplications2;
  final String selectedLocation2;
  final String selectedApplication2;
  final Product? selectedProduct2;

  ProductState copyWith({
    ProductStatus? status,
    String? error,
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    List<String>? availableApplications,
    String? selectedLocation,
    String? selectedApplication,
    Product? selectedProduct,
    // Product 2
    List<Product>? filteredProducts2,
    List<String>? availableApplications2,
    String? selectedLocation2,
    String? selectedApplication2,
    Product? selectedProduct2,
  }) {
    return ProductState(
      status: status ?? this.status,
      error: error ?? this.error,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      availableApplications:
          availableApplications ?? this.availableApplications,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedApplication: selectedApplication ?? this.selectedApplication,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      // Product 2
      filteredProducts2: filteredProducts2 ?? this.filteredProducts2,
      availableApplications2:
          availableApplications2 ?? this.availableApplications2,
      selectedLocation2: selectedLocation2 ?? this.selectedLocation2,
      selectedApplication2: selectedApplication2 ?? this.selectedApplication2,
      selectedProduct2: selectedProduct2 ?? this.selectedProduct2,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        allProducts,
        filteredProducts,
        availableApplications,
        selectedLocation,
        selectedApplication,
        selectedProduct,
        // Product 2
        filteredProducts2,
        availableApplications2,
        selectedLocation2,
        selectedApplication2,
        selectedProduct2,
      ];
} 