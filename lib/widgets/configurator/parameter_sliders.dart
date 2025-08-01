import 'package:alfalite_configurator/blocs/configuration/configuration_bloc.dart';
import 'package:alfalite_configurator/utils/configuration_mode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ParameterSliders extends StatelessWidget {
  final TextEditingController topValueController;
  final TextEditingController bottomValueController;
  final bool isSecond;

  const ParameterSliders({
    super.key,
    required this.topValueController,
    required this.bottomValueController,
    this.isSecond = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigurationBloc, ConfigurationState>(
      builder: (context, state) {
        return HookBuilder(builder: (context) {
          final mode = isSecond ? state.mode2 : state.mode;
          final topParam = isSecond ? state.topParam2 : state.topParam;
          final bottomParam = isSecond ? state.bottomParam2 : state.bottomParam;
          final topValue = isSecond ? state.topValue2 : state.topValue;
          final bottomValue = isSecond ? state.bottomValue2 : state.bottomValue;
          final topSliderMax = isSecond ? state.topSliderMax2 : state.topSliderMax;
          final bottomSliderMax =
              isSecond ? state.bottomSliderMax2 : state.bottomSliderMax;
          final units = isSecond ? state.units2 : state.units;
          final lastUpdateSource =
              isSecond ? state.lastUpdateSource2 : state.lastUpdateSource1;

          useEffect(() {
            if (lastUpdateSource == ValueUpdateSource.textField) return;

            final formattedTopValue =
                topValue.toStringAsFixed(mode == ConfigurationMode.tiles ? 0 : 2);
            if (topValueController.text != formattedTopValue) {
              topValueController.text = formattedTopValue;
            }
            return null;
          }, [topValue, mode]);

          useEffect(() {
            if (lastUpdateSource == ValueUpdateSource.textField) return;

            final formattedBottomValue = bottomValue
                .toStringAsFixed(mode == ConfigurationMode.tiles ? 0 : 2);
            if (bottomValueController.text != formattedBottomValue) {
              bottomValueController.text = formattedBottomValue;
            }
            return null;
          }, [bottomValue, mode]);

          return _buildUI(
            context: context,
            mode: mode,
            topParam: topParam,
            bottomParam: bottomParam,
            topValue: topValue,
            bottomValue: bottomValue,
            topSliderMax: topSliderMax,
            bottomSliderMax: bottomSliderMax,
            onTopChanged: (val, {fromTextField = false}) {
              final source = fromTextField
                  ? ValueUpdateSource.textField
                  : ValueUpdateSource.slider;
              if (isSecond) {
                context.read<ConfigurationBloc>().add(TopValueChanged2(val, source));
              } else {
                context.read<ConfigurationBloc>().add(TopValueChanged(val, source));
              }
            },
            onBottomChanged: (val, {fromTextField = false}) {
              final source = fromTextField
                  ? ValueUpdateSource.textField
                  : ValueUpdateSource.slider;
              if (isSecond) {
                context
                    .read<ConfigurationBloc>()
                    .add(BottomValueChanged2(val, source));
              } else {
                context
                    .read<ConfigurationBloc>()
                    .add(BottomValueChanged(val, source));
              }
            },
            units: units,
            onUnitsChanged: (val) {
              if (isSecond) {
                context.read<ConfigurationBloc>().add(UnitsChanged2(val!));
              } else {
                context.read<ConfigurationBloc>().add(UnitsChanged(val!));
              }
            },
          );
        });
      },
    );
  }
  
  Widget _buildUI({
    required BuildContext context,
    required ConfigurationMode mode,
    required String topParam,
    required String bottomParam,
    required double topValue,
    required double bottomValue,
    required double topSliderMax,
    required double bottomSliderMax,
    required void Function(double, {bool fromTextField}) onTopChanged,
    required void Function(double, {bool fromTextField}) onBottomChanged,
    required String units,
    required ValueChanged<String?> onUnitsChanged,
  }) {
    if (mode == ConfigurationMode.dimensions) {
      return Column(
        children: [
          _buildUnitsToggle(mode, units, onUnitsChanged),
          const SizedBox(height: 20),
          _buildSlider(
            label: _getLabelForParam(topParam, units, mode),
            value: topValue,
            max: topSliderMax,
            onChanged: onTopChanged,
            controller: topValueController,
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: _getLabelForParam(bottomParam, units, mode),
            value: bottomValue,
            max: bottomSliderMax,
            onChanged: onBottomChanged,
            controller: bottomValueController,
          ),
        ],
      );
    }

    if (mode == ConfigurationMode.diagonal) {
      return _buildSlider(
        label: _getLabelForParam(topParam, units, mode),
        value: topValue,
        max: topSliderMax,
        onChanged: onTopChanged,
        controller: topValueController,
      );
    }

    if (mode == ConfigurationMode.surface) {
      return Column(
        children: [
          _buildUnitsToggle(mode, units, onUnitsChanged),
          const SizedBox(height: 20),
          _buildSlider(
            label: _getLabelForParam(topParam, units, mode),
            value: topValue,
            max: topSliderMax,
            onChanged: onTopChanged,
            controller: topValueController,
          ),
        ],
      );
    }

    // Default for Tiles
    return Column(
      children: [
        _buildSlider(
          label: _getLabelForParam(topParam, units, mode),
          value: topValue,
          max: topSliderMax,
          onChanged: onTopChanged,
          controller: topValueController,
          isTile: true,
        ),
        const SizedBox(height: 20),
        _buildSlider(
          label: _getLabelForParam(bottomParam, units, mode),
          value: bottomValue,
          max: bottomSliderMax,
          onChanged: onBottomChanged,
          controller: bottomValueController,
          isTile: true,
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double max,
    required void Function(double, {bool fromTextField}) onChanged,
    required TextEditingController controller,
    bool isTile = false,
  }) {
    final textInput = TextFormField(
      controller: controller,
      keyboardType: isTile ? TextInputType.number : const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: isTile ? [FilteringTextInputFormatter.digitsOnly] : [],
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        fillColor: Color(0x1AFFFFFF),
        filled: true,
      ),
      onChanged: (value) {
        final double? parsedValue = double.tryParse(value.replaceAll(',', '.'));
        if (parsedValue != null) {
          if (isTile) {
            final clampedValue = parsedValue.clamp(1.0, max);
            onChanged(clampedValue, fromTextField: true);

            if (clampedValue != parsedValue) {
              final clampedText = clampedValue.toStringAsFixed(0);
              controller.value = TextEditingValue(
                text: clampedText,
                selection: TextSelection.fromPosition(
                    TextPosition(offset: clampedText.length)),
              );
            }
          } else {
            onChanged(parsedValue, fromTextField: true);
          }
        }
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(color: Color(0xFFF78400), fontSize: 16)),
          const SizedBox(height: 10),
        ],
        if (isTile)
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: 1,
                  max: max,
                  divisions: (max - 1).toInt(),
                  label: value.round().toString(),
                  onChanged: (value) => onChanged(value, fromTextField: false),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(width: 80, child: textInput),
            ],
          )
        else
          SizedBox(
            height: 50,
            child: textInput,
          ),
      ],
    );
  }

  Widget _buildUnitsToggle(ConfigurationMode mode, String units, ValueChanged<String?> onUnitsChanged) {
    final availableUnits = (mode == ConfigurationMode.dimensions || mode == ConfigurationMode.surface)
        ? ['m', 'ft']
        : ['m', 'ft', 'in'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Units:', style: const TextStyle(color: Color(0xFFF78400), fontSize: 16)),
        const SizedBox(width: 10),
        ...availableUnits.map((unit) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: unit,
              groupValue: units,
              onChanged: onUnitsChanged,
              activeColor: const Color(0xFFFC7100),
              fillColor: MaterialStateProperty.all(const Color(0xFFFC7100)),
            ),
            Text(
              (unit == 'm' ? 'Meters' : unit == 'ft' ? 'Feet' : 'Inches') +
              (mode == ConfigurationMode.surface ? '²' : ''),
            ),
          ],
        )).toList(),
      ],
    );
  }

  String _getLabelForParam(String param, String units, ConfigurationMode mode) {
    switch (param) {
      case 'tiles_horizontal': return 'Tiles Horizontal';
      case 'tiles_vertical': return 'Tiles Vertical';
      case 'width':
        final unit = units == 'm' ? 'meters' : units == 'ft' ? 'feet' : 'inches';
        return 'Width ($unit)';
      case 'height':
        final unit = units == 'm' ? 'meters' : units == 'ft' ? 'feet' : 'inches';
        return 'Height ($unit)';
      case 'diagonal':
        if (mode == ConfigurationMode.diagonal) {
          return 'Diagonal (inches)';
        }
        final unit = units == 'm' ? 'meters' : units == 'ft' ? 'feet' : 'inches';
        return 'Diagonal ($unit)';
      case 'surface':
        final unit = units == 'm' ? 'm²' : units == 'ft' ? 'ft²' : 'in²';
        return 'Surface ($unit)';
      case 'aspect_ratio':
        return 'Aspect Ratio (W:H)';
      default:
        return '';
    }
  }
} 