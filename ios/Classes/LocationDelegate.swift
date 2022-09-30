//
//  LocationDelegate.swift
//  another_background_location
//
//  Created by Julian Steenbakker on 21/08/2022.
//

import Foundation

public class LocationDelegate: NSObject, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    
    private let eventChannel: FlutterEventChannel
    
    init(registrar: FlutterPluginRegistrar) {
        eventChannel = FlutterEventChannel(name: "dev.steenbakker.flutter_ble_central/scan_result",
                                               binaryMessenger: registrar.messenger())
        super.init()
        eventChannel.setStreamHandler(self)
    }
    
    func publishScanResult() {
        if let eventSink = self.eventSink {
//            let deviceDiscoveryMessage = [
//                "rssi": Int32(rssi),
//            ] as [String : Any]
//            eventSink(deviceDiscoveryMessage)
        }
    }
    
    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

}

