import 'package:alfalite_configurator/constants/app_theme.dart';
import 'package:alfalite_configurator/screens/configurator_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class App extends StatelessWidget {
  final ui.Image backgroundImage;
  final ui.Image maleImage;
  final ui.Image femaleImage;

  const App({
    super.key,
    required this.backgroundImage,
    required this.maleImage,
    required this.femaleImage,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Screen Configurator',
      theme: AppTheme.darkTheme,
      home: ConfiguratorScreen(
        backgroundImage: backgroundImage,
        maleImage: maleImage,
        femaleImage: femaleImage,
      ),
    );
  }
} 