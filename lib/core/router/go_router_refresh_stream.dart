import 'dart:async';
import 'package:flutter/foundation.dart';

/// A ChangeNotifier that listens to a stream and notifies listeners when the stream emits.
/// This is used to refresh GoRouter when auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
