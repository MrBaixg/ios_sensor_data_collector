//
//  Network.swift
//  SensorDataCollector
//
//  Created by baixg on 2019/1/16.
//  Copyright © 2019 baixg. All rights reserved.
//

import Foundation
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork

class NetworkMonitor {
    
    init() {
        
    }
    public func getWifiInfo() -> (ssid: String, mac: String) {
        let interfaces:NSArray = CNCopySupportedInterfaces()!
        var ssid: String?
        var mac: String?
        for sub in interfaces
        {
            if let dict = CFBridgingRetain(CNCopyCurrentNetworkInfo(sub as! CFString))
            {
                ssid = dict["SSID"] as? String
                mac = dict["BSSID"] as? String
            }
        }
        return (ssid ?? "", mac ?? "")
    }
}
