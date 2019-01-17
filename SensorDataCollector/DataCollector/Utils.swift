//
//  Utils.swift
//  SensorDataCollector
//
//  Created by baixg on 2019/1/15.
//  Copyright © 2019 baixg. All rights reserved.
//

import UIKit
import AdSupport

class Utils: NSObject {
    override init() {
        
    }
    
    class public func dateConvertString(date:Date, dateFormat:String="yyyy-MM-dd HH:mm:ss") -> String {
        let timeZone = TimeZone.init(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: date)
        return date.components(separatedBy: " ").first!
    }
    
    class public func getIDFA() -> String {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        return idfa
    }

}
