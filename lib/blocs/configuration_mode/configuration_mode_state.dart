part of 'configuration_mode_bloc.dart';

class ConfigurationModeState extends Equatable {
  final ConfigurationMode mode;

  const ConfigurationModeState({this.mode = ConfigurationMode.tiles});

  @override
  List<Object> get props => [mode];

  ConfigurationModeState copyWith({
    ConfigurationMode? mode,
  }) {
    return ConfigurationModeState(
      mode: mode ?? this.mode,
    );
  }
} 