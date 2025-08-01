// Web-specific implementation for browser detection
import 'dart:html' as html;

/// Web-specific browser detection implementation
class BrowserDetectionWeb {
  static String _getUserAgent() {
    return html.window.navigator.userAgent;
  }

  static bool isFirefox() {
    return _getUserAgent().contains('Firefox');
  }

  static bool isChrome() {
    final userAgent = _getUserAgent();
    return userAgent.contains('Chrome') && !userAgent.contains('Firefox');
  }

  static bool isSafari() {
    final userAgent = _getUserAgent();
    return userAgent.contains('Safari') && !userAgent.contains('Chrome');
  }

  static bool isEdge() {
    return _getUserAgent().contains('Edg');
  }

  static String getBrowserName() {
    if (isFirefox()) return 'Firefox';
    if (isChrome()) return 'Chrome';
    if (isSafari()) return 'Safari';
    if (isEdge()) return 'Edge';
    return 'Unknown';
  }
} 