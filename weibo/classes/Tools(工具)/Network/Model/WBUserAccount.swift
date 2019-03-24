//
//  WBUserAccount.swift
//  weibo
//
//  Created by 麒麟 on 24/03/2019.
//  Copyright © 2019 Learn. All rights reserved.
//

import UIKit

//用户账户信息
class WBUserAccount: NSObject {
    
    //以下的属性必须跟接口返回的属性名一致，不然无法映射
    //访问令牌
    @objc var access_token: String? //= "2.00qXUXgH0UvlTRc360822b2dKNqxFB"
    
    //用户id
    @objc var uid: String?
    
    //过期时间，单位秒，开发者5年(每次登陆之后，都是5年)，使用者3天(会从第1次登陆开始递减)
    @objc var expires_in: TimeInterval = 0 {
        didSet {
            //通过didSet给expiresDate赋值，格式化的数据为：expiresDate = 2024-03-22 05:51:03 +0000;
            expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    
    //是否是真名
    @objc var isRealName: String?
    
    //过期日期
    @objc var expiresDate: Date?
    
    override var description: String{
        return yy_modelDescription()
    }
    
    //将用户信息用json保存
    func saveAccount(){
        //1: 模型(类对象)转为字典,此时的self就是WBUserAccount
        var dict = (self.yy_modelToJSONObject() as? [String: Any]) ?? [:]
        //删除 expires_in key
        dict.removeValue(forKey: "expires_in")
        
        //2: 字典序列化
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
              let filePath = ("useraccount.json" as NSString).cz_appendDocumentDir() else {
            return
        }
        
        //3: 写入磁盘,放在文档目录下
        (data as NSData).write(toFile: filePath, atomically: true)
        
        print("用户账户信息保存成功! 文件保存在: \(filePath)")
    }
}
