//
//  NetworkingTools.swift
//  SensorDataCollector
//
//  Created by baixg on 2019/1/18.
//  Copyright © 2019 baixg. All rights reserved.
//

import Foundation
import Alamofire

enum HTTPRequestType {
    case GET
    case POST
}

class NetworkManager {
    
    //单例
    static let shared : NetworkManager = {
        let tools = NetworkManager()
        tools.requestSerializer = AFJSONRequestSerializer()
        tools.responseSerializer = AFJSONResponseSerializer()
        tools.requestSerializer.setValue("application/json,text/html", forHTTPHeaderField: "Accept")
        tools.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return tools
    }()
    
    /// 封装GET和POST 请求
    ///
    /// - Parameters:
    ///   - requestType: 请求方式
    ///   - urlString: urlString
    ///   - parameters: 字典参数
    ///   - completion: 回调
    func request(requestType: HTTPRequestType, urlString: String, parameters: [String: AnyObject]?, completion: @escaping (AnyObject?) -> ()) {
        
        //成功回调
        let success = { (task: URLSessionDataTask, json: Any)->() in
            completion(json as AnyObject?)
        }
        
        //失败回调
        let failure = { (task: URLSessionDataTask?, error: Error) -> () in
            print("网络请求错误 \(error)")
            completion(nil)
        }
        if requestType == .GET {
            get(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
        } else {
            post(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
    }
}
