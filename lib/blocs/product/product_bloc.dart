import 'package:alfalite_configurator/api/product_repository.dart';
import 'package:alfalite_configurator/models/product.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(const ProductState()) {
    on<LoadProducts>(_onLoadProducts);
    on<LocationChanged>(_onLocationChanged);
    on<ApplicationChanged>(_onApplicationChanged);
    on<ProductSelected>(_onProductSelected);
    on<LocationChanged2>(_onLocationChanged2);
    on<ApplicationChanged2>(_onApplicationChanged2);
    on<ProductSelected2>(_onProductSelected2);
  }

  void _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final products = await _productRepository.fetchProducts();
      final allApps = products
          .expand((p) =>
              p.application.map((a) => a[0].toUpperCase() + a.substring(1).toLowerCase()))
          .toSet()
          .toList();
      allApps.sort();

      emit(state.copyWith(
        status: ProductStatus.success,
        allProducts: products,
        filteredProducts: products,
        filteredProducts2: products,
        selectedProduct: products.isNotEmpty ? products.first : null,
        selectedProduct2: products.isNotEmpty ? products.first : null,
        availableApplications: ['All', ...allApps],
        availableApplications2: ['All', ...allApps],
      ));
    } catch (e) {
      emit(state.copyWith(status: ProductStatus.failure, error: e.toString()));
    }
  }

  void _onLocationChanged(
      LocationChanged event, Emitter<ProductState> emit) {
    final filtered =
        _filterProducts(state, event.location, 'All', state.allProducts);
    emit(state.copyWith(
        selectedLocation: event.location,
        selectedApplication: 'All',
        filteredProducts: filtered,
        selectedProduct: filtered.isNotEmpty ? filtered.first : null));
  }

  void _onApplicationChanged(
      ApplicationChanged event, Emitter<ProductState> emit) {
    final filtered = _filterProducts(
        state, state.selectedLocation, event.application, state.allProducts);
    emit(state.copyWith(
        selectedApplication: event.application,
        filteredProducts: filtered,
        selectedProduct: filtered.isNotEmpty ? filtered.first : null));
  }

  void _onProductSelected(ProductSelected event, Emitter<ProductState> emit) {
    emit(state.copyWith(selectedProduct: event.product));
  }

  // Event handlers for second product
  void _onLocationChanged2(
      LocationChanged2 event, Emitter<ProductState> emit) {
    final filtered =
        _filterProducts(state, event.location, 'All', state.allProducts);
    emit(state.copyWith(
        selectedLocation2: event.location,
        selectedApplication2: 'All',
        filteredProducts2: filtered,
        selectedProduct2: filtered.isNotEmpty ? filtered.first : null));
  }

  void _onApplicationChanged2(
      ApplicationChanged2 event, Emitter<ProductState> emit) {
    final filtered = _filterProducts(
        state, state.selectedLocation2, event.application, state.allProducts);
    emit(state.copyWith(
        selectedApplication2: event.application,
        filteredProducts2: filtered,
        selectedProduct2: filtered.isNotEmpty ? filtered.first : null));
  }

  void _onProductSelected2(ProductSelected2 event, Emitter<ProductState> emit) {
    emit(state.copyWith(selectedProduct2: event.product));
  }

  List<Product> _filterProducts(ProductState state, String location,
      String application, List<Product> products) {
    List<Product> tempFiltered = products;
    if (location != 'All') {
      tempFiltered =
          tempFiltered.where((p) => p.location == location).toList();
    }
    if (application != 'All') {
      tempFiltered = tempFiltered
          .where((p) => p.application
              .map((a) => a.toLowerCase())
              .contains(application.toLowerCase()))
          .toList();
    }
    return tempFiltered;
  }
} 