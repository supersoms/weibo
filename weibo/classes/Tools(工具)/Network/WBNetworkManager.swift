//
//  WBNetworkManager.swift
//  weibo
//
//  Created by 麒麟 on 22/03/2019.
//  Copyright © 2019 Learn. All rights reserved.
//

import UIKit
import AFNetworking //导入就Pods目录里面框架文件夹的名字

//网络管理工具
class WBNetworkManager: AFHTTPSessionManager {
    
    static let shared = WBNetworkManager() //这样一个单例就写完了
}
