import Foundation

///单条微博的视图模型
/**
    如果一个类没有任何的父类，如果在开发中debug调试时，需要输出一个模型的具体调试信息，需要
    1: 继承 CustomStringConvertible
    2: 实现 description 计算型属性
*/
class WBStatusViewModel: CustomStringConvertible {
    
    @objc var status: WBStatus              //首页微博列表模型
    @objc var memberIcon: UIImage?          //会员等级图标,存储型属性(用内存换CPU)
    @objc var vipIcon: UIImage?             //认证类型 -1:没有认证，0:认证用户，2,3,5:企业认证，220:达人
    @objc var retweetedStr: String?         //转发文字
    @objc var commentStr: String?           //评论文字
    @objc var likeStr: String?              //赞文字
    @objc var pictureViewSize = CGSize()    //配图视图大小
    
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
        
        //设置底部计数字符串
        retweetedStr = countString(count: model.reposts_count, defaultStr: "转发")
        commentStr = countString(count: model.comments_count, defaultStr: "评论")
        likeStr = countString(count: model.attitudes_count, defaultStr: "赞")
        
        //计算配图视图的大小
        pictureViewSize = calcPictureViewSize(count: status.pic_urls?.count)
        
    }
    
    //此description计算型属性的作用是: 返回 status 的具体描述信息，在debug时，可以看到模型的具体数据，如果不重写debug时查看不了
    var description: String {
        return status.description
    }
    
    /// 计算指定数量的图片对应的配图视图的大小
    ///
    /// - Parameter count: 配图数量
    /// - Returns: 配图视图的大小
    private func calcPictureViewSize(count: Int?) -> CGSize{
        
        if count == 0 && count == nil {
            return CGSize()
        }
        
        //2:计算高度
        //2.1: 根据count知道行数（1~9）
        let row = (count! - 1) / 3 + 1
        //2.2: 根据行数算高度
        var height = WBStatusPictureViewOutterMargin
        height += CGFloat(row) * WBStatusPictureItemWidth
        height += CGFloat(row - 1) * WBStatusPictureViewInnerMargin
        
        return CGSize(width: WBStatutPictureViewWidth, height: height)
    }
    
    /// 给定一个数字，返回对应的结果
    /// - Parameters:
    ///   - count: 数字
    ///   - defaultStr: 默认什
    /// - Returns: 描述结果
    /**
        如果数量 == 0，显示默认标题
        如果数量超过 10000，显示x.xx万
        如果数量 < 10000，显示实际数字
     */
    private func countString(count: Int, defaultStr: String) ->String{
        if count == 0 {
            return defaultStr
        }
        if count < 10000 {
            return count.description
        }
        return String(format: "%.02f 万", Double(count) / 10000)
    }
}
