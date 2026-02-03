import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';

class StripeConfig {
  static const String _testKey =
      'pk_test_51SXnwrCuZzSxcGtXYuOnwQJVlETMAkrkBKH6cieCuCDBpOIB5iStCYjagh45sCRrVpx1mmNf0ZQnfIhu9gwgeDyU00uOGl3J6v';

  static const String _liveKey =
      'pk_live_51SQDUJAI5OdDBekTZlVnIdEG9vueafDa0Uxrp8OuQpA9cobKyAz3oleiXD3KZfI3ye3vfHlBq24FLCY9gNjJLa8q00REIDeFWe';

  static const String _merchantId = 'merchant.com.edmsolutions';

  static bool _initCalled = false;
  static bool _settingsApplied = false;
  static bool _initializing = false;

  /// Called ONCE at app startup (sync, safe)
  static void init() {
    if (_initCalled) return;

    Stripe.publishableKey = kReleaseMode ? _liveKey : _testKey;
    Stripe.merchantIdentifier = _merchantId;

    _initCalled = true;
  }

  /// Call before showing CardField
  static Future<void> ensureReady() async {
    if (!_initCalled) {
      init();
    }

    if (_settingsApplied || _initializing) return;

    _initializing = true;

    try {
      await Stripe.instance.applySettings();
      _settingsApplied = true;
    } catch (e) {
      debugPrint('Stripe applySettings failed: $e');
      // ❗ do NOT throw
      // ❗ allow retry on next UI build
    } finally {
      _initializing = false;
    }
  }
}
