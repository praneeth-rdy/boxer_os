# wakelock_plus test channel

`wakelock_plus` (1.7.0) is not a plain `MethodChannel` plugin on the default test platform;
`WakelockPlus.enable/disable` route through `wakelock_plus_platform_interface`'s pigeon-generated
`MethodChannelWakelockPlus`, which uses a `BasicMessageChannel` named
`dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle` (no suffix by
default), not `setMockMethodCallHandler`.

Don't import `wakelock_plus_platform_interface` in tests to extend its platform interface class
or reach `WakelockPlusApi.pigeonChannelCodec` - it's a transitive dependency only, and doing so
trips the `depend_on_referenced_packages` lint (`flutter analyze` does enforce it here, via
`package:lints/recommended.yaml`).

Instead mock at the raw byte level with
`TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(channel, handler)`
and reply with `const StandardMessageCodec().encodeMessage(<Object?>[])` for success or
`encodeMessage(<Object?>[code, message, details])` for a platform failure (the pigeon wire
protocol: an empty/short list is success, a 3-element list is an error that the caller turns into
a `PlatformException`). See `test/services/wake_lock_service_test.dart`.
