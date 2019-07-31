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

import SQLite
import Alamofire

enum MotionActivity : String{
    case Stationary = "Stationary"
    case Walking = "Walking"
    case Cycling = "Cycling"
    case Running = "Running"
    case Automotive = "Automotive"
    case Unkown = "Unkown"
}

enum Database : String{
    case Location = "location"
    case Sensor = "sensor"
}

struct BLEDeviceData{
    var name : String
    var uuid : String
    var state : String
    var rssi : Int
}

class LocationInfo : BaseModel {
    var time: Double?
    var id: String?
    var longitude: Double?
    var latitude: Double?
    var altitude: Double?
    var speed: Double?
    var course: Double?
    var accuracy_horizontal: Double?
    var accuracy_vertical: Double?
    var time_gps: Double?
}

class SensorInfo : BaseModel {
    var time: Double?
    var id: String?
    var accelerometerX: Double?
    var accelerometerY: Double?
    var accelerometerZ: Double?
    var gyroscopeDataX: Double?
    var gyroscopeDataY: Double?
    var gyroscopeDataZ: Double?
    var magnetometerX: Double?
    var magnetometerY: Double?
    var magnetometerZ: Double?
}
class TotalInfo : BaseModel {
    var location: [LocationInfo]? = []
    var sensor: [SensorInfo]? = []
}

class Feedback : BaseModel {
    var status : String?
    var message : String?
}
 /*
struct LocationInfo : Codable {
    var time: Double?
    var id: String?
    var longitude: Double?
    var latitude: Double?
    var altitude: Double?
    var speed: Double?
    var course: Double?
    var accuracy_horizontal: Double?
    var accuracy_vertical: Double?
    var time_gps: Double?
}

struct SensorInfo : Codable {
    var time: Double?
    var id: String?
    var accelerometerX: Double?
    var accelerometerY: Double?
    var accelerometerZ: Double?
    var gyroscopeDataX: Double?
    var gyroscopeDataY: Double?
    var gyroscopeDataZ: Double?
    var magnetometerX: Double?
    var magnetometerY: Double?
    var magnetometerZ: Double?
}
struct TotalInfo : Codable {
    var location: [LocationInfo]? = []
    var sensor: [SensorInfo]? = []
}*/


class Data {

    init() {
        idfa = ""
        location = CLLocation.init()
        accelerometerData = CMAcceleration.init()
        gyroscopeData = CMRotationRate.init()
        magnetometerData = CMMagneticField.init()
        /*
        pedometerData = CMPedometerData.init()
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
 */
        locationDataList = []
        sensorDataList = []
        locationNameList = []
        sensorNameList = []
    }
    
    init(another : Data) {
        self.idfa = another.idfa
        self.location = another.location
        self.accelerometerData = another.accelerometerData
        self.gyroscopeData = another.gyroscopeData
        self.magnetometerData = another.magnetometerData
        /*
        self.pedometerData = another.pedometerData.copy() as! CMPedometerData
        self.altitudeData = another.altitudeData?.copy() as? CMAltitudeData

        self.shakeStatus = another.shakeStatus
        self.shakeTimes = another.shakeTimes
        self.activity = another.activity
        self.confidence = another.confidence
        self.proximityStatus = another.proximityStatus
        self.wifiSSID = another.wifiSSID
        self.wifiMacAddress = another.wifiMacAddress
        self.bleState = another.bleState
        self.bleDevicesData = another.bleDevicesData
 */
        self.locationDataList = another.locationDataList
        self.sensorDataList = another.sensorDataList
        self.locationNameList = another.locationNameList
        self.sensorNameList = another.sensorNameList
    }
    
    var idfa : String
    var location : CLLocation
    var accelerometerData : CMAcceleration
    var gyroscopeData : CMRotationRate
    var magnetometerData : CMMagneticField
    /*
    var pedometerData : CMPedometerData
    var altitudeData : CMAltitudeData?
    var shakeStatus : String
    var shakeTimes : Int
    var activity : MotionActivity
    var confidence : String
    var proximityStatus : String
    var wifiSSID : String
    var wifiMacAddress : String
    var bleState : String
    var bleDevicesData : [BLEDeviceData]
     */
    
    var locationNameList : [Int64]
    var sensorNameList : [Int64]
    var sensorDataList : [Int64] // 存储正在处理的number
    var locationDataList : [Int64]

    
    // 获取doc路径
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    // 如果不存在的话，创建一个名为db.sqlite3的数据库，并且连接数据库
    
    let number = Expression<Int64>("Number")
    let time = Expression<Double>("time")
    let id = Expression<String>("id")
    
    
    //Location Data
    let longitude = Expression<Double?>("longitude")
    let latitude = Expression<Double?>("latitude")
    let altitude = Expression<Double?>("altitude")
    let time_gps = Expression<Double?>("time_gps")
    let speed = Expression<Double?>("speed")
    let course = Expression<Double?>("course")
    let accuracy_horizontal = Expression<Double?>("accuracy_horizontal")
    let accuracy_vertical = Expression<Double?>("accuracy_vertical")
    
    //Motion Data
    let accelerometerX = Expression<Double?>("accelerometerX")
    let accelerometerY = Expression<Double?>("accelerometerY")
    let accelerometerZ = Expression<Double?>("accelerometerZ")
    let gyroscopeDataX = Expression<Double?>("gyroscopeDataX")
    let gyroscopeDataY = Expression<Double?>("gyroscopeDataY")
    let gyroscopeDataZ = Expression<Double?>("gyroscopeDataZ")
    let magnetometerX = Expression<Double?>("magnetometerX")
    let magnetometerY = Expression<Double?>("magnetometerY")
    let magnetometerZ = Expression<Double?>("magnetometerZ")
    
    public func storeLocationLocal(timestamp : Double) {
        let db = try? Connection("\(path)/db.sqlite3")
        let location = Table("location")

        do {
        try db!.run(location.create(ifNotExists: true) { t in     // CREATE TABLE "users" (
            t.column(number, primaryKey: .autoincrement)
            t.column(time)
            t.column(id) //     "id" INTEGER PRIMARY KEY NOT NULL,
            t.column(longitude)  //     "email" TEXT UNIQUE NOT NULL,
            t.column(latitude)                 //     "name" TEXT
            t.column(altitude)
            t.column(time_gps)
            t.column(speed)
            t.column(course)
            t.column(accuracy_horizontal)
            t.column(accuracy_vertical)
        })
        } catch {
            print("location creat table failed: \(error)")
        }
        do {
            let rowid = try db!.run(location.insert(time <- timestamp,
                                                    id <- self.idfa,
                                                    longitude <- self.location.coordinate.longitude,
                                                    latitude <- self.location.coordinate.latitude,
                                                    altitude <- self.location.altitude,
                                                    time_gps <- Utils.dataConvertDouble(date: self.location.timestamp),
                                                    speed <- Double(self.location.speed),
                                                    course <- Double(self.location.course),
                                                    accuracy_horizontal <- Double(self.location.horizontalAccuracy),
                                                    accuracy_vertical <- Double(self.location.verticalAccuracy)))
            print("location inserted id: \(rowid)")
        } catch {
            print("location insertion failed: \(error)")
        }
    }
    
    public func storeSensorLocal(timestamp : Double){
        let db = try? Connection("\(path)/db.sqlite3")
        let sensor = Table("sensor")
        
        do {
            try db!.run(sensor.create(ifNotExists: true) { t in     // CREATE TABLE "users" (
                t.column(number, primaryKey: .autoincrement)
                t.column(time)
                t.column(id) //     "id" INTEGER PRIMARY KEY NOT NULL,
                t.column(accelerometerX)
                t.column(accelerometerY)
                t.column(accelerometerZ)
                t.column(gyroscopeDataX)
                t.column(gyroscopeDataY)
                t.column(gyroscopeDataZ)
                t.column(magnetometerX)
                t.column(magnetometerY)
                t.column(magnetometerZ)
            })
        } catch {
            print("sensor creat table failed: \(error)")
        }
        do {
            let rowid = try db!.run(sensor.insert(time <- timestamp,
                                                  id <- self.idfa,
                                                  accelerometerX <- self.accelerometerData.x,
                                                  accelerometerY <- self.accelerometerData.y,
                                                  accelerometerZ <- self.accelerometerData.z,
                                                  gyroscopeDataX <- self.gyroscopeData.x,
                                                  gyroscopeDataY <- self.gyroscopeData.y,
                                                  gyroscopeDataZ <- self.gyroscopeData.z,
                                                  magnetometerX <- self.magnetometerData.x,
                                                  magnetometerY <- self.magnetometerData.y,
                                                  magnetometerZ <- self.magnetometerData.z))
            print("sensor inserted id: \(rowid)")
        } catch {
            print("insertion failed: \(error)")
        }
    }
    
    public func upload(totalInfo : TotalInfo, isDatabase : Bool, timestamp: Double = 0.0){
        let jsonInfo = JsonUtil.modelToJson(totalInfo)
        print(jsonInfo)
//        print(jsonInfo)
//        NetworkManager.shared.request(requestType: .POST, urlString: "http://120.78.167.211:10086/ios/upload", parameters: jsonInfo as [String : AnyObject], completion: { (json) in
//            print(json as! Any)
//            status = String(describing: json!)
//        })
            Alamofire.request("http://120.78.167.211:10086/ios/upload", method: .post, parameters: jsonInfo, encoding: JSONEncoding.default).responseString { response in
                let feedback : Feedback = JsonUtil.jsonToModel(response.result.value ?? JsonUtil.modelToJsonString(Feedback()),Feedback.self) as! Feedback
                if let status = feedback.status{
                    if status == "success" {
                        if isDatabase{
                            print("Database upload successfully!")
                            do {
                                let db = try? Connection("\(self.path)/db.sqlite3")
                                let sensor = Table("sensor")
                                let location = Table("location")
                                let target1 = location.filter(self.locationDataList.contains(self.number))
                                try db?.run(target1.delete())
                                self.locationDataList = []
                                let target2 = sensor.filter(self.sensorDataList.contains(self.number))
                                try db?.run(target2.delete())
                                self.sensorDataList = []
                            } catch {
                                print(error)
                            }
                        }
                        else {
                            print("Real-time data upload successfully!")
                        }
                    }
                    else {
                        if !isDatabase{
                            self.storeLocationLocal(timestamp: timestamp)
                            self.storeSensorLocal(timestamp: timestamp)
                            print("Real-time data store locally successfully!")
                        }
                        else {
                            self.locationDataList = []
                            self.sensorDataList = []
                        }
                    }
                }
                else {
                    if !isDatabase{
                        self.storeLocationLocal(timestamp: timestamp)
                        self.storeSensorLocal(timestamp: timestamp)
                        print("Real-time data store locally successfully!")
                    }
                }
            }
        }
    
    private func gatherInfo(timestamp : Double) -> TotalInfo{
        let totalInfo: TotalInfo = TotalInfo()
        let comp1 : LocationInfo = LocationInfo()
        
        comp1.time = timestamp
        comp1.id = self.idfa
        comp1.longitude = self.location.coordinate.longitude
        comp1.latitude = self.location.coordinate.latitude
        comp1.altitude = self.location.altitude
        comp1.time_gps = Utils.dataConvertDouble(date: self.location.timestamp)
        comp1.speed = Double(self.location.speed)
        comp1.course = Double(self.location.course)
        comp1.accuracy_horizontal = Double(self.location.horizontalAccuracy)
        comp1.accuracy_vertical = Double(self.location.verticalAccuracy)
        
        let comp2 : SensorInfo = SensorInfo()
        comp2.time = timestamp
        comp2.id = self.idfa
        comp2.accelerometerX = self.accelerometerData.x
        comp2.accelerometerY = self.accelerometerData.y
        comp2.accelerometerZ = self.accelerometerData.z
        comp2.gyroscopeDataX = self.gyroscopeData.x
        comp2.gyroscopeDataY = self.gyroscopeData.y
        comp2.gyroscopeDataZ = self.gyroscopeData.z
        comp2.magnetometerX = self.magnetometerData.x
        comp2.magnetometerY = self.magnetometerData.y
        comp2.magnetometerZ = self.magnetometerData.z
        
        
        totalInfo.location?.append(comp1)
        totalInfo.sensor?.append(comp2)
        
        return totalInfo
    }
    
    private func gatherInfo(totalInfo : TotalInfo, database : Database, num : Int64) -> (Bool, TotalInfo){
        let db = try? Connection("\(path)/db.sqlite3")
        let sensor = Table("sensor")
        let location = Table("location")
        if database == Database.Location {
            let target = location.filter(number == num)
            let comp = LocationInfo()
            do{
                
                let result = try db?.prepare(target)
                if let res = result {
                    for re in res{
                        comp.time = try re.get(time)
                        comp.id = try re.get(id)
                        comp.longitude = try re.get(longitude)
                        comp.latitude = try re.get(latitude)
                        comp.speed = try re.get(speed)
                        comp.accuracy_horizontal = try re.get(accuracy_horizontal)
                        comp.accuracy_vertical = try re.get(accuracy_vertical)
                        comp.course = try re.get(course)
                        comp.altitude = try re.get(altitude)
                        comp.time_gps = try re.get(time_gps)
                    }
                    totalInfo.location?.append(comp)
                }
            }catch{
                print(error)
                return (false, totalInfo)
            }
        }
        else if database == Database.Sensor {
            let target = sensor.filter(number == num)
            let comp = SensorInfo()
            do{
                
                let result = try db?.prepare(target)
                if let res = result {
                    for re in res{
                        comp.time = try re.get(time)
                        comp.id = try re.get(id)
                        comp.accelerometerX = try re.get(accelerometerX)
                        comp.accelerometerY = try re.get(accelerometerY)
                        comp.accelerometerZ = try re.get(accelerometerZ)
                        comp.gyroscopeDataX = try re.get(gyroscopeDataX)
                        comp.gyroscopeDataY = try re.get(gyroscopeDataY)
                        comp.gyroscopeDataZ = try re.get(gyroscopeDataZ)
                        comp.magnetometerX = try re.get(magnetometerX)
                        comp.magnetometerY = try re.get(magnetometerY)
                        comp.magnetometerZ = try re.get(magnetometerZ)
                    }
                    totalInfo.sensor?.append(comp)
                }
            }catch{
                print(error)
                return (false, totalInfo)
            }
        }
        return (true, totalInfo)
    }
    
    public func updateDataBaseStatus() {
        let db = try? Connection("\(path)/db.sqlite3")
        let sensor = Table("sensor")
        let location = Table("location")
        locationNameList = []
        sensorNameList = []
        do {
            try db!.run(location.create(ifNotExists: true) { t in     // CREATE TABLE "users" (
                t.column(number, primaryKey: .autoincrement)
                t.column(time)
                t.column(id) //     "id" INTEGER PRIMARY KEY NOT NULL,
                t.column(longitude)  //     "email" TEXT UNIQUE NOT NULL,
                t.column(latitude)                 //     "name" TEXT
                t.column(altitude)
                t.column(time_gps)
                t.column(speed)
                t.column(course)
                t.column(accuracy_horizontal)
                t.column(accuracy_vertical)
            })
        } catch {
            print("location creat table failed: \(error)")
        }
        do {
            try db!.run(sensor.create(ifNotExists: true) { t in     // CREATE TABLE "users" (
                t.column(number, primaryKey: .autoincrement)
                t.column(time)
                t.column(id) //     "id" INTEGER PRIMARY KEY NOT NULL,
                t.column(accelerometerX)
                t.column(accelerometerY)
                t.column(accelerometerZ)
                t.column(gyroscopeDataX)
                t.column(gyroscopeDataY)
                t.column(gyroscopeDataZ)
                t.column(magnetometerX)
                t.column(magnetometerY)
                t.column(magnetometerZ)
            })
        } catch {
            print("sensor creat table failed: \(error)")
        }
        do{
            let target1 = location.select(number)
            for lo in try (db?.prepare(target1))!{
                locationNameList.append(lo[number])
            }
            let target2 = sensor.select(number)
            for se in try (db?.prepare(target2))!{
                sensorNameList.append(se[number])
            }
        } catch {
            print(error)
        }
    }
    
    public func uploadDataBase() {
        var result : Bool = false
        var totalInfo = TotalInfo()
        updateDataBaseStatus()
        print(locationNameList)
        print(sensorNameList)
        if locationNameList.count != 0 {
            for order in locationNameList {
                (result, totalInfo) = gatherInfo(totalInfo: totalInfo, database: .Location, num: Int64(order))
                if result == false {
                    break
                }
                locationDataList.append(Int64(order))
            }
        }
        if sensorNameList.count != 0 {
            for order in sensorNameList {
                (result, totalInfo) = gatherInfo(totalInfo: totalInfo, database: .Sensor, num: Int64(order))
                if result == false {
                    break
                }
                sensorDataList.append(Int64(order))
            }
        }
        if result {
            upload(totalInfo: totalInfo, isDatabase: true)
        }
    }
    
    public func uploadRealTimeData(timestamp: Double) {
        let totalInfo = gatherInfo(timestamp: timestamp)
        upload(totalInfo: totalInfo, isDatabase: false, timestamp: timestamp)
    }
    /*
    public func storeOnline(timestamp : Double) {
        var totalInfo: TotalInfo = TotalInfo()
        var comp1 : LocationInfo = LocationInfo()
        comp1.time = timestamp
        comp1.id = self.idfa
        comp1.longitude = self.location.coordinate.longitude
        comp1.latitude = self.location.coordinate.latitude
        comp1.altitude = self.location.altitude
        comp1.time_gps = Utils.dataConvertDouble(date: self.location.timestamp)
        comp1.speed = Double(self.location.speed)
        comp1.course = Double(self.location.course)
        comp1.accuracy_horizontal = Double(self.location.horizontalAccuracy)
        comp1.accuracy_vertical = Double(self.location.verticalAccuracy)
        
        var comp2 : SensorInfo = SensorInfo()
        comp2.time = timestamp
        comp2.id = self.idfa
        comp2.accelerometerX = self.accelerometerData.x
        comp2.accelerometerY = self.accelerometerData.y
        comp2.accelerometerZ = self.accelerometerData.z
        comp2.gyroscopeDataX = self.gyroscopeData.x
        comp2.gyroscopeDataY = self.gyroscopeData.y
        comp2.gyroscopeDataZ = self.gyroscopeData.z
        comp2.magnetometerX = self.magnetometerData.x
        comp2.magnetometerY = self.magnetometerData.y
        comp2.magnetometerZ = self.magnetometerData.z
        totalInfo.location?.append(comp1)
        totalInfo.sensor?.append(comp2)
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(totalInfo)
        let json = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
        print(json! as Any)
    }*/
    
    
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
        /*
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
        }*/
        
        
        
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
//        print(resultData)
        //        data.storeLocationLocal(timestamp: Double(timestamp))
        //        data.storeSensorLocal(timestamp: Double(timestamp))
        data.uploadRealTimeData(timestamp: Double(timestamp))
        data.uploadDataBase()
        return (resultName, resultData)
    }
    
    

}
