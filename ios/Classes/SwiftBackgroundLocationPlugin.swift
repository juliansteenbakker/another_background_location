import Flutter
import UIKit
import CoreLocation

public class SwiftBackgroundLocationPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    
    private let anotherBackgroundLocationManager: AnotherBackgroundLocationManager
    private let locationDelegate: LocationDelegate
    
    init(locationDelegate: LocationDelegate) {
        self.locationDelegate = locationDelegate
        anotherBackgroundLocationManager = AnotherBackgroundLocationManager(locationDelegate: LocationDelegate)
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "dev.steenbakker.background_location/methods", binaryMessenger: registrar.messenger())
      let instance = SwiftBackgroundLocationPlugin(scanResultHandler: ScanResultHandler(registrar: registrar), stateChangedHandler: StateChangedHandler(registrar: registrar))
      registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "start":
            startScan(result)
        case "stop":
            stopScan(result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    static var locationManager: CLLocationManager = CLLocationManager()
    static var channel: FlutterMethodChannel?
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        SwiftBackgroundLocationPlugin.locationManager?.delegate = self
        SwiftBackgroundLocationPlugin.locationManager?.requestAlwaysAuthorization()

        SwiftBackgroundLocationPlugin.locationManager?.allowsBackgroundLocationUpdates = true
        if #available(iOS 11.0, *) {
            SwiftBackgroundLocationPlugin.locationManager?.showsBackgroundLocationIndicator = true;
        }
        SwiftBackgroundLocationPlugin.locationManager?.pausesLocationUpdatesAutomatically = false

        SwiftBackgroundLocationPlugin.channel?.invokeMethod("location", arguments: "method")


        result(true)
    }
    
    private func startLocationService(_ result: @escaping FlutterResult) {
        SwiftBackgroundLocationPlugin.channel?.invokeMethod("location", arguments: "start_location_service")
        
        let args = call.arguments as? Dictionary<String, Any>
        let distanceFilter = args?["distance_filter"] as? Double
        SwiftBackgroundLocationPlugin.locationManager?.distanceFilter = distanceFilter ?? 0
        
        SwiftBackgroundLocationPlugin.locationManager?.startUpdatingLocation()
        result(nil)
    }
    
    private func stopLocationService(_ result: @escaping FlutterResult) {
        SwiftBackgroundLocationPlugin.channel?.invokeMethod("location", arguments: "stop_location_service")
        SwiftBackgroundLocationPlugin.locationManager?.stopUpdatingLocation()
        result(nil)
    }
}
