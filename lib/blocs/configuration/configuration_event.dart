part of 'configuration_bloc.dart';

enum ValueUpdateSource { slider, textField }

abstract class ConfigurationEvent extends Equatable {
  const ConfigurationEvent();

  @override
  List<Object> get props => [];
}

class Calculate extends ConfigurationEvent {
  const Calculate();
}

class ConfigurationModeUpdated extends ConfigurationEvent {
  final ConfigurationMode mode;
  const ConfigurationModeUpdated(this.mode);
  @override
  List<Object> get props => [mode];
}

class TopValueChanged extends ConfigurationEvent {
  final double value;
  final ValueUpdateSource source;

  const TopValueChanged(this.value, this.source);
  @override
  List<Object> get props => [value, source];
}

class BottomValueChanged extends ConfigurationEvent {
  final double value;
  final ValueUpdateSource source;

  const BottomValueChanged(this.value, this.source);
  @override
  List<Object> get props => [value, source];
}

class UnitsChanged extends ConfigurationEvent {
  final String units;
  const UnitsChanged(this.units);
  @override
  List<Object> get props => [units];
}

class ProductChanged extends ConfigurationEvent {
  final Product product;
  const ProductChanged(this.product);
  @override
  List<Object> get props => [product];
}

class ToggleComparisonLock extends ConfigurationEvent {
  final bool isLocked;

  const ToggleComparisonLock(this.isLocked);

  @override
  List<Object> get props => [isLocked];
}

class ToggleComparisonView extends ConfigurationEvent {}

// Events for second product
class Product2Changed extends ConfigurationEvent {
  final Product product;
  const Product2Changed(this.product);
  @override
  List<Object> get props => [product];
}

class TopValueChanged2 extends ConfigurationEvent {
  final double value;
  final ValueUpdateSource source;

  const TopValueChanged2(this.value, this.source);
  @override
  List<Object> get props => [value, source];
}

class BottomValueChanged2 extends ConfigurationEvent {
  final double value;
  final ValueUpdateSource source;

  const BottomValueChanged2(this.value, this.source);
  @override
  List<Object> get props => [value, source];
}

class UnitsChanged2 extends ConfigurationEvent {
  final String units;
  const UnitsChanged2(this.units);
  @override
  List<Object> get props => [units];
}

class Recalculate2 extends ConfigurationEvent {}

class UpdateArrowVisibility extends ConfigurationEvent {
  final bool showDownArrow;
  final bool showRightArrow;

  const UpdateArrowVisibility({
    required this.showDownArrow,
    required this.showRightArrow,
  });

  @override
  List<Object> get props => [showDownArrow, showRightArrow];
}

class ConfigurationModeUpdated2 extends ConfigurationEvent {
  final ConfigurationMode mode;
  const ConfigurationModeUpdated2(this.mode);
  @override
  List<Object> get props => [mode];
} 