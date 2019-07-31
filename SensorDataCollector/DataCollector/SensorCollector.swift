//
//  SensorDataCollector.swift
//  SensorDataCollector
//
//  Created by baixg on 2019/1/14.
//  Copyright © 2019 baixg. All rights reserved.
//

import UIKit
import Foundation
import CoreMotion


enum Frequency : String {
    case HZ_1 = "1 HZ"
    case HZ_10 = "10 HZ"
    case HZ_20 = "20 HZ"
    case HZ_50 = "50 HZ"
    case HZ_100 = "100 HZ"
}



class SensorCollector: UIResponder {
    
    static let shared = SensorCollector.init()
    
    override init(){
        isRunning = false
        frequency = Frequency.HZ_1
        super.init()
    }
    
    init(another : SensorCollector) {
        self.isRunning = another.isRunning
        self.frequency = Frequency.HZ_1
    }
    
    private var isRunning : Bool
    
    /****************experiment information************************/
    private var startTime : Date?
    private var endTime : Date?
    private var frequency : Frequency
    
    private var pedometerData = CMPedometerData.init()
    private var altitudeData = CMAltitudeData.init()
    private var activity = MotionActivity.Unkown
    private var confidence = "low"
    private var proximityStatus = "Leaving."
//    private var audioURL : URL!

    private let motionManager = CMMotionManager.init()
    private let motionActivityManager = CMMotionActivityManager.init()
    private let pedometer = CMPedometer.init()
    private let altitudeSensor = CMAltimeter.init()
    private let locationMonitor = LocationMonitor.init()
    private let bluetoothMonitor = BluetoothMonitor.init()
    private let networkMonitor = NetworkMonitor.init()

    private var timeIntervalUpdate = 1.0
    private var refreshTimer : Timer!
    
    public func startCollectSensorData() {
        if isRunning{
            return
        }
        else{
            startMotionData()
            locationMonitor.startCollectLocationData()
//            startPedometerData()
//            startAltitudeData()
//            startProximityStatus()
            
//            bluetoothMonitor.startScanPeripheral()
//            bluetoothMonitor.stopScanPeripheral()
//            bluetoothMonitor.startScanPeripheral()
            
            isRunning = true
        }
    }
    
    public func stopCollectSensorData() {
        if isRunning{
            stopMotionData()
            locationMonitor.stopCollectLocationData()
//            stopPedometerData()
//            stopAltitudeData()
//            stopProximityStatus()
//            bluetoothMonitor.stopScanPeripheral()
            
            isRunning = false
            return
        }
        else{
            return
        }
    }
    
    public func startMotionData() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = timeIntervalUpdate
            motionManager.startAccelerometerUpdates()
        }
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = timeIntervalUpdate
            motionManager.startGyroUpdates()
        }
        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = timeIntervalUpdate
            motionManager.startMagnetometerUpdates()
        }
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = timeIntervalUpdate
            motionManager.startDeviceMotionUpdates()
        }
        self.motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (motionActivity) in
            var status = MotionActivity.Unkown
            var confidence = "Low"
            if let activity = motionActivity{
                if activity.unknown{
                    status = MotionActivity.Unkown
                }else if activity.walking{
                    status = MotionActivity.Walking
                }else if activity.running{
                    status = MotionActivity.Running
                }else if activity.cycling{
                    status = MotionActivity.Cycling
                }else if activity.automotive{
                    status = MotionActivity.Automotive
                }else if activity.stationary{
                    status = MotionActivity.Stationary
                }
                switch activity.confidence{
                case .high:
                    confidence = "High"
                case .medium:
                    confidence = "Medium"
                case .low:
                    confidence = "Low"
                }
                self.activity = status
                self.confidence = confidence
            }
        }
    }
    
    public func stopMotionData() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        motionManager.stopMagnetometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        self.motionActivityManager.stopActivityUpdates()
    }
    
    private func startPedometerData(){
        if CMPedometer.isStepCountingAvailable() && CMPedometer.isPaceAvailable(){
            self.pedometer.startUpdates(from: Date.init(), withHandler: { data, error in
                if (error != nil){
                    print(error.debugDescription)
                }
                if let tempData = data{
                    self.pedometerData = tempData
                }
            })
        }
    }
    
    private func stopPedometerData(){
        if CMPedometer.isStepCountingAvailable(){
            self.pedometer.stopUpdates()
        }
    }
    
    private func startAltitudeData(){
        if CMAltimeter.isRelativeAltitudeAvailable(){
            self.altitudeSensor.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: {
                data, error in
                if error != nil{
                    return
                }
                if let dataTemp = data{
                    self.altitudeData = dataTemp
                }
            })
        }
        else{
            let infoStr = "Altitude sensor is not available."
            print(infoStr)
        }
    }
    
    private func stopAltitudeData(){
        if CMAltimeter.isRelativeAltitudeAvailable(){
            CMAltimeter.init().stopRelativeAltitudeUpdates()
        }
    }
    
    // start collect proximity staus using NotificationCenter
    private func startProximityStatus(){
        let curDevice = UIDevice.current
        let isOpend = curDevice.isProximityMonitoringEnabled
        if !isOpend{
            curDevice.isProximityMonitoringEnabled = true
        }
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(self.proximityStateDidChange), name: NSNotification.Name.UIDeviceProximityStateDidChange, object: nil)

    }
    
    // stop collect proximity status
    private func stopProximityStatus(){
        let curDevice = UIDevice.current
        let isOpend = curDevice.isProximityMonitoringEnabled
        if isOpend{
            curDevice.isProximityMonitoringEnabled = false
        }
    }
    
    public func fillRealtimeData(sensorData : Data) {
        //get the motion sensor data
        /*if let data = self.motionManager.accelerometerData{
            sensorData.accelerometerData = data.acceleration
        }
        if let data = self.motionManager.gyroData{
            sensorData.gyroscopeData = data.rotationRate
        }*/
        
        if let motionData = motionManager.deviceMotion{
            sensorData.accelerometerData = motionData.userAcceleration
            sensorData.gyroscopeData = motionData.rotationRate
        }
        if let data = self.motionManager.magnetometerData{
            sensorData.magnetometerData = data.magneticField
        }
        
        sensorData.location = locationMonitor.getLocation()
        /*
        sensorData.pedometerData = self.pedometerData
        sensorData.altitudeData = self.altitudeData
        sensorData.activity = self.activity
        sensorData.confidence = self.confidence
        sensorData.proximityStatus = self.proximityStatus
        
        //bluetooth data
        sensorData.bleState = bluetoothMonitor.bleState
        sensorData.bleDevicesData = bluetoothMonitor.bleDevicesData

        
        let network = networkMonitor.getWifiInfo()
        sensorData.wifiSSID = network.ssid
        sensorData.wifiMacAddress = network.mac
 */
 
    }
    /*
    public func setShakeStatus(status : String, sensorData : Data) {
        sensorData.shakeStatus = status
    }
    
    private func getShakeTimes(sensordata : Data) -> Int {
        return sensordata.shakeTimes
    }
    
    public func setShakeTimes(time : Int, sensorData : Data) {
        sensorData.shakeTimes = getShakeTimes(sensordata: sensorData) + time
    }
     */
    
    // listen the state change of proximity sensor.
    @objc func proximityStateDidChange(){
        let curDevice = UIDevice.current
        if curDevice.proximityState{
            self.proximityStatus = "Closing."
        }
        else{
            self.proximityStatus = "Leaving."
        }
    }
    
}
