//
//  Utils.swift
//  SensorDataCollector
//
//  Created by baixg on 2019/1/15.
//  Copyright © 2019 baixg. All rights reserved.
//

import UIKit
import AdSupport
import SAMKeychain

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
    
    class public func dataConvertDouble(date: Date) -> Double {
        let result = date.timeIntervalSince1970
        return Double(result)
    }
    
    class public func getIDFA() -> String {
        var idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        idfa = getUUID()
        return idfa
    }
    
    class func getUUID() -> String {
        let service = Bundle.main.object(forInfoDictionaryKey: String(kCFBundleNameKey)) as? String ?? "" // app名称
        let account = Bundle.main.object(forInfoDictionaryKey: String(kCFBundleIdentifierKey)) as? String ?? "" // bundleID
        var optionUUID = SAMKeychain.password(forService: service, account: account) ?? ""
        if optionUUID.count > 0 {
            print("是否第一次安装：false，app唯一标识：\(optionUUID)")
            return optionUUID
        } else {
            optionUUID = UIDevice.current.identifierForVendor?.uuidString ?? ""
            let query = SAMKeychainQuery()
            query.service = service
            query.account = account
            query.password = optionUUID
            query.synchronizationMode = .no
            do {
                try query.save()
                print("------ save uuid to keychain succeed!!! ------")
            } catch {
                print("------ save uuid to keychain failed!!! ------")
            }
            print("是否第一次安装：true，app唯一标识：\(optionUUID)")
            return optionUUID
        }
    }
}
