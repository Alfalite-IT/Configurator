import 'package:flutter/material.dart';
import 'package:alfalite_configurator/services/browser_detection_service.dart';

/// Widget that shows browser performance recommendations
class BrowserPerformanceNotice extends StatelessWidget {
  final bool showForFirefox;
  final Duration autoHideDuration;
  final VoidCallback? onDismiss;

  const BrowserPerformanceNotice({
    super.key,
    this.showForFirefox = true,
    this.autoHideDuration = const Duration(seconds: 8),
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final browserService = BrowserDetectionService();
    
    // Only show for browsers with performance issues
    if (!browserService.hasPerformanceIssues || !showForFirefox) {
      return const SizedBox.shrink();
    }

    final recommendation = browserService.performanceRecommendation;
    if (recommendation == null) {
      return const SizedBox.shrink();
    }

    return _BrowserNoticeContent(
      message: recommendation,
      browserName: browserService.browserName,
      autoHideDuration: autoHideDuration,
      onDismiss: onDismiss,
    );
  }
}

/// Internal widget for the notice content
class _BrowserNoticeContent extends StatefulWidget {
  final String message;
  final String browserName;
  final Duration autoHideDuration;
  final VoidCallback? onDismiss;

  const _BrowserNoticeContent({
    required this.message,
    required this.browserName,
    required this.autoHideDuration,
    this.onDismiss,
  });

  @override
  State<_BrowserNoticeContent> createState() => _BrowserNoticeContentState();
}

class _BrowserNoticeContentState extends State<_BrowserNoticeContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Auto-hide after specified duration
    Future.delayed(widget.autoHideDuration, () {
      if (mounted) {
        _hide();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _hide() {
    if (!_isVisible) return;
    
    setState(() => _isVisible = false);
    _animationController.forward().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Performance Notice',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _hide,
              icon: const Icon(Icons.close, size: 16),
              color: Colors.white54,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 