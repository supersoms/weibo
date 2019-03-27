import UIKit

///首页微博列表用户模型
class WBUser: NSObject {
    
    @objc var id: Int64 = 0                 //用户id,基本数据类型不能为可选，必须赋默认值
    @objc var screen_name: String?          //用户昵称
    @objc var profile_image_url: String?    //用户头像地址（中图），50×50像素
    @objc var verified_type: Int = 0        //认证类型 -1:没有认证，0:认证用户，2,3,5:企业认证，220:达人
    @objc var mbrank: Int = 0               //会员等级
    
    //为了方便调试输出当前模型的信息，所以重写以下方法
    override var description: String{
        return yy_modelDescription()
    }
}
