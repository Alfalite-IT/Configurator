import 'package:alfalite_configurator/blocs/configuration/configuration_bloc.dart';
import 'package:alfalite_configurator/blocs/configuration_mode/configuration_mode_bloc.dart';
import 'package:alfalite_configurator/blocs/product/product_bloc.dart';
import 'package:alfalite_configurator/services/calculation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'package:alfalite_configurator/api/product_repository.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:alfalite_configurator/config/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Print environment information for debugging
  if (kDebugMode) {
    Environment.printEnvironment();
  }
  
  final ui.Image backgroundImage =
      await _loadImage('assets/images/screen-background.png');
  final ui.Image maleImage = await _loadImage('assets/images/male_figure.png');
  final ui.Image femaleImage =
      await _loadImage('assets/images/female_figure.png');

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProductRepository>(
          create: (context) => ProductRepository(),
        ),
        RepositoryProvider<CalculationService>(
          create: (context) => CalculationService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ProductBloc>(
            create: (context) => ProductBloc(
              productRepository: context.read<ProductRepository>(),
            )..add(const LoadProducts()),
          ),
          BlocProvider<ConfigurationModeBloc>(
            create: (context) => ConfigurationModeBloc(),
          ),
          BlocProvider<ConfigurationBloc>(
            create: (context) => ConfigurationBloc(
              calculationService: context.read<CalculationService>(),
            ),
          ),
        ],
        child: App(
          backgroundImage: backgroundImage,
          maleImage: maleImage,
          femaleImage: femaleImage,
        ),
      ),
    ),
  );
}

Future<ui.Image> _loadImage(String assetPath) async {
  if (kIsWeb) {
    // Web-specific approach that's more Firefox-friendly
    final ImageProvider provider = AssetImage(assetPath);
    final ImageStream stream = provider.resolve(ImageConfiguration.empty);
    final Completer<ui.Image> completer = Completer<ui.Image>();
    
    stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));
    
    return completer.future;
  } else {
    // Keep existing method for mobile platforms
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }
}
