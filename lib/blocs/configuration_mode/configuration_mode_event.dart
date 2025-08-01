part of 'configuration_mode_bloc.dart';

abstract class ConfigurationModeEvent extends Equatable {
  const ConfigurationModeEvent();

  @override
  List<Object> get props => [];
}

class ConfigurationModeChanged extends ConfigurationModeEvent {
  final ConfigurationMode newMode;

  const ConfigurationModeChanged(this.newMode);

  @override
  List<Object> get props => [newMode];
} 