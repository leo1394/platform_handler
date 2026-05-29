import 'package:extension_dart/utils.dart';

import 'platform_notification.dart';

/// A platform notification for one request and one terminal response.
class PingPongPlatformNotification extends PlatformNotification {
  /// The payload key used to store the generated request id.
  static const String requestIdKey = 'requestId';

  /// The payload key used to store the original request arguments.
  static const String requestArgumentsKey = 'arguments';

  /// The payload key used to store response data in native callbacks.
  static const String responseDataKey = 'responseData';

  /// The maximum number of completed request ids retained for duplicate checks.
  final int maxCompletedRequestIds;
  final Set<String> _completedRequestIds = <String>{};
  final List<String> _completedRequestIdOrder = <String>[];
  String? _activeRequestId;

  /// Creates a notification that matches one active request to one response.
  PingPongPlatformNotification({this.maxCompletedRequestIds = 128});

  /// Creates a new request id and wraps the platform arguments with it.
  ///
  /// Native implementations should echo [requestIdKey] back in callback payloads
  /// so delayed or duplicated callbacks can be ignored by this receiver.
  Map<String, dynamic> requestArguments(dynamic arguments) {
    _activeRequestId = Utils.fastUUID();
    onRequest(_activeRequestId, arguments);
    return {
      requestIdKey: _activeRequestId,
      requestArgumentsKey: arguments,
    };
  }

  /// The request id currently waiting for a terminal response.
  String? get activeRequestId => _activeRequestId;

  /// Whether a callback method should complete the active request.
  bool isTerminalResponse(String method) => true;

  /// Whether [requestId] matches the active request and has not completed.
  bool isActiveRequestId(String? requestId) {
    return requestId != null &&
        requestId == _activeRequestId &&
        !_completedRequestIds.contains(requestId);
  }

  /// Marks the current active request as completed.
  void completeActiveRequest() {
    completeRequest(_activeRequestId);
  }

  /// Marks [requestId] as completed and clears it if it is active.
  void completeRequest(String? requestId) {
    if (requestId == null || requestId.isEmpty) {
      return;
    }
    if (_completedRequestIds.add(requestId)) {
      _completedRequestIdOrder.add(requestId);
      while (_completedRequestIdOrder.length > maxCompletedRequestIds) {
        _completedRequestIds.remove(_completedRequestIdOrder.removeAt(0));
      }
    }
    if (_activeRequestId == requestId) {
      _activeRequestId = null;
    }
  }

  /// Extracts a request id from map or JSON string callback arguments.
  static String? requestIdFrom(dynamic arguments) {
    if (arguments is Map) {
      final requestId = arguments[requestIdKey];
      return requestId?.toString();
    }
    if (arguments is String) {
      final decoded = Utils.tryJsonDecode(arguments);
      if (decoded is Map) {
        final requestId = decoded[requestIdKey];
        return requestId?.toString();
      }
    }
    return null;
  }

  /// Extracts response data from callback arguments.
  static dynamic responseDataFrom(dynamic arguments) {
    if (arguments is Map && arguments.containsKey(responseDataKey)) {
      return arguments[responseDataKey];
    }
    return arguments;
  }

  /// Called when a callback is ignored because it does not match the active request.
  void onRequestIgnored(String method, dynamic arguments) {}

  /// Called after a request id is created for outgoing platform arguments.
  void onRequest(String? requestId, dynamic arguments) {}

  /// Called before subscriber callbacks receive a matching response.
  void onResponse(String? requestId, dynamic arguments) {}

  /// Receives a native callback and dispatches it when it matches the active request.
  @override
  dynamic receiver(String method, dynamic arguments) {
    if (!docking || subscribers.isEmpty || !subscribers.containsKey(method)) {
      return false;
    }

    final requestId = requestIdFrom(arguments);
    if (!isActiveRequestId(requestId)) {
      onRequestIgnored(method, arguments);
      return false;
    }

    if (isTerminalResponse(method)) {
      completeRequest(requestId);
    }
    dynamic data = responseDataFrom(arguments);
    onResponse(requestId, data);
    Function.apply(subscribers[method]!, [data]);
    return true;
  }
}
