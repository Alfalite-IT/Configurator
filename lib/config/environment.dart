/// Environment configuration for the Alfalite Configurator app.
/// 
/// This class provides compile-time constants for API URLs and other
/// environment-specific configuration. Values are set using --dart-define
/// flags during the build process.
class Environment {
  /// Base URL for API requests (e.g., http://localhost:8080 or https://localhost:1337)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://localhost:1337',
  );
  
  /// Base URL for server resources like images (e.g., http://localhost:8080 or https://localhost:1337)
  static const String serverBaseUrl = String.fromEnvironment(
    'SERVER_BASE_URL',
    defaultValue: 'https://localhost:1337',
  );
  
  /// Environment name (development, staging, production)
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  /// Whether the app is running in debug mode
  static const bool isDebug = bool.fromEnvironment(
    'DEBUG',
    defaultValue: true,
  );
  
  /// Whether the app is running in production mode
  static bool get isProduction => environment == 'production';
  
  /// Whether the app is running in development mode
  static bool get isDevelopment => environment == 'development';
  
  /// Whether the app is running in staging mode
  static bool get isStaging => environment == 'staging';
  
  /// Get the full API URL for a specific endpoint
  static String getApiUrl(String endpoint) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$apiBaseUrl$cleanEndpoint';
  }
  
  /// Get the full server URL for a specific resource
  static String getServerUrl(String resource) {
    final cleanResource = resource.startsWith('/') ? resource : '/$resource';
    return '$serverBaseUrl$cleanResource';
  }
  
  /// Print environment information (useful for debugging)
  static void printEnvironment() {
    print('🌍 Environment Configuration:');
    print('   Environment: $environment');
    print('   API Base URL: $apiBaseUrl');
    print('   Server Base URL: $serverBaseUrl');
    print('   Debug Mode: $isDebug');
    print('   Production: $isProduction');
  }
} 