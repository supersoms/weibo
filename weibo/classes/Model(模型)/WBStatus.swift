import UIKit
import YYModel

//首页微博列表模型，新浪微博接口: statuses/home_timeline，获取当前登录用户及其所关注（授权）用户的最新微博 数据模型
class WBStatus: NSObject {
    ///FIXME - 踩坑：在swift4.0版本时,如果用NSArray.yy_modelArray()将json数据转为模型数组时，模型对象属性必须加上@objc修饰，不然，解析json时无法将数据映射给WBStatus模型对象，那数组就会为空
    //以下所有的属性名称必须与json数据里面的key对应一致，不然无法映射
    @objc var id: Int64 = 0             //基本数据类型要赋值默认值，微博ID
    @objc var text: String?             //微博信息内容
    @objc var user: WBUser?             //微博用户，user是微博列表中的一个对象(object)，在iOS中就是一个map字典
    @objc var reposts_count: Int = 0    //转发数
    @objc var comments_count: Int = 0   //评论数
    @objc var attitudes_count: Int = 0  //赞数
    
    //模型必须重写 description 的计算型属性
    override var description: String {
        return yy_modelDescription()
    }
}
