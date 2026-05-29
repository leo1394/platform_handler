import 'package:extension_dart/utils.dart';

import 'platform_notification.dart';

/// A platform notification for one request and one terminal response.
class PingPongPlatformNotification extends PlatformNotification {
  static const String requestIdKey = 'requestId';
  static const String requestArgumentsKey = 'arguments';
  static const String responseDataKey = 'responseData';

  final int maxCompletedRequestIds;
  final Set<String> _completedRequestIds = <String>{};
  final List<String> _completedRequestIdOrder = <String>[];
  String? _activeRequestId;

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

  String? get activeRequestId => _activeRequestId;

  bool isTerminalResponse(String method) => true;

  bool isActiveRequestId(String? requestId) {
    return requestId != null &&
        requestId == _activeRequestId &&
        !_completedRequestIds.contains(requestId);
  }

  void completeActiveRequest() {
    completeRequest(_activeRequestId);
  }

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

  static dynamic responseDataFrom(dynamic arguments) {
    if (arguments is Map && arguments.containsKey(responseDataKey)) {
      return arguments[responseDataKey];
    }
    return arguments;
  }

  void onRequestIgnored(String method, dynamic arguments) {}
  void onRequest(String? requestId, dynamic arguments) {}
  void onResponse(String? requestId, dynamic arguments) {}

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
