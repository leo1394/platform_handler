import 'package:flutter/services.dart';
import 'platform_notification.dart';

/// An abstract class for the platform notification manager.
///
/// This class is used to create an abstract class for the platform notification manager.
abstract class PlatformNotificationManager {
  /// A method for registering the native method channel.
  ///
  /// This method is used to register the channel used for Flutter-native calls.
  void registerChannel(
    String channelName, {
    Future<dynamic> Function(MethodCall call)? handler,
  });

  /// A method for dispatching the notification to the platform.
  ///
  /// This method is used to dispatch the notification to the platform.
  dynamic n2fCallDispatcher(MethodCall call);

  /// A method for subscribing to the notification.
  ///
  /// This method is used to subscribe to the notification.
  void subscribe(List<PlatformNotification> notifications);

  /// A method for invoking a native platform method.
  ///
  /// Ping-pong notifications automatically wrap arguments with a request id.
  Future<T?> invokeMethod<T>(
    String method, [
    dynamic arguments,
    PlatformNotification? notification,
  ]);

  /// A method for invoking a native platform method that returns a list.
  ///
  /// Ping-pong notifications automatically wrap arguments with a request id.
  Future<List<T>?> invokeListMethod<T>(
    String method, [
    dynamic arguments,
    PlatformNotification? notification,
  ]);
}
