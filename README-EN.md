# platform_handler

[![pub package](https://img.shields.io/pub/v/platform_handler.svg)](https://pub.dev/packages/platform_handler)
[![pub points](https://img.shields.io/pub/points/platform_handler?color=2E8B57&label=pub%20points)](https://pub.dev/packages/platform_handler/score)
[![GitHub Issues](https://img.shields.io/github/issues/leo1394/platform_handler.svg?branch=master)](https://github.com/leo1394/platform_handler/issues)
[![GitHub License](https://img.shields.io/badge/license-MIT%20-blue.svg)](https://raw.githubusercontent.com/leo1394/platform_handler/master/LICENSE)

A small Flutter helper for organizing native `MethodChannel` callbacks.

`platform_handler` lets you register one native channel, subscribe callback handlers by method name, and invoke native methods through the same manager. For request-response style calls, `PingPongPlatformNotification` automatically attaches a `requestId` and ignores stale or duplicated responses.

## Features

- Register a native `MethodChannel` in one place.
- Route native callbacks to focused `PlatformNotification` classes.
- Invoke native methods without exposing `MethodChannel` to business code.
- Built-in ping-pong request id handling for one request and one terminal response.

Language: English | [中文](README.md)

## Quick Start

```dart
final handler = AppPlatformHandler();

handler.registerChannel('native.demo.com/messageChannel');
handler.subscribe([
  logNotification,
  ruleNotification,
]);
```

### Handle Native Callbacks

```dart
class AppPlatformHandler extends PlatformHandler {
  @override
  Future<dynamic> n2fCallDispatcher(MethodCall call) async {
    print('native -> flutter: ${call.method}, ${call.arguments}');
    return super.n2fCallDispatcher(call);
  }
}

class LogNotification extends PlatformNotification {
  LogNotification() {
    subscribers = {
      'LogCallback': onLog,
    };
  }

  void listen() {
    docking = true;
  }

  void onLog(dynamic arguments) {
    print(arguments);
  }
}
```

### Invoke Native Methods

```dart
logNotification.listen();
await handler.invokeMethod('startLog');
```

## Ping-Pong Requests

Use `PingPongPlatformNotification` when each request should accept only one terminal response.

```dart
class RuleNotification extends PingPongPlatformNotification {
  RuleNotification() {
    subscribers = {
      'RuleResult': onRuleResult,
    };
  }

  void listen() {
    docking = true;
  }

  void onRuleResult(dynamic responseData) {
    print('rule result: $responseData');
  }
}

final ruleNotification = RuleNotification();
ruleNotification.listen();

await handler.invokeMethod(
  'luaScript',
  'return 1',
  ruleNotification,
);
```

When the notification is ping-pong, `invokeMethod` sends this shape to native:

```dart
{
  'requestId': 'ph-request...',
  'arguments': originalArguments,
}
```

Native should return:

```dart
{
  'requestId': sameRequestId,
  'responseData': nativeResult,
}
```

Only the matching response is delivered to `onRuleResult`. Late, duplicated, or mismatched responses are ignored.

## Native Side

Use the same method channel name on Android and iOS:

```text
native.demo.com/messageChannel
```

Then call Flutter with the method names subscribed by your notifications, for example `LogCallback` or `RuleResult`.

## Additional Information

Issues and suggestions are welcome on GitHub.
