import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:alfalite_configurator/models/configuration_result.dart';
import 'package:alfalite_configurator/models/product.dart';
import 'package:alfalite_configurator/services/calculation_service.dart';
import 'package:alfalite_configurator/utils/configuration_mode.dart';

part 'configuration_event.dart';
part 'configuration_state.dart';

class ConfigurationBloc extends Bloc<ConfigurationEvent, ConfigurationState> {
  final CalculationService _calculationService;

  ConfigurationBloc({required CalculationService calculationService})
      : _calculationService = calculationService,
        super(const ConfigurationState()) {
    on<ConfigurationModeUpdated>(_onConfigurationModeUpdated);
    on<TopValueChanged>(_onTopValueChanged);
    on<BottomValueChanged>(_onBottomValueChanged);
    on<UnitsChanged>(_onUnitsChanged);
    on<ProductChanged>(_onProductChanged);
    on<ToggleComparisonLock>(_onToggleComparisonLock);
    on<ToggleComparisonView>(_onToggleComparisonView);
    on<Product2Changed>(_onProduct2Changed);
    on<TopValueChanged2>(_onTopValueChanged2);
    on<BottomValueChanged2>(_onBottomValueChanged2);
    on<UnitsChanged2>(_onUnitsChanged2);
    on<ConfigurationModeUpdated2>(_onConfigurationModeUpdated2);
    on<Calculate>(_onCalculate);
    on<UpdateArrowVisibility>(_onUpdateArrowVisibility);
  }

  void _onToggleComparisonLock(
      ToggleComparisonLock event, Emitter<ConfigurationState> emit) async {
    emit(state.copyWith(isComparisonLocked: event.isLocked));
    // When locking, we may need to re-sync product 2 with product 1
    if (event.isLocked) {
      add(const Calculate()); // Recalculate will handle mirroring
    }
  }

  void _onToggleComparisonView(
      ToggleComparisonView event, Emitter<ConfigurationState> emit) async {
    final willBeComparing = !state.isComparing;
    if (willBeComparing) {
      // Entering comparison. Copy product 1 to 2 if 2 is null.
      final product2 = state.product2 ?? state.product;

      if (product2 != null) {
        final params = <String, double>{
          state.topParam: state.topValue,
          state.bottomParam: state.bottomValue,
        };
        final result2 = await _calculationService.calculate(
            product: product2, units: state.units, params: params);

        emit(state.copyWith(
          isComparing: true,
          product2: product2,
          result2: result2,
          mode2: state.mode,
          units2: state.units,
          topParam2: state.topParam,
          bottomParam2: state.bottomParam,
          topValue2: state.topValue,
          bottomValue2: state.bottomValue,
        ));
      } else {
        emit(state.copyWith(isComparing: true));
      }
    } else {
      // Exiting comparison mode.
      emit(state.copyWith(isComparing: false));
    }
  }

  void _onProduct2Changed(
      Product2Changed event, Emitter<ConfigurationState> emit) async {
    final params = <String, double>{
      state.topParam2: state.topValue2,
      state.bottomParam2: state.bottomValue2,
    };
    final result2 = await _calculationService.calculate(
        product: event.product, units: state.units2, params: params);
    emit(state.copyWith(product2: event.product, result2: result2));
  }

  void _onTopValueChanged2(
      TopValueChanged2 event, Emitter<ConfigurationState> emit) async {
    if (state.product2 == null) {
      emit(state.copyWith(
          topValue2: event.value, lastUpdateSource2: event.source));
      return;
    }
    final params = <String, double>{
      state.topParam2: event.value,
      state.bottomParam2: state.bottomValue2,
    };
    final result2 = await _calculationService.calculate(
        product: state.product2!, units: state.units2, params: params);
    emit(state.copyWith(
        topValue2: event.value,
        result2: result2,
        lastUpdateSource2: event.source));
  }

  void _onBottomValueChanged2(
      BottomValueChanged2 event, Emitter<ConfigurationState> emit) async {
    if (state.product2 == null) {
      emit(state.copyWith(
          bottomValue2: event.value, lastUpdateSource2: event.source));
      return;
    }
    final params = <String, double>{
      state.topParam2: state.topValue2,
      state.bottomParam2: event.value,
    };
    final result2 = await _calculationService.calculate(
        product: state.product2!, units: state.units2, params: params);
    emit(state.copyWith(
        bottomValue2: event.value,
        result2: result2,
        lastUpdateSource2: event.source));
  }

  void _onUnitsChanged2(UnitsChanged2 event, Emitter<ConfigurationState> emit) async {
    if (state.product2 == null) {
      emit(state.copyWith(units2: event.units));
      return;
    }
    final params = <String, double>{
      state.topParam2: state.topValue2,
      state.bottomParam2: state.bottomValue2,
    };
    final result2 = await _calculationService.calculate(
        product: state.product2!, units: event.units, params: params);
    emit(state.copyWith(units2: event.units, result2: result2));
  }

  void _onConfigurationModeUpdated2(
    ConfigurationModeUpdated2 event,
    Emitter<ConfigurationState> emit,
  ) async {
    var newState = state.copyWith(
      mode2: event.mode,
      topValue2: 1.0,
      bottomValue2: 1.0,
      resetLastUpdateSource: true,
    );

    switch (event.mode) {
      case ConfigurationMode.tiles:
        newState = newState.copyWith(
          topParam2: 'tiles_horizontal',
          bottomParam2: 'tiles_vertical',
          units2: 'tiles',
        );
        break;
      case ConfigurationMode.dimensions:
        newState = newState.copyWith(
          topParam2: 'width',
          bottomParam2: 'height',
          units2: state.units2 == 'in' ? 'm' : state.units2,
        );
        break;
      case ConfigurationMode.diagonal:
        newState = newState.copyWith(
          topParam2: 'diagonal',
          bottomParam2: 'aspect_ratio',
          units2: 'in',
        );
        break;
      case ConfigurationMode.surface:
        newState = newState.copyWith(
          topParam2: 'surface',
          bottomParam2: 'aspect_ratio',
          units2: state.units2 == 'in' ? 'm' : state.units2,
        );
        break;
    }
    emit(newState);
    if (state.product2 != null) {
      final params = <String, double>{
        newState.topParam2: newState.topValue2,
        newState.bottomParam2: newState.bottomValue2,
      };
      final result2 = await _calculationService.calculate(
          product: state.product2!, units: newState.units2, params: params);
      emit(newState.copyWith(result2: result2));
    } else {
      emit(newState);
    }
  }

  void _onProductChanged(
    ProductChanged event,
    Emitter<ConfigurationState> emit,
  ) {
    emit(state.copyWith(product: event.product));
    add(const Calculate());
  }

  Future<void> _onConfigurationModeUpdated(
    ConfigurationModeUpdated event,
    Emitter<ConfigurationState> emit,
  ) async {
    var newState = state.copyWith(
      mode: event.mode,
      topValue: 1.0,
      bottomValue: 1.0,
      resetLastUpdateSource: true,
    );

    switch (event.mode) {
      case ConfigurationMode.tiles:
        newState = newState.copyWith(
          topParam: 'tiles_horizontal',
          bottomParam: 'tiles_vertical',
          units: 'tiles',
        );
        break;
      case ConfigurationMode.dimensions:
        newState = newState.copyWith(
          topParam: 'width',
          bottomParam: 'height',
          units: state.units == 'in' ? 'm' : state.units,
        );
        break;
      case ConfigurationMode.diagonal:
        newState = newState.copyWith(
          topParam: 'diagonal',
          bottomParam: 'aspect_ratio',
          units: 'in',
        );
        break;
      case ConfigurationMode.surface:
        newState = newState.copyWith(
          topParam: 'surface',
          bottomParam: 'aspect_ratio',
          units: state.units == 'in' ? 'm' : state.units,
        );
        break;
    }
    emit(newState);
    await _recalculate(emit, newState);
    if (state.isComparing && state.isComparisonLocked) {
      add(ConfigurationModeUpdated2(event.mode));
    }
  }

  Future<void> _onTopValueChanged(
      TopValueChanged event, Emitter<ConfigurationState> emit) async {
    final newState =
        state.copyWith(topValue: event.value, lastUpdateSource1: event.source);
    emit(newState);
    await _recalculate(emit, newState);
  }

  Future<void> _onBottomValueChanged(
      BottomValueChanged event, Emitter<ConfigurationState> emit) async {
    final newState = state.copyWith(
        bottomValue: event.value, lastUpdateSource1: event.source);
    emit(newState);
    await _recalculate(emit, newState);
  }

  Future<void> _onUnitsChanged(
      UnitsChanged event, Emitter<ConfigurationState> emit) async {
    final newState = state.copyWith(units: event.units);
    emit(newState);
    await _recalculate(emit, newState);
  }

  Future<void> _onCalculate(
      Calculate event, Emitter<ConfigurationState> emit) async {
    await _recalculate(emit, state);
  }

  void _onUpdateArrowVisibility(
      UpdateArrowVisibility event, Emitter<ConfigurationState> emit) {
    emit(state.copyWith(
      showDownArrow: event.showDownArrow,
      showRightArrow: event.showRightArrow,
    ));
  }

  Future<void> _recalculate(
      Emitter<ConfigurationState> emit, ConfigurationState currentState) async {
    if (currentState.product == null) {
      return;
    }

    final params = <String, double>{
      currentState.topParam: currentState.topValue,
      currentState.bottomParam: currentState.bottomValue,
    };

    final result1 = await _calculationService.calculate(
      product: currentState.product!,
      units: currentState.units,
      params: params,
    );

    // Mirroring logic
    if (currentState.isComparing && currentState.isComparisonLocked) {
      final mirroredParams = <String, double>{
        currentState.topParam: currentState.topValue,
        currentState.bottomParam: currentState.bottomValue,
      };

      if (currentState.product2 != null) {
        final result2 = await _calculationService.calculate(
          product: currentState.product2!,
          units: currentState.units,
          params: mirroredParams,
        );
        emit(currentState.copyWith(
          result: result1,
          result2: result2,
          mode2: currentState.mode,
          units2: currentState.units,
          topParam2: currentState.topParam,
          bottomParam2: currentState.bottomParam,
          topValue2: currentState.topValue,
          bottomValue2: currentState.bottomValue,
        ));
      } else {
        // Product 2 is null but we are in locked mode, still need to emit result1
        emit(currentState.copyWith(result: result1));
      }
    } else {
      // Not in locked comparison mode, just emit result for product 1
      emit(currentState.copyWith(result: result1));
    }
  }
} 