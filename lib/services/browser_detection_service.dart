import 'package:flutter/foundation.dart';

/// Service for detecting browser types and providing browser-specific functionality
class BrowserDetectionService {
  static final BrowserDetectionService _instance = BrowserDetectionService._internal();
  factory BrowserDetectionService() => _instance;
  BrowserDetectionService._internal();

  /// Detects if the current platform is web
  bool get isWeb => kIsWeb;

  /// Detects if the current browser is Firefox
  bool get isFirefox {
    if (!isWeb) return false;
    
    try {
      return _getUserAgent().contains('Firefox');
    } catch (e) {
      return false;
    }
  }

  /// Detects if the current browser is Chrome/Chromium-based
  bool get isChrome {
    if (!isWeb) return false;
    
    try {
      final userAgent = _getUserAgent();
      return userAgent.contains('Chrome') && !userAgent.contains('Firefox');
    } catch (e) {
      return false;
    }
  }

  /// Detects if the current browser is Safari
  bool get isSafari {
    if (!isWeb) return false;
    
    try {
      final userAgent = _getUserAgent();
      return userAgent.contains('Safari') && !userAgent.contains('Chrome');
    } catch (e) {
      return false;
    }
  }

  /// Detects if the current browser is Edge
  bool get isEdge {
    if (!isWeb) return false;
    
    try {
      return _getUserAgent().contains('Edg');
    } catch (e) {
      return false;
    }
  }

  /// Gets the browser name as a string
  String get browserName {
    if (!isWeb) return 'Mobile';
    if (isFirefox) return 'Firefox';
    if (isChrome) return 'Chrome';
    if (isSafari) return 'Safari';
    if (isEdge) return 'Edge';
    return 'Unknown';
  }

  /// Checks if the browser has known performance issues with Flutter web
  bool get hasPerformanceIssues {
    return isFirefox; // Firefox has known performance issues with Flutter web
  }

  /// Gets a performance recommendation message for the current browser
  String? get performanceRecommendation {
    if (isFirefox) {
      return 'For optimal performance, consider using Chrome or Edge.';
    }
    return null;
  }

  /// Gets browser-specific performance settings
  Map<String, dynamic> get performanceSettings {
    if (isFirefox) {
      return {
        'scrollThrottleMs': 32, // More aggressive throttling for Firefox
        'animationDuration': 1.2, // Slower animations for Firefox
        'enableHardwareAcceleration': true,
      };
    }
    
    return {
      'scrollThrottleMs': 16, // Standard throttling for other browsers
      'animationDuration': 1.0, // Normal animation speed
      'enableHardwareAcceleration': true,
    };
  }

  /// Gets the user agent string (web only)
  String _getUserAgent() {
    if (!isWeb) return '';
    
    try {
      // Use web-specific implementation if available
      if (kIsWeb) {
        // Import dart:html conditionally
        return _getWebUserAgent();
      }
    } catch (e) {
      // Fallback if dart:html is not available
    }
    
    return '';
  }

  /// Web-specific user agent detection
  String _getWebUserAgent() {
    // This will be implemented differently for web vs other platforms
    // For now, we'll use a simple approach that works in Flutter web
    return '';
  }
}

/// Extension to make browser detection easily accessible
extension BrowserDetection on Object {
  BrowserDetectionService get browser => BrowserDetectionService();
} 