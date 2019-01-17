//
//  DataProcessing.swift
//  SensorDataCollector
//
//  Created by baixg on 2019/1/15.
//  Copyright © 2019 baixg. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation

enum MotionActivity : String{
    case Stationary = "Stationary"
    case Walking = "Walking"
    case Cycling = "Cycling"
    case Running = "Running"
    case Automotive = "Automotive"
    case Unkown = "Unkown"
}

struct BLEDeviceData{
    var name : String
    var uuid : String
    var state : String
    var rssi : Int
}

class Data {

    init() {
        idfa = ""
        accelerometerData = CMAcceleration.init()
        gyroscopeData = CMRotationRate.init()
        magnetometerData = CMMagneticField.init()
        pedometerData = CMPedometerData.init()
        location = CLLocation.init()
        altitudeData = nil
        shakeStatus  = "No Shake"
        shakeTimes = 0
        activity = MotionActivity.Unkown
        confidence = "Low"
        proximityStatus  = "Leaving"

        wifiSSID = ""
        wifiMacAddress = ""
        bleState = "Power Off"
        bleDevicesData = []
    }
    
    init(another : Data) {
        self.idfa = another.idfa
        self.accelerometerData = another.accelerometerData
        self.gyroscopeData = another.gyroscopeData
        self.magnetometerData = another.magnetometerData
        self.pedometerData = another.pedometerData.copy() as! CMPedometerData
        self.altitudeData = another.altitudeData?.copy() as? CMAltitudeData
        self.location = another.location
        self.shakeStatus = another.shakeStatus
        self.shakeTimes = another.shakeTimes
        self.activity = another.activity
        self.confidence = another.confidence
        self.proximityStatus = another.proximityStatus
        self.wifiSSID = another.wifiSSID
        self.wifiMacAddress = another.wifiMacAddress
        self.bleState = another.bleState
        self.bleDevicesData = another.bleDevicesData
    }
    
    var idfa : String
    var accelerometerData : CMAcceleration
    var gyroscopeData : CMRotationRate
    var magnetometerData : CMMagneticField
    var pedometerData : CMPedometerData
    var altitudeData : CMAltitudeData?
    var location : CLLocation
    var shakeStatus : String
    var shakeTimes : Int
    var activity : MotionActivity
    var confidence : String
    var proximityStatus : String
    var wifiSSID : String
    var wifiMacAddress : String
    var bleState : String
    var bleDevicesData : [BLEDeviceData]
    
    
    public func printData() -> ([String], [String]){
        var resultSensorList : [String] = []
        var resultSensorData : [String] = []
        var sensorValue = "No Value"
        
        
        
        //AccelerometerX
        resultSensorList.append("AccelerometerX")
        sensorValue = String(self.accelerometerData.x)
        resultSensorData.append(sensorValue)
        //AccelerometerY
        resultSensorList.append("AccelerometerY")
        sensorValue = String(self.accelerometerData.y)
        resultSensorData.append(sensorValue)
        //AccelerometerZ
        resultSensorList.append("AccelerometerZ")
        sensorValue = String(self.accelerometerData.z)
        resultSensorData.append(sensorValue)
        //GyroscopeX
        resultSensorList.append("GyroscopeX")
        sensorValue = String(self.gyroscopeData.x)
        resultSensorData.append(sensorValue)
        //GyroscopeY
        resultSensorList.append("GyroscopeY")
        sensorValue = String(self.gyroscopeData.y)
        resultSensorData.append(sensorValue)
        //GyroscopeZ
        resultSensorList.append("GyroscopeZ")
        sensorValue = String(self.gyroscopeData.z)
        resultSensorData.append(sensorValue)
        //MegnetometerX
        resultSensorList.append("MagnetometerX")
        sensorValue = String(self.magnetometerData.x)
        resultSensorData.append(sensorValue)
        //MegnetometerY
        resultSensorList.append("MagnetometerY")
        sensorValue = String(self.magnetometerData.y)
        resultSensorData.append(sensorValue)
        //MegnetometerZ
        resultSensorList.append("MagnetometerZ")
        sensorValue = String(self.magnetometerData.z)
        resultSensorData.append(sensorValue)
        //Location
        resultSensorList.append("Location")
        sensorValue = "(" + String(self.location.coordinate.longitude) + "," + String(self.location.coordinate.latitude) + ")"
        resultSensorData.append(sensorValue)
        //Speed
        resultSensorList.append("Speed")
        sensorValue = String(self.location.speed)
        resultSensorData.append(sensorValue)
        //Altitude
        resultSensorList.append("altitude")
        sensorValue = String(self.location.altitude)
        resultSensorData.append(sensorValue)
        //Course
        resultSensorList.append("course")
        sensorValue = String(self.location.course)
        resultSensorData.append(sensorValue)
        //Accuracy
        resultSensorList.append("Horizonal accuracy")
        sensorValue = String(self.location.horizontalAccuracy)
        resultSensorData.append(sensorValue)
        resultSensorList.append("Horizonal accuracy")
        sensorValue = String(self.location.verticalAccuracy)
        resultSensorData.append(sensorValue)
        //Timestamp
        resultSensorList.append("Timestamp for GPS")
        sensorValue = Utils.dateConvertString(date: self.location.timestamp, dateFormat: "HH:mm:ss")
        resultSensorData.append(sensorValue)
        //Steps
        resultSensorList.append("Steps")
        sensorValue = String(self.pedometerData.numberOfSteps.intValue)
        resultSensorData.append(sensorValue)
        //Distance
        resultSensorList.append("Distance")
        if let distance = self.pedometerData.distance{
            sensorValue = distance.stringValue
        }else{
            sensorValue = "No Value"
        }
        resultSensorData.append(sensorValue)
        //CurrentPace
        resultSensorList.append("CurrentPace")
        if let currentPace = self.pedometerData.currentPace{
            sensorValue = currentPace.stringValue
        }else{
            sensorValue = "No Value"
        }
        resultSensorData.append(sensorValue)
        //Motion activity
        resultSensorList.append("Activity")
        resultSensorData.append(self.activity.rawValue)
        resultSensorList.append("Confidence")
        resultSensorData.append(self.confidence)
        
        //ShakeStatus
        resultSensorList.append("ShakeStatus")
        sensorValue = self.shakeStatus
        resultSensorData.append(sensorValue)
        //ShakeTimes
        resultSensorList.append("ShakeTimes")
        sensorValue = String(self.shakeTimes)
        resultSensorData.append(sensorValue)
        //ProximityStatus
        resultSensorList.append("ProximityStatus")
        sensorValue = self.proximityStatus
        resultSensorData.append(sensorValue)
        //RelativeAltitude
        resultSensorList.append("RelativeAltitude")
        if let altitudeData = self.altitudeData{
            sensorValue = altitudeData.relativeAltitude.stringValue
        }else{
            sensorValue = "No Value"
        }
        resultSensorData.append(sensorValue)
        //Pressure
        resultSensorList.append("Pressure")
        if let altitudeData = self.altitudeData{
            sensorValue = altitudeData.pressure.stringValue
        }
        resultSensorData.append(sensorValue)
        //WifiSSID
        resultSensorList.append("WifiSSID")
        sensorValue = self.wifiSSID
        resultSensorData.append(sensorValue)
        //WifiStrength
        resultSensorList.append("Wifi Mac")
        sensorValue = String(self.wifiMacAddress)
        resultSensorData.append(sensorValue)
        //BLEStatus
        resultSensorList.append("BLEStatus")
        sensorValue = String(self.bleState)
        resultSensorData.append(sensorValue)
        //BLEDevice data
        bleDevicesData.sort { (first, second) -> Bool in
            if first.uuid < second.uuid{
                return true
            }else{
                return false
            }
        }
        for bleDevice in bleDevicesData{
            resultSensorList.append(bleDevice.uuid)
            resultSensorData.append(String(bleDevice.rssi))
        }
        
        
        
        return (resultSensorList, resultSensorData)
    }
    

}


class DataProcessing {
    static let shared = DataProcessing.init()
    
    init() {
        data = Data.init()
        sensorCollector = SensorCollector.init()
    }
    init(another : DataProcessing) {
        self.data = Data.init(another: another.data)
        self.sensorCollector = SensorCollector.init(another: another.sensorCollector)
    }
    
    var data : Data
    var sensorCollector : SensorCollector
    
    public func updateData() -> ([String], [String]) {
        // clear the string array
        var resultName : [String] = []
        var resultData : [String] = []
        if data.idfa.count < 3 {
            data.idfa = Utils.getIDFA()
        }
        resultName.append("IDFA")
        resultData.append(data.idfa)
        resultName.append("TimeStamp")
        let now = NSDate()
        let timestamp = now.timeIntervalSince1970
        resultData.append(String(timestamp))
        
//        sensorCollector.startCollectSensorData()
        sensorCollector.fillRealtimeData(sensorData: data)
        
        let (sensorName, sensorData) = data.printData()
        
        //sensorCollector.stopCollectSensorData()
        
        resultName.append(contentsOf: sensorName)
        resultData.append(contentsOf: sensorData)
        print(resultData)
        return (resultName, resultData)
    }
    
    

}
