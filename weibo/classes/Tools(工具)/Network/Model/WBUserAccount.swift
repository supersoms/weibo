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
    
    //访问令牌
    @objc var access_token: String? //= "2.00qXUXgH0UvlTRc360822b2dKNqxFB"
    //用户id
    @objc var uid: String?
    //过期时间，单位秒，开发者5年，使用者3天
    @objc var expires_in: TimeInterval = 0
    
    override var description: String{
        return yy_modelDescription()
    }
}
