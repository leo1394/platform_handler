import 'package:flutter/services.dart';
import 'platform_notification.dart';

/// An abstract class for the platform notification manager.
///
/// This class is used to create an abstract class for the platform notification manager.
abstract class PlatformNotificationManager {
  /// A method for dispatching the notification to the platform.
  ///
  /// This method is used to dispatch the notification to the platform.
  dynamic n2fCallDispatcher(MethodCall call);

  /// A method for subscribing to the notification.
  ///
  /// This method is used to subscribe to the notification.
  void subscribe(List<PlatformNotification> notifications);
}
