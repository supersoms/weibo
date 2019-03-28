import Foundation

///单条微博的视图模型
/**
    如果一个类没有任何的父类，如果在开发中debug调试时，需要输出一个模型的具体调试信息，需要
    1: 继承 CustomStringConvertible
    2: 实现 description 计算型属性
*/

class WBStatusViewModel: CustomStringConvertible {
    
    @objc var status: WBStatus          //首页微博列表模型
    @objc var memberIcon: UIImage?      //会员等级图标,存储型属性(用内存换CPU)
    @objc var vipIcon: UIImage?         //认证类型 -1:没有认证，0:认证用户，2,3,5:企业认证，220:达人
    
    ///构造函数
    ///因为status定义时不是可选的，所以必须在init中初始化
    init(model: WBStatus) {
        self.status = model
        
        //在此直接计算出 会员等级 0-6，tableView滚动的时候不会再次计算，这就是优化
        if (model.user?.mbrank)! > 0 && (model.user?.mbrank)! < 7 {
            let imageName = "common_icon_membership_level\(model.user?.mbrank ?? 1)"
            memberIcon = UIImage(named: imageName)
        }
        //认证图标
        switch model.user?.verified_type ?? -1 {
        case 0:
            vipIcon = UIImage(named: "avatar_vip")
        case 2,3,5:
            vipIcon = UIImage(named: "avatar_enterprise_vip")
        case 220:
            vipIcon = UIImage(named: "avatar_grassroot")
        default:
            break
        }
    }
    
    //此description计算型属性的作用是: 返回 status 的具体描述信息，在debug时，可以看到模型的具体数据，如果不重写debug时查看不了
    var description: String {
        return status.description
    }
}
