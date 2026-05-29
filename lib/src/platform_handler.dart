import 'package:flutter/services.dart';
import 'package:enhanced_change_notifier/enhanced_change_notifier.dart';
import 'ping_pong_platform_notification.dart';
import 'platform_notification.dart';
import 'platform_notification_manager.dart';

/// A class for the platform handler.
///
/// This class is used to create a class for the platform handler.
class PlatformHandler extends EnhancedChangeNotifier
    implements PlatformNotificationManager {
  MethodChannel? _methodChannel;

  /// Registers the method channel used for Flutter-native calls.
  @override
  void registerChannel(
    String channelName, {
    Future<dynamic> Function(MethodCall call)? handler,
  }) {
    _methodChannel = MethodChannel(channelName);
    _methodChannel!.setMethodCallHandler(handler ?? n2fCallDispatcher);
  }

  /// Subscribes platform notifications to their registered methods.
  @override
  void subscribe(List<PlatformNotification> notifications) {
    for (var element in notifications) {
      super.addListener(element.receiver, target: element.getSubscriptions());
    }
  }

  /// Dispatches native-to-Flutter callbacks to matching subscribers.
  @override
  Future<dynamic> n2fCallDispatcher(MethodCall call) async {
    if (hasListeners) {
      super.properties[call.method] = call.arguments;
      notifyListeners(call.method);
    }
    return "SUCCESS";
  }

  /// Invokes a native platform method with optional notification wrapping.
  @override
  Future<T?> invokeMethod<T>(
    String method, [
    dynamic arguments,
    PlatformNotification? notification,
  ]) {
    return _channel.invokeMethod<T>(
      method,
      _platformArguments(arguments, notification),
    );
  }

  /// Invokes a native platform method that returns a list.
  @override
  Future<List<T>?> invokeListMethod<T>(
    String method, [
    dynamic arguments,
    PlatformNotification? notification,
  ]) {
    return _channel.invokeListMethod<T>(
      method,
      _platformArguments(arguments, notification),
    );
  }

  dynamic _platformArguments(
      dynamic arguments, PlatformNotification? notification) {
    if (notification is PingPongPlatformNotification) {
      return notification.requestArguments(arguments);
    }
    return arguments;
  }

  MethodChannel get _channel {
    final channel = _methodChannel;
    if (channel == null) {
      throw StateError("Platform channel has not been registered.");
    }
    return channel;
  }
}
