import Foundation

// MARK - 专门用来存放定义全局通知
let WBUserShouldLoginNotification = "WBUserShouldLoginNotification"     // 用户需要登录的通知名字
let WBUserLoginSuccessNotification = "WBUserLoginSuccessNotification"   // 用户登录成功的通知名字

// MARK - 定义微博应用程序配置
let WBAppKey = "258293456"                              //申请应用时分配的
let WBAppSecret = "c0a6befc3802bdc449389e4d3821bf7a"    //应用程序加密信息(开发者可修改)
let WBRedirectURI = "http://www.baidu.com"              //重定向回调地址,登录完成之后跳转的地址

// MARK - 计算微博配图视图大小需要用到的常量
let WBStatusPictureViewOutterMargin = CGFloat(12)                                                   //配图视图外侧的间距
let WBStatusPictureViewInnerMargin = CGFloat(3)                                                     //配图视图内部图像视图的间距
let WBStatutPictureViewWidth = UIScreen.cz_screenWidth() - 2 * WBStatusPictureViewOutterMargin      //配图视图的宽度
//每个 Item 默认的宽度
let WBStatusPictureItemWidth = (WBStatutPictureViewWidth - 2 * WBStatusPictureViewInnerMargin) / 3
