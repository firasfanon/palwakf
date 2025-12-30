import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Track *all* current connection types (wifi + vpn, etc.)
  static Set<ConnectivityResult> _currentStatuses = {ConnectivityResult.none};

  static final StreamController<bool> _connectionController =
  StreamController<bool>.broadcast();

  // Stream to listen to connectivity changes (true/false)
  static Stream<bool> get connectionStream => _connectionController.stream;

  /// Primary/most relevant status (for display if you still want one)
  static ConnectivityResult get primaryStatus => _pickPrimary(_currentStatuses);

  /// Connected at all?
  static bool get isConnected =>
      _currentStatuses.isNotEmpty &&
          !_currentStatuses.contains(ConnectivityResult.none);

  /// Specific transports
  static bool get isConnectedToWiFi =>
      _currentStatuses.contains(ConnectivityResult.wifi);
  static bool get isConnectedToMobile =>
      _currentStatuses.contains(ConnectivityResult.mobile);

  // Initialize connectivity service
  static Future<void> init() async {
    try {
      // Initial statuses
      final initial = await _connectivity.checkConnectivity();
      _currentStatuses = initial.toSet();

      // Listen to changes (List<ConnectivityResult>)
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_onConnectivityChanged,
              onError: (error) {
                debugPrint('Connectivity error: $error');
              });

      debugPrint(
          'Connectivity service initialized. Current statuses: $_currentStatuses');
      // Emit initial state
      _connectionController.add(isConnected);
    } catch (e) {
      debugPrint('Error initializing connectivity service: $e');
    }
  }

  // Handle connectivity changes
  static void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasConnected = isConnected;

    _currentStatuses = results.toSet();
    final isNowConnected = isConnected;

    debugPrint('Connectivity changed: $_currentStatuses');

    // Notify listeners about connection status change
    _connectionController.add(isNowConnected);

    // Handle connection state transitions
    if (!wasConnected && isNowConnected) {
      _onConnectionRestored();
    } else if (wasConnected && !isNowConnected) {
      _onConnectionLost();
    }
  }

  static void _onConnectionRestored() {
    debugPrint('Internet connection restored');
    // e.g., trigger retries/sync here
  }

  static void _onConnectionLost() {
    debugPrint('Internet connection lost');
    // e.g., queue pending ops / show banner
  }

  // Check connectivity with timeout
  static Future<bool> checkConnectivity(
      {Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final results =
      await _connectivity.checkConnectivity().timeout(timeout); // List<ConnectivityResult>
      _currentStatuses = results.toSet();
      return isConnected;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  // Test internet connection (simple)
  static Future<bool> hasInternetConnection() async {
    try {
      if (!isConnected) return false;
      // Optionally: perform a lightweight HTTP HEAD to a reliable endpoint
      return true;
    } catch (e) {
      debugPrint('Error testing internet connection: $e');
      return false;
    }
  }

  // Human-readable description (handles multiple transports)
  static String getConnectivityDescription() {
    if (!isConnected) return 'غير متصل بالإنترنت';

    final types = <String>[];
    if (isConnectedToWiFi) types.add('واي فاي');
    if (isConnectedToMobile) types.add('بيانات الهاتف');
    if (_currentStatuses.contains(ConnectivityResult.ethernet)) types.add('إيثرنت');
    if (_currentStatuses.contains(ConnectivityResult.bluetooth)) types.add('بلوتوث');
    if (_currentStatuses.contains(ConnectivityResult.vpn)) types.add('VPN');
    if (_currentStatuses.contains(ConnectivityResult.other)) types.add('شبكة أخرى');

    // Fallback to primary if nothing matched above
    if (types.isEmpty) {
      return _arabicLabel(primaryStatus);
    }
    return 'متصل: ${types.join(' + ')}';
  }

  // Show connectivity snackbar
  static void showConnectivitySnackBar(BuildContext context) {
    final message = getConnectivityDescription();
    final color = isConnected ? Colors.green : Colors.red;
    final icon = isConnected ? Icons.wifi : Icons.wifi_off;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Wait for connection
  static Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
    Duration checkInterval = const Duration(seconds: 1),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      if (await checkConnectivity()) return true;
      await Future.delayed(checkInterval);
    }
    return false;
  }

  // Execute function when connected
  static Future<T?> executeWhenConnected<T>(
      Future<T> Function() function, {
        Duration timeout = const Duration(seconds: 30),
      }) async {
    if (isConnected) return await function();

    final connected = await waitForConnection(timeout: timeout);
    if (connected) return await function();

    throw Exception('No internet connection available');
  }

  // Retry with connectivity check
  static Future<T> retryWithConnectivity<T>(
      Future<T> Function() function, {
        int maxRetries = 3,
        Duration delay = const Duration(seconds: 2),
      }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        if (!isConnected) {
          await waitForConnection(timeout: delay);
        }
        return await function();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        debugPrint('Retry attempt $attempts failed: $e');
        await Future.delayed(delay);
      }
    }
    throw Exception('Max retries exceeded');
  }

  // Get network info
  static Map<String, dynamic> getNetworkInfo() {
    return {
      'statuses': _currentStatuses.map((e) => e.toString()).toList(),
      'primary_status': primaryStatus.toString(),
      'is_connected': isConnected,
      'is_wifi': isConnectedToWiFi,
      'is_mobile': isConnectedToMobile,
      'description': getConnectivityDescription(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Dispose resources
  static Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _connectionController.close();
  }

  /// Helpers

  // Choose a single "primary" status for display
  static ConnectivityResult _pickPrimary(Set<ConnectivityResult> set) {
    if (set.isEmpty || set.contains(ConnectivityResult.none)) {
      return ConnectivityResult.none;
    }
    // Priority: wifi > ethernet > mobile > vpn > bluetooth > other
    if (set.contains(ConnectivityResult.wifi)) return ConnectivityResult.wifi;
    if (set.contains(ConnectivityResult.ethernet)) return ConnectivityResult.ethernet;
    if (set.contains(ConnectivityResult.mobile)) return ConnectivityResult.mobile;
    if (set.contains(ConnectivityResult.vpn)) return ConnectivityResult.vpn;
    if (set.contains(ConnectivityResult.bluetooth)) return ConnectivityResult.bluetooth;
    return ConnectivityResult.other;
  }

  static String _arabicLabel(ConnectivityResult r) {
    switch (r) {
      case ConnectivityResult.wifi:
        return 'متصل بالواي فاي';
      case ConnectivityResult.mobile:
        return 'متصل ببيانات الهاتف';
      case ConnectivityResult.ethernet:
        return 'متصل بالإيثرنت';
      case ConnectivityResult.bluetooth:
        return 'متصل بالبلوتوث';
      case ConnectivityResult.vpn:
        return 'متصل عبر VPN';
      case ConnectivityResult.other:
        return 'متصل بشبكة أخرى';
      case ConnectivityResult.none:
        return 'غير متصل بالإنترنت';
    }
  }
}

// Connectivity-aware widget (unchanged API)
class ConnectivityBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isConnected) builder;
  final Widget? disconnectedWidget;

  const ConnectivityBuilder({
    super.key,
    required this.builder,
    this.disconnectedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService.connectionStream,
      initialData: ConnectivityService.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;

        if (!isConnected && disconnectedWidget != null) {
          return disconnectedWidget!;
        }

        return builder(context, isConnected);
      },
    );
  }
}

// Offline indicator widget (unchanged)
class OfflineIndicator extends StatelessWidget {
  final Widget child;
  final String? message;

  const OfflineIndicator({
    super.key,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ConnectivityBuilder(
      builder: (context, isConnected) {
        return Column(
          children: [
            if (!isConnected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      message ?? 'لا يوجد اتصال بالإنترنت',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
