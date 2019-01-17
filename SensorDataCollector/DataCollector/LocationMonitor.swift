//
//  LocationMonitor.swift
//  SensorDataCollector
//
//  Created by baixg on 2019/1/15.
//  Copyright © 2019 baixg. All rights reserved.
//

import UIKit
import CoreLocation

class LocationMonitor: UIResponder, CLLocationManagerDelegate {
    
    public static let shared = LocationMonitor.init()
    
    override init(){
        isRunning = false
        super.init()
    }
    
    init(another : LocationMonitor) {
        self.isRunning = another.isRunning
    }
    
    var result : CLLocation = CLLocation.init()
    var locationManager = CLLocationManager.init()
    
    
    private var isRunning : Bool
    
    public func startCollectLocationData() {
        if isRunning{
            return
        }
        else{
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.delegate = self
            if #available(iOS 9.0, *) {
                // 如果APP处于后台,则会出现蓝条
                locationManager.allowsBackgroundLocationUpdates = true
            }
            locationManager.startUpdatingLocation()
            
            isRunning = true
            return
        }
    }
    
    public func stopCollectLocationData() {
        if isRunning{
            locationManager.stopUpdatingLocation()
            
            isRunning = false
            return
        }
        else{
            return
        }
    }
    
    public func getLocation() -> CLLocation {
        
        if let data = locationManager.location{
            result = data
        }
        return result
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let data = locationManager.location{
            result = data
        }
        return
    }
}
