import Flutter
import UIKit
import CoreLocation

public class SwiftBackgroundLocationPlugin: NSObject, FlutterPlugin {
    
    private let anotherBackgroundLocationManager: AnotherBackgroundLocationManager
    
    static var channel: FlutterMethodChannel?
    
    private let locationHandler: LocationHandler
    init(locationHandler: LocationHandler) {
        self.locationHandler = locationHandler
        anotherBackgroundLocationManager = AnotherBackgroundLocationManager(locationHandler: locationHandler)
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "dev.steenbakker.background_location/methods", binaryMessenger: registrar.messenger())
      let instance = SwiftBackgroundLocationPlugin(locationHandler: LocationHandler(registrar: registrar))
      registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "start_location_service":
            anotherBackgroundLocationManager.startLocationService(call, result)
        case "stop_location_service":
            anotherBackgroundLocationManager.stopLocationService(result)
//        case "get_current_location":
//            X
//        case "set_configuration":
//            x
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
