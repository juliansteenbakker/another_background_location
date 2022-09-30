import 'dart:async';
import 'dart:io' show Platform;

import 'package:another_background_location/src/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// BackgroundLocation plugin to get background
/// lcoation updates in iOS and Android
class BackgroundLocation {
  /// Singleton instance
  static final BackgroundLocation _instance = BackgroundLocation._internal();

  /// Singleton factory
  factory BackgroundLocation() {
    return _instance;
  }

  /// Singleton constructor
  BackgroundLocation._internal();

  /// Method Channel used to communicate state with
  static const MethodChannel _methodChannel =
  MethodChannel('dev.steenbakker.background_location/methods');

  /// Event Channel for events from platform side
  static const EventChannel _eventChannel = EventChannel(
    'dev.steenbakker.background_location/events',
  );

  final receivetest = _eventChannel
      .receiveBroadcastStream()
      .distinct()
      .map((event) {
        return Location.fromJson(Map<String, dynamic>.from(event as Map));
  });

  /// Start receiving location updated
  Future<void> startLocationService({double distanceFilter = 0.0,
    bool forceAndroidLocationManager = false,}) =>
      _methodChannel.invokeMethod('start_location_service', <String, dynamic>{
        'distance_filter': distanceFilter,
        'force_location_manager': forceAndroidLocationManager
      });

  /// Stop receiving location updates
  Future<void> stopLocationService() =>
      _methodChannel.invokeMethod('stop_location_service');

  Future<void> setAndroidNotification(
      {String? title, String? message, String? icon,}) async {
    if (Platform.isAndroid) {
      return _methodChannel.invokeMethod('set_android_notification',
        <String, dynamic>{'title': title, 'message': message, 'icon': icon},);
    } else {
      debugPrint('setAndroidNotification is only possible on Android!');
    }
  }

  Future<void> setAndroidConfiguration(int interval) async {
    if (Platform.isAndroid) {
      return _methodChannel.invokeMethod('set_configuration', <String, dynamic>{
        'interval': interval.toString(),
      });
    } else {
      debugPrint('setAndroidConfiguration is only possible on Android!');
    }
  }

  /// Get the current location once.
  Future<Location?> getCurrentLocation() async{
    final location = await _methodChannel.invokeMapMethod<String, dynamic>('get_current_location');
    if (location == null) {
      return null;
    }
    return Location.fromJson(location);
  }

  /// Register a function to receive location updates as long as the location
  /// service has started
  Future<void> getLocationUpdates(Function(Location) callback) async =>
      // add a handler on the channel to recive updates from the native classes
  _methodChannel.setMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'location') {
      final locationData = Map<String, dynamic>.from(methodCall.arguments as Map<String, dynamic>);
      // Call the user passed function
      callback(
        Location.fromJson(locationData)
        // Location().fromMap(locationData);
      //   Location(
      //       latitude: locationData['latitude'],
      //       longitude: locationData['longitude'],
      //       altitude: locationData['altitude'],
      //       accuracy: locationData['accuracy'],
      //       bearing: locationData['bearing'],
      //       speed: locationData['speed'],
      //       time: locationData['time'],
      //       isMock: locationData['is_mock']),
      );
    }
  });

  // Stream<Location>? _locationState;

  // /// Returns Stream of MTU updates.
  // Stream<Location> get onLocationUpdate {
  //   _locationState ??= _eventChannel
  //       .receiveBroadcastStream()
  //       .cast<Map<String, dynamic>>()
  //       .distinct()
  //       .map((Map<String, dynamic> event) {
  //         final location = Location.fromJson(event);
  //         return location;
  //   });
  //   return _locationState!;
  // }
}
