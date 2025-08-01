import 'package:alfalite_configurator/blocs/configuration/configuration_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/configuration_mode.dart';

class ConfigurationModeToggle extends StatelessWidget {
  final bool isLocked;
  final bool isSecond;

  const ConfigurationModeToggle({
    super.key,
    this.isLocked = false,
    this.isSecond = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigurationBloc, ConfigurationState>(
      builder: (context, state) {
        final currentMode = isSecond ? state.mode2 : state.mode;
        return _buildUI(context, currentMode, (newMode) {
          if (isSecond) {
            context
                .read<ConfigurationBloc>()
                .add(ConfigurationModeUpdated2(newMode));
          } else {
            context
                .read<ConfigurationBloc>()
                .add(ConfigurationModeUpdated(newMode));
          }
        });
      },
    );
  }

  Widget _buildUI(BuildContext context, ConfigurationMode currentMode,
      Function(ConfigurationMode) onModeSelected) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ConfigurationMode.values.map((m) {
          final isSelected = m == currentMode;
          return Expanded(
            child: GestureDetector(
              onTap: isLocked ? null : () => onModeSelected(m),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFF78400) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  m.name[0].toUpperCase() + m.name.substring(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 