import UIKit
import YYModel

//新浪微博接口: statuses/home_timeline，获取当前登录用户及其所关注（授权）用户的最新微博 数据模型
class WBStatus: NSObject {
    ///FIXME - 踩坑：在swift4.0版本时,如果用NSArray.yy_modelArray()将json数据转为模型数组时，模型对象属性必须加上@objc修饰，不然，解析json时无法将数据映射给WBStatus模型对象，那数组就会为空
    @objc var id: Int64 = 0     //基本数据类型要赋值默认值，微博ID
    @objc var text: String?     //微博信息内容
    
    //模型必须重写 description 的计算型属性
    override var description: String {
        return yy_modelDescription()
    }
}
