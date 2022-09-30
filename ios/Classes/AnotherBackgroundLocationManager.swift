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
    
    static var locationManager: CLLocationManager = CLLocationManager()
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
           
        }
    }
    
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

        SwiftBackgroundLocationPlugin.channel?.invokeMethod("location", arguments: location)
    }
}
