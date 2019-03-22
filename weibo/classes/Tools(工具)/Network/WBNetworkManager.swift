//  WBNetworkManager.swift
//  weibo
//
//  Created by 麒麟 on 22/03/2019.
//  Copyright © 2019 Learn. All rights reserved.
//

import UIKit
import AFNetworking //导入就Pods目录里面框架文件夹的名字

//swift中的枚举支持任意数据类型
enum WBHTTPMethod {
    case GET
    case POST
}

//网络管理工具
class WBNetworkManager: AFHTTPSessionManager {
    
    static let shared = WBNetworkManager() //这样一个单例就写完了
    
    ///使用一个函数封装 AFN 的 GET / POST 请求
    /// - parameter method:     GET/POS
    /// - parameter url:        url
    /// - parameter params:     参数字典
    /// - parameter completion: 完成回调[json(这个json有可能是字典/数组), 是否成功]
    func request(method: WBHTTPMethod = .GET, url: String, params: [String: Any], completion: @escaping (_ json:Any?, _ isSucess:Bool)->()) {
        
        //定义数据请求成功的闭包successCall回调
        let successCall = { (task: URLSessionDataTask, jsonData: Any?) ->() in
            completion(jsonData, true) //调用闭包实现将数据回传到UI界面
        }
         //定义数据请求失败的闭包failureCall回调
        let failureCall = { (task: URLSessionDataTask?, error: Error) ->() in
            print("网络请求错误: \(error)")
            completion(nil, false)
        }
        
        if method == .GET{
            get(url, parameters: params, progress: nil, success: successCall, failure: failureCall)
        } else {
            post(url, parameters: params, progress: nil, success: successCall, failure: failureCall)
        }
    }
}
