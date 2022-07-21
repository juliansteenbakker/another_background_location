import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:another_background_location/another_background_location.dart';

void main() {
  const channel = MethodChannel('background_location');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
