part of 'configuration_bloc.dart';

class ConfigurationState extends Equatable {
  const ConfigurationState({
    this.mode = ConfigurationMode.tiles,
    this.units = 'tiles',
    this.topParam = 'tiles_horizontal',
    this.bottomParam = 'tiles_vertical',
    this.topValue = 1.0,
    this.bottomValue = 1.0,
    this.topSliderMax = 200.0,
    this.bottomSliderMax = 200.0,
    this.result,
    this.cappedResult1,
    this.cappedResult2,
    this.showDownArrow = false,
    this.showRightArrow = false,
    // Second product state
    this.mode2 = ConfigurationMode.tiles,
    this.units2 = 'tiles',
    this.topParam2 = 'tiles_horizontal',
    this.bottomParam2 = 'tiles_vertical',
    this.topValue2 = 1.0,
    this.bottomValue2 = 1.0,
    this.topSliderMax2 = 200.0,
    this.bottomSliderMax2 = 200.0,
    this.result2,
    this.product,
    this.product2,
    this.isComparing = false,
    this.lastUpdateSource1,
    this.lastUpdateSource2,
    this.isComparisonLocked = true,
  });

  final bool isComparing;
  final bool isComparisonLocked;

  // Configuration state
  final ConfigurationMode mode;
  final String units;
  final String topParam;
  final String bottomParam;
  final double topValue;
  final double bottomValue;
  final double topSliderMax;
  final double bottomSliderMax;
  final ValueUpdateSource? lastUpdateSource1;

  // Calculation Result
  final ConfigurationResult? result;
  final ConfigurationResult? cappedResult1;
  final ConfigurationResult? cappedResult2;
  final bool showDownArrow;
  final bool showRightArrow;

  // Second product state
  final ConfigurationMode mode2;
  final String units2;
  final String topParam2;
  final String bottomParam2;
  final double topValue2;
  final double bottomValue2;
  final double topSliderMax2;
  final double bottomSliderMax2;
  final ValueUpdateSource? lastUpdateSource2;
  final ConfigurationResult? result2;

  final Product? product;
  final Product? product2;

  ConfigurationState copyWith({
    bool? isComparing,
    ConfigurationMode? mode,
    String? units,
    String? topParam,
    String? bottomParam,
    double? topValue,
    double? bottomValue,
    double? topSliderMax,
    double? bottomSliderMax,
    ConfigurationResult? result,
    ConfigurationResult? cappedResult1,
    ConfigurationResult? cappedResult2,
    bool? showDownArrow,
    bool? showRightArrow,
    // Second product state
    ConfigurationMode? mode2,
    String? units2,
    String? topParam2,
    String? bottomParam2,
    double? topValue2,
    double? bottomValue2,
    double? topSliderMax2,
    double? bottomSliderMax2,
    ConfigurationResult? result2,
    Product? product,
    Product? product2,
    ValueUpdateSource? lastUpdateSource1,
    ValueUpdateSource? lastUpdateSource2,
    bool? isComparisonLocked,
    bool resetLastUpdateSource = false,
  }) {
    return ConfigurationState(
      isComparing: isComparing ?? this.isComparing,
      mode: mode ?? this.mode,
      units: units ?? this.units,
      topParam: topParam ?? this.topParam,
      bottomParam: bottomParam ?? this.bottomParam,
      topValue: topValue ?? this.topValue,
      bottomValue: bottomValue ?? this.bottomValue,
      topSliderMax: topSliderMax ?? this.topSliderMax,
      bottomSliderMax: bottomSliderMax ?? this.bottomSliderMax,
      result: result ?? this.result,
      cappedResult1: cappedResult1 ?? this.cappedResult1,
      cappedResult2: cappedResult2 ?? this.cappedResult2,
      showDownArrow: showDownArrow ?? this.showDownArrow,
      showRightArrow: showRightArrow ?? this.showRightArrow,
      // Second product state
      mode2: mode2 ?? this.mode2,
      units2: units2 ?? this.units2,
      topParam2: topParam2 ?? this.topParam2,
      bottomParam2: bottomParam2 ?? this.bottomParam2,
      topValue2: topValue2 ?? this.topValue2,
      bottomValue2: bottomValue2 ?? this.bottomValue2,
      topSliderMax2: topSliderMax2 ?? this.topSliderMax2,
      bottomSliderMax2: bottomSliderMax2 ?? this.bottomSliderMax2,
      result2: result2 ?? this.result2,
      product: product ?? this.product,
      product2: product2 ?? this.product2,
      lastUpdateSource1:
          resetLastUpdateSource ? null : lastUpdateSource1 ?? this.lastUpdateSource1,
      lastUpdateSource2:
          resetLastUpdateSource ? null : lastUpdateSource2 ?? this.lastUpdateSource2,
      isComparisonLocked: isComparisonLocked ?? this.isComparisonLocked,
    );
  }

  @override
  List<Object?> get props => [
        isComparing,
        mode,
        units,
        topParam,
        bottomParam,
        topValue,
        bottomValue,
        topSliderMax,
        bottomSliderMax,
        result,
        cappedResult1,
        cappedResult2,
        showDownArrow,
        showRightArrow,
        // Second product state
        mode2,
        units2,
        topParam2,
        bottomParam2,
        topValue2,
        bottomValue2,
        topSliderMax2,
        bottomSliderMax2,
        result2,
        product,
        product2,
        lastUpdateSource1,
        lastUpdateSource2,
        isComparisonLocked,
      ];
} 