import UIKit

//微博配图模型,(所有参与字典转模型的都必须继承NSObject)
class WBStatusPicture: NSObject {
    
    //缩略图地址
    @objc var thumbnail_pic: String?
    var myArray = [AnyObject]()
    
    //为了在Debug时，打印出具体的信息，重写计算型属性description
    override var description: String {
        return yy_modelDescription()
    }
}
