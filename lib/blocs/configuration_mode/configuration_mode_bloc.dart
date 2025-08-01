import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:alfalite_configurator/utils/configuration_mode.dart';

part 'configuration_mode_event.dart';
part 'configuration_mode_state.dart';

class ConfigurationModeBloc extends Bloc<ConfigurationModeEvent, ConfigurationModeState> {
  ConfigurationModeBloc() : super(const ConfigurationModeState()) {
    on<ConfigurationModeChanged>((event, emit) {
      emit(state.copyWith(mode: event.newMode));
    });
  }
} 