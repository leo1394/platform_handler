# platform_handler

[![pub package](https://img.shields.io/pub/v/platform_handler.svg)](https://pub.dev/packages/platform_handler)
[![pub points](https://img.shields.io/pub/points/platform_handler?color=2E8B57&label=pub%20points)](https://pub.dev/packages/platform_handler/score)
[![GitHub Issues](https://img.shields.io/github/issues/leo1394/platform_handler.svg?branch=master)](https://github.com/leo1394/platform_handler/issues)
[![GitHub License](https://img.shields.io/badge/license-MIT%20-blue.svg)](https://raw.githubusercontent.com/leo1394/platform_handler/master/LICENSE)

一个用于整理 Flutter `MethodChannel` 通信的小工具。

`platform_handler` 可以让你只注册一次 native channel，然后按 method name 把 Native 回调分发给对应的 notification。对于请求-响应型调用，`PingPongPlatformNotification` 会自动添加 `requestId`，并忽略过期、重复或不匹配的响应。

English documentation: [README.md](README.md)

## 特性

- 集中注册 native `MethodChannel`。
- 按 method name 将 Native 回调路由到独立的 `PlatformNotification`。
- 业务代码通过 manager 调用 Native，不需要直接持有 `MethodChannel`。
- 内置 ping-pong request id 机制，适合一次请求只接受一次终态响应的场景。

## 快速开始

```dart
final handler = AppPlatformHandler();

handler.registerChannel('native.demo.com/messageChannel');
handler.subscribe([
  logNotification,
  ruleNotification,
]);
```

### 处理 Native 回调

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

### 调用 Native 方法

```dart
logNotification.listen();
await handler.invokeMethod('startLog');
```

## Ping-Pong 请求

当每次请求只应该接受一次终态响应时，使用 `PingPongPlatformNotification`。

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

当 notification 是 ping-pong 类型时，`invokeMethod` 会自动把请求参数包装成：

```dart
{
  'requestId': 'ph-request...',
  'arguments': originalArguments,
}
```

Native 侧应按下面结构返回：

```dart
{
  'requestId': sameRequestId,
  'responseData': nativeResult,
}
```

只有 requestId 匹配的响应会进入 `onRuleResult`。超时后才返回、重复返回、或 requestId 不匹配的响应都会被忽略。

## Native 侧

Android 和 iOS 使用同一个 channel name：

```text
native.demo.com/messageChannel
```

然后按 notification 订阅的方法名回调 Flutter，例如 `LogCallback` 或 `RuleResult`。

## 适用场景

- 日志回调
- 定位回调
- 扫码回调
- Lua/规则执行
- 其他 Native bridge 请求-响应场景

## 更多信息

欢迎在 GitHub 提交 issue 或建议。
