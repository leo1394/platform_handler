import 'package:enhanced_change_notifier/signal.dart';

/// A base class for platform notifications.
///
/// This class is used to create a base class for platform notifications.
class PlatformNotification {
  /// A signal for throttling the notification.
  ///
  /// This signal is used to throttle the notification.
  Signal throttlingSignal = Signal();

  /// A map of subscribers for the notification.
  ///
  /// This map is used to store the subscribers for the notification.
  Map<String, Function> subscribers = {};

  /// A flag for the docking state of the notification.
  ///
  /// This flag is used to store the docking state of the notification.
  bool docking = false;

  /// A method for receiving the notification.
  ///
  /// This method is used to receive the notification.
  dynamic receiver(String method, dynamic arguments) {
    if (!docking || subscribers.isEmpty || !subscribers.containsKey(method)) {
      return;
    }
    Function.apply(subscribers[method]!, [arguments]);
  }

  /// A method for getting the subscriptions of the notification.
  ///
  /// This method is used to get the subscriptions of the notification.
  List<String> getSubscriptions() => subscribers.keys.toList();

  /// A method for docking off the notification.
  ///
  /// This method is used to docking off the notification.
  void dockingOff() {
    docking = false;
  }

  /// A method for docking on the notification.
  ///
  /// This method is used to docking on the notification.
  void dockingOn() {
    docking = true;
  }
}
