import UIKit
import YYModel

//首页微博列表模型，新浪微博接口: statuses/home_timeline，获取当前登录用户及其所关注（授权）用户的最新微博 数据模型
class WBStatus: NSObject {
    //FIXME: - 踩坑
    //在swift4.0版本时,如果用NSArray.yy_modelArray()将json数据转为模型数组时，模型对象属性必须加上@objc修饰，不然，解析json时无法将数据映射给WBStatus模型对象，那数组就会为空
    //以下所有的属性名称必须与json数据里面的key对应一致，不然无法映射
    @objc var id: Int64 = 0                 //基本数据类型要赋值默认值，微博ID
    @objc var text: String?                 //微博信息内容
    @objc var created_at: String?           //微博创建时间字符串
    @objc var source: String? {             //微博来源(发布微博使用的客户端)
        didSet{
            source = "来自于 " + (source?.cz_href()?.text ?? "") //重新计算source并且保存，这样做不用开辟新的内存空间
        }
    }
    @objc var user: WBUser?                 //微博用户，user是微博列表中的一个对象(object)，在iOS中就是一个map字典
    @objc var reposts_count: Int = 0        //转发数
    @objc var comments_count: Int = 0       //评论数
    @objc var attitudes_count: Int = 0      //赞数
    @objc var pic_urls: [WBStatusPicture]?  //微博配图视图模型数组
    @objc var retweeted_status: WBStatus?   //被转发的原创微博的数据
    
    //模型必须重写 description 的计算型属性，在debug时，可以查看具体的信息
    override var description: String {
        return yy_modelDescription()
    }
    
    //类函数，告诉第三方框架YY_Model,如果遇到数组类型的属性,数组中存放的对象是什么类? 就是告诉框架要用什么类去映射
    //FIXME: - 踩坑
    /****
     在swift3.0版本前，使用YYModel实现嵌套的字典转模型时，如果返回数据中，包含数组，就需要实现 modelContainerPropertyGenericClass 方法，但不用加@objc可以解析
     在swift4.0版本以上包含4.0版本，如果不加@objc，解析数据失败
    */
    @objc class func modelContainerPropertyGenericClass() -> [String: WBStatusPicture.Type] {
        return ["pic_urls": WBStatusPicture.self]
    }
}
