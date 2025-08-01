part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  const LoadProducts();
}

class LocationChanged extends ProductEvent {
  final String location;
  const LocationChanged(this.location);

  @override
  List<Object> get props => [location];
}

class ApplicationChanged extends ProductEvent {
  final String application;
  const ApplicationChanged(this.application);

  @override
  List<Object> get props => [application];
}

class ProductSelected extends ProductEvent {
  final Product? product;
  const ProductSelected(this.product);

  @override
  List<Object?> get props => [product];
}

// Events for the second product in comparison mode
class ApplicationChanged2 extends ProductEvent {
  final String application;
  const ApplicationChanged2(this.application);

  @override
  List<Object> get props => [application];
}

class ProductSelected2 extends ProductEvent {
  final Product? product;
  const ProductSelected2(this.product);

  @override
  List<Object?> get props => [product];
}

class LocationChanged2 extends ProductEvent {
  final String location;

  const LocationChanged2(this.location);

  @override
  List<Object> get props => [location];
} 