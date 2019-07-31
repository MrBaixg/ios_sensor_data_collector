//
//  BaseModel.swift
//  SensorDataCollector
//
//  Created by baixg on 2019/1/18.
//  Copyright © 2019 baixg. All rights reserved.
//

import Foundation
import UIKit
import HandyJSON
class BaseModel: HandyJSON {
    //    var date: Date?
    //    var decimal: NSDecimalNumber?
    //    var url: URL?
    //    var data: Data?
    //    var color: UIColor?
    
    required init() {}
    
    func mapping(mapper: HelpingMapper) {   //自定义解析规则，日期数字颜色，如果要指定解析格式，子类实现重写此方法即可
        //        mapper <<<
        //            date <-- CustomDateFormatTransform(formatString: "yyyy-MM-dd")
        //
        //        mapper <<<
        //            decimal <-- NSDecimalNumberTransform()
        //
        //        mapper <<<
        //            url <-- URLTransform(shouldEncodeURLString: false)
        //
        //        mapper <<<
        //            data <-- DataTransform()
        //
        //        mapper <<<
        //            color <-- HexColorTransform()
    }
}
