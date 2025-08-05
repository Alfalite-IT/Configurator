import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alfalite_configurator/services/units_service.dart';
import 'package:alfalite_configurator/models/configuration_result.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:alfalite_configurator/services/user_data.dart';
import 'package:alfalite_configurator/models/product.dart';
import 'package:alfalite_configurator/widgets/user_info_form.dart';
import 'package:alfalite_configurator/widgets/configurator/input_column.dart';
import 'package:alfalite_configurator/widgets/results/results_panel.dart';
import 'package:alfalite_configurator/blocs/configuration/configuration_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alfalite_configurator/services/browser_detection_service.dart';
import 'package:alfalite_configurator/widgets/browser_performance_notice.dart';
import 'package:alfalite_configurator/utils/configuration_mode.dart';
import 'package:alfalite_configurator/services/pdf_exporter.dart';
import 'package:alfalite_configurator/services/pdf_generator.dart';
import 'package:alfalite_configurator/services/email_client_service.dart';
import 'package:equatable/equatable.dart';

class ConfiguratorScreen extends StatefulWidget {
  final ui.Image backgroundImage;
  final ui.Image maleImage;
  final ui.Image femaleImage;
  const ConfiguratorScreen({
    super.key,
    required this.backgroundImage,
    required this.maleImage,
    required this.femaleImage,
  });

  @override
  State<ConfiguratorScreen> createState() => _ConfiguratorScreenState();
}

class _ConfiguratorScreenState extends State<ConfiguratorScreen>
    with SingleTickerProviderStateMixin {
  String _resultsUnit = 'm';

  AnimationController? _arrowAnimationController;
  
  // Add throttling for web performance
  Timer? _scrollThrottleTimer;
  Timer? _comparisonScrollThrottleTimer;
  
  // Browser detection service
  late final BrowserDetectionService _browserService;

  final TextEditingController _topValueController = TextEditingController();
  final TextEditingController _bottomValueController = TextEditingController();
  final TextEditingController _topValueController2 = TextEditingController();
  final TextEditingController _bottomValueController2 = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final ScrollController _comparisonScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _browserService = BrowserDetectionService();
    
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (700 * _browserService.performanceSettings['animationDuration']).round()),
    );
    
    // Add scroll listeners to detect when arrows should be shown
    _scrollController.addListener(_onScrollChanged);
    _comparisonScrollController.addListener(_onComparisonScrollChanged);
  }

  void _onScrollChanged() {
    if (!mounted) return;
    
    // Use browser-specific throttling
    final throttleMs = _browserService.performanceSettings['scrollThrottleMs'] as int;
    
    if (kIsWeb) {
      _scrollThrottleTimer?.cancel();
      _scrollThrottleTimer = Timer(Duration(milliseconds: throttleMs), () {
        _performScrollUpdate();
      });
    } else {
      _performScrollUpdate();
    }
  }
  
  void _performScrollUpdate() {
    if (!mounted) return;
    
    final state = context.read<ConfigurationBloc>().state;
    final position = _scrollController.position;
    // Show down arrow if there's more content below and we're not at the bottom
    final showDownArrow = position.pixels < position.maxScrollExtent - 50;
    
    if (showDownArrow != state.showDownArrow) {
      context.read<ConfigurationBloc>().add(UpdateArrowVisibility(
        showDownArrow: showDownArrow,
        showRightArrow: state.showRightArrow,
      ));
    }
  }

  void _onComparisonScrollChanged() {
    if (!mounted) return;
    
    // Use browser-specific throttling
    final throttleMs = _browserService.performanceSettings['scrollThrottleMs'] as int;
    
    if (kIsWeb) {
      _comparisonScrollThrottleTimer?.cancel();
      _comparisonScrollThrottleTimer = Timer(Duration(milliseconds: throttleMs), () {
        _performComparisonScrollUpdate();
      });
    } else {
      _performComparisonScrollUpdate();
    }
  }
  
  void _performComparisonScrollUpdate() {
    if (!mounted) return;
    
    final state = context.read<ConfigurationBloc>().state;
    final position = _comparisonScrollController.position;
    // Show right arrow if there's more content to the right and we're not at the end
    final showRightArrow = position.pixels < position.maxScrollExtent - 50;
    
    if (showRightArrow != state.showRightArrow) {
      context.read<ConfigurationBloc>().add(UpdateArrowVisibility(
        showDownArrow: state.showDownArrow,
        showRightArrow: showRightArrow,
      ));
    }
  }

  void _checkArrowVisibility() {
    if (!mounted) return;
    
    final state = context.read<ConfigurationBloc>().state;
    bool showDownArrow = false;
    bool showRightArrow = false;
    
    // Check if down arrow should be shown (for vertical scrolling)
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      showDownArrow = position.pixels < position.maxScrollExtent - 50;
    }
    
    // Check if right arrow should be shown (for horizontal scrolling in comparison mode)
    if (state.isComparing && _comparisonScrollController.hasClients) {
      final position = _comparisonScrollController.position;
      showRightArrow = position.pixels < position.maxScrollExtent - 50;
    }
    
    // Only update if values have changed
    if (showDownArrow != state.showDownArrow || showRightArrow != state.showRightArrow) {
      context.read<ConfigurationBloc>().add(UpdateArrowVisibility(
        showDownArrow: showDownArrow,
        showRightArrow: showRightArrow,
      ));
    }
  }

  @override
  void dispose() {
    _topValueController.dispose();
    _bottomValueController.dispose();
    _topValueController2.dispose();
    _bottomValueController2.dispose();
    _arrowAnimationController?.dispose();
    _scrollController.dispose();
    _comparisonScrollController.dispose();
    _scrollThrottleTimer?.cancel();
    _comparisonScrollThrottleTimer?.cancel();
    super.dispose();
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset('assets/images/banner.png', height: 50),
        const SizedBox(height: 8),
        const Text('LED Screen Configurator'),
      ],
    );
  }

  void _copyToClipboard(BuildContext context) {
    final state = context.read<ConfigurationBloc>().state;
    if (state.result == null) return;

    final resultString = _buildResultString(state, state.result!, state.product!,
        isFirstProduct: true);
    final compareString = state.isComparing && state.result2 != null
        ? _buildResultString(state, state.result2!, state.product2!,
            isFirstProduct: false)
        : '';

    Clipboard.setData(ClipboardData(text: '$resultString\n$compareString'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        backgroundColor: Color(0xFFFC7100),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _buildResultString(ConfigurationState state, ConfigurationResult result,
      Product product, {required bool isFirstProduct}) {
    final selectedProduct = product;

    final intFormatter = NumberFormat("#,###", "de_DE");
    final dec1Formatter = NumberFormat("#,##0.0", "de_DE");
    final dec2Formatter = NumberFormat("#,##0.00", "de_DE");

    double diagonalValue = result.diagonal;
    double surfaceValue = result.surface;
    double widthValue = result.width;
    double heightValue = result.height;
    String lengthUnit = 'm';
    String surfaceUnit = 'm²';

    final currentUnits = isFirstProduct ? state.units : state.units2;

    if (currentUnits == 'ft') {
      diagonalValue = UnitsService.convertMetersToFeet(result.diagonal);
      surfaceValue = UnitsService.convertSqMetersToSqFeet(result.surface);
      widthValue = UnitsService.convertMetersToFeet(result.width);
      heightValue = UnitsService.convertMetersToFeet(result.height);
      lengthUnit = 'ft';
      surfaceUnit = 'ft²';
    } else if (currentUnits == 'in') {
      diagonalValue = UnitsService.convertMetersToInches(result.diagonal);
      surfaceValue = UnitsService.convertSqMetersToSqInches(result.surface);
      widthValue = UnitsService.convertMetersToInches(result.width);
      heightValue = UnitsService.convertMetersToInches(result.height);
      lengthUnit = 'in';
      surfaceUnit = 'in²';
    }

    final resolutionParts = result.resolution.split('x');
    final formattedResolution =
        '${intFormatter.format(int.parse(resolutionParts[0]))}x${intFormatter.format(int.parse(resolutionParts[1]))}';

    final formattedWidth = dec2Formatter.format(widthValue);
    final formattedHeight = dec2Formatter.format(heightValue);
    final formattedDimensions = '$formattedWidth x $formattedHeight $lengthUnit';

    final formattedDiagonal = '${dec2Formatter.format(diagonalValue)} $lengthUnit';
    final formattedSurface = '${dec2Formatter.format(surfaceValue)} $surfaceUnit';
    final formattedMaxPower = result.maxPower.replaceFirst('.', ',');
    final formattedAvgPower = result.avgPower.replaceFirst('.', ',');
    final formattedWeight = result.weight.replaceFirst('.', ',');
    final formattedBrightness =
        '${intFormatter.format(int.parse(result.brightness.split(' ')[0]))} nits';
    final formattedRefreshRate = result.refreshRate != null
        ? '${dec1Formatter.format(result.refreshRate)} Hz'
        : 'N/A';

    final optDistParts = result.optViewDistance.split(' / ');
    final metersDist = optDistParts[0].replaceAll('m', '');
    final feetDist = optDistParts[1].replaceAll('ft', '');
    final formattedOptDistance =
        '${metersDist.replaceFirst('.', ',')}m / ${feetDist.replaceFirst('.', ',')}ft';

    return '''
    Product: ${selectedProduct.name}
    Resolution: $formattedResolution
    Dimensions: $formattedDimensions
    Diagonal: $formattedDiagonal
    Aspect Ratio: ${result.aspectRatio}
    Surface Area: $formattedSurface
    Max Power: $formattedMaxPower
    Avg. Power: $formattedAvgPower
    Weight: $formattedWeight
    Optimal View Distance: $formattedOptDistance
    Refresh Rate: $formattedRefreshRate
    Contrast: ${result.contrast ?? 'N/A'}
    Vision Angle: ${result.visionAngle ?? 'N/A'}
    Redundancy (Optional): ${result.redundancy ?? 'N/A'}
    Brightness: $formattedBrightness
    Total Tiles: ${result.totalTiles}
    ''';
  }

  void _handleCapping(BuildContext context, ConfigurationResult result, int panelIndex) {
    TextEditingController topController =
        panelIndex == 1 ? _topValueController : _topValueController2;
    TextEditingController bottomController =
        panelIndex == 1 ? _bottomValueController : _bottomValueController2;
    final state = context.read<ConfigurationBloc>().state;
    ConfigurationMode mode = panelIndex == 1 ? state.mode : state.mode2;

    if (mode == ConfigurationMode.dimensions) {
      if (result.cappedWidth != null) {
        topController.text = result.cappedWidth!.toStringAsFixed(2);
      }
      if (result.cappedHeight != null) {
        bottomController.text = result.cappedHeight!.toStringAsFixed(2);
      }
    } else if (mode == ConfigurationMode.diagonal) {
      if (result.cappedDiagonal != null) {
        topController.text = result.cappedDiagonal!.toStringAsFixed(2);
      }
    } else if (mode == ConfigurationMode.surface) {
      if (result.cappedSurface != null) {
        topController.text = result.cappedSurface!.toStringAsFixed(2);
      }
    }

    String message = "Input adjusted to maximum size";
    if (result.wasCappedH && result.wasCappedV) {
      message = "Inputs adjusted to maximum values";
    } else if (result.wasCappedH) {
      message = "Width-related input adjusted to maximum value";
    } else if (result.wasCappedV) {
      message = "Height-related input adjusted to maximum value";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConfigurationBloc, ConfigurationState>(
      listener: (context, state) {
        if (state.cappedResult1 != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleCapping(context, state.cappedResult1!, 1);
            // Add event to clear capped result
          });
        }
        if (state.cappedResult2 != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleCapping(context, state.cappedResult2!, 2);
             // Add event to clear capped result
          });
        }

        final bool shouldAnimateArrows =
            state.showDownArrow || state.showRightArrow;
        if (shouldAnimateArrows && !_arrowAnimationController!.isAnimating) {
          _arrowAnimationController!.repeat(reverse: true);
        } else if (!shouldAnimateArrows &&
            _arrowAnimationController!.isAnimating) {
          _arrowAnimationController!.stop();
        }
        
        // Check arrow visibility when results change
        if (state.result != null || state.result2 != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkArrowVisibility();
          });
        }
      },
      builder: (context, state) {
        return LayoutBuilder(builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 1000;
          return Scaffold(
            appBar: isWideScreen
                ? null
                : AppBar(
                    title: _buildHeader(),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    toolbarHeight: 120,
                  ),
            body: Stack(
              children: [
                isWideScreen
                    ? _buildWideLayout(context)
                    : _buildNarrowLayout(context),
                // Browser performance notice (only shows for problematic browsers)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: BrowserPerformanceNotice(),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    final state = context.watch<ConfigurationBloc>().state;
    return SingleChildScrollView(
      controller: _scrollController,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: state.isComparing ? 1040 : 500),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputColumn(isFirstProduct: true),
                if (state.isComparing) ...[
                  const Divider(height: 40, thickness: 2),
                  _buildInputColumn(isFirstProduct: false),
                  const SizedBox(height: 20),
                ],
                const SizedBox(height: 20),
                _buildCalculationActions(),
                const SizedBox(height: 20),
                // Down arrow indicator positioned to guide users to results
                if (state.result != null || state.result2 != null)
                  _buildDownArrowIndicator(),
                if (state.result != null || state.result2 != null)
                  Column(
                    children: [
                      _buildResultsPanel(context, isWide: false),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    final state = context.watch<ConfigurationBloc>().state;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildInputColumn(isFirstProduct: true),
                if (state.isComparing) ...[
                  const Divider(height: 40, thickness: 2),
                  _buildInputColumn(isFirstProduct: false),
                  const SizedBox(height: 20),
                ],
                const SizedBox(height: 20),
                _buildCalculationActions(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(25, 5, 25, 5),
            child: (state.result != null || state.result2 != null)
                ? _buildResultsPanel(context, isWide: true)
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text('Results will appear here.',
                          style: Theme.of(context).textTheme.headlineMedium),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculationActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {}, // No-op, but keeps the button enabled.
              child: const Text(
                'Calculate Configuration',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BlocBuilder<ConfigurationBloc, ConfigurationState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    context
                        .read<ConfigurationBloc>()
                        .add(ToggleComparisonView());
                  },
                  child: Text(
                    state.isComparing ? 'Hide Comparison' : 'Compare Screens',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputColumn({required bool isFirstProduct}) {
    return InputColumn(
      isFirstProduct: isFirstProduct,
      topValueController:
          isFirstProduct ? _topValueController : _topValueController2,
      bottomValueController:
          isFirstProduct ? _bottomValueController : _bottomValueController2,
    );
  }

  Widget _buildResultsPanel(BuildContext context, {required bool isWide}) {
    final state = context.watch<ConfigurationBloc>().state;
    return ResultsPanel(
      isWide: isWide,
      scrollController:
          state.isComparing ? _comparisonScrollController : _scrollController,
      resultsUnit: _resultsUnit,
      onUnitsChanged: (newUnit) {
        setState(() {
          _resultsUnit = newUnit;
        });
      },
      screenBackgroundImage: widget.backgroundImage,
      arrowAnimationController: _arrowAnimationController,
      maleImage: widget.maleImage,
      femaleImage: widget.femaleImage,
    );
  }

  Widget _buildDownArrowIndicator() {
    final state = context.watch<ConfigurationBloc>().state;
    return Center(
      child: AnimatedOpacity(
        opacity: state.showDownArrow ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FadeTransition(
          opacity: _arrowAnimationController!,
          child: GestureDetector(
            onTap: () {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_downward,
                  size: 30, color: Color(0xFFFC7100)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightArrowIndicator() {
    final state = context.watch<ConfigurationBloc>().state;
    return Positioned(
      right: 10,
      top: 0,
      bottom: 0,
      child: Center(
        child: AnimatedOpacity(
          opacity: state.showRightArrow ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: FadeTransition(
            opacity: _arrowAnimationController!,
            child: GestureDetector(
              onTap: () {
                final scrollController = state.isComparing
                    ? _comparisonScrollController
                    : _scrollController;
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_forward_ios,
                  size: 50, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPulsingArrow(IconData icon) {
    return FadeTransition(
      opacity: _arrowAnimationController!,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 30),
      ),
    );
  }

  Widget _buildActionButtons() {
    final isComparing = context.watch<ConfigurationBloc>().state.isComparing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => _copyToClipboard(context),
          child: const Text('Copy Results to Clipboard'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _showUserInfoForm(context, 'Save as PDF'),
          child: const Text('Send PDF by Email'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _showUserInfoForm(context, 'Request a Quote'),
          child: const Text('Request a Quote'),
        ),
        if (isComparing) ...[
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _showUserInfoForm(context, 'Comparison Chart'),
            style:
                ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFC7100)),
            child: const Text('Send Comparison by Email'),
          ),
        ],
      ],
    );
  }

  void _showUserInfoForm(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return UserInfoForm(
          title: title,
          onSubmit: (userData) {
            final state = context.read<ConfigurationBloc>().state;
            if (title == 'Save as PDF') {
              _generateAndSavePdf(dialogContext, userData, state.result!, 'pdf');
            } else if (title == 'Request a Quote') {
              _generateAndSavePdf(dialogContext, userData, state.result!, 'quote');
            } else if (title == 'Comparison Chart') {
              _generateComparativePdf(
                  dialogContext, userData, state.product!, state.result!, state.product2!, state.result2!);
            }
          },
        );
      },
    );
  }

  Future<void> _generateAndSavePdf(
      BuildContext context, UserData userData, ConfigurationResult result, String emailType) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating PDF and sending email...'),
        backgroundColor: Color(0xFFFC7100),
        duration: Duration(seconds: 4),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 50));

    try {
      // Generate PDF and get bytes for email
      final pdfBytes = await PdfGenerator().generateSingleProductPdf(userData, result);
      
      // Send email with PDF attachment
      final emailSuccess = await EmailClientService.sendPdfEmail(
        userData: userData,
        pdfBytes: pdfBytes,
        emailType: emailType,
      );

      if (context.mounted) {
        if (emailSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF generated and email sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email could not be sent. Please try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateComparativePdf(
      BuildContext context,
      UserData userData,
      Product product1,
      ConfigurationResult result1,
      Product product2,
      ConfigurationResult result2) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating comparison PDF and sending email...'),
        backgroundColor: Color(0xFFFC7100),
        duration: Duration(seconds: 4),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 50));

    try {
      // Generate PDF and get bytes for email
      final pdfBytes = await PdfGenerator().generateComparativePdf(
        product1, result1, product2, result2);
      
      // Send email with PDF attachment
      final emailSuccess = await EmailClientService.sendComparisonEmail(
        userData: userData,
        pdfBytes: pdfBytes,
      );

      if (context.mounted) {
        if (emailSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comparison PDF generated and email sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email could not be sent. Please try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _LoadingState extends Equatable {
  final bool isLoading;
  final String? error;

  const _LoadingState(this.isLoading, this.error);

  @override
  List<Object?> get props => [isLoading, error];
}