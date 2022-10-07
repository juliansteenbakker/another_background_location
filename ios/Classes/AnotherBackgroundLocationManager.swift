//
//  AnotherBackgroundLocationManager.swift
//  another_background_location
//
//  Created by Julian Steenbakker on 21/08/2022.
//

import Foundation
import Flutter
import UIKit
import CoreLocation

public class AnotherBackgroundLocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
//    let locationManager: CLLocationManager? = nil
    let locationHandler: LocationHandler
    
    init(locationHandler: LocationHandler) {
        self.locationHandler = locationHandler
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .other
        super.init()
        locationManager.delegate = self
    }
    
//    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedAlways {
//
//        }
//    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = [
            "speed": locations.last!.speed,
            "altitude": locations.last!.altitude,
            "latitude": locations.last!.coordinate.latitude,
            "longitude": locations.last!.coordinate.longitude,
            "accuracy": locations.last!.horizontalAccuracy,
            "bearing": locations.last!.course,
            "time": locations.last!.timestamp.timeIntervalSince1970 * 1000,
            "is_mock": false
        ] as [String : Any]
        locationHandler.publishScanResult(location: location)
    }
    
    
    public func getLocation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        locationManager.allowsBackgroundLocationUpdates = true
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true;
        }
        locationManager.pausesLocationUpdatesAutomatically = false
        result(true)
    }
    
    func startLocationService(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        let distanceFilter = args?["distance_filter"] as? Double
        self.locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        locationManager.distanceFilter = distanceFilter ?? 0

        locationManager.startUpdatingLocation()
        result(nil)
    }
    
    func stopLocationService(_ result: @escaping FlutterResult) {
        locationManager.stopUpdatingLocation()
        result(nil)
    }
}
