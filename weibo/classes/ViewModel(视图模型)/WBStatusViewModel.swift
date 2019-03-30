import Foundation

///单条微博的视图模型,负责相应的逻辑处理
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
    @objc var picUrls: [WBStatusPicture]? { //如果是被转发的微博，原创微博一定没有图
        //前面是返回被转发微博的配图
        //后面返回的是原创微博的配图
        //如果都没有,返回nil
        return status.retweeted_status?.pic_urls ?? status.pic_urls
    }
    
    @objc var retweetedText: String?        //被转发微博的文字
    @objc var rowHeight: CGFloat = 0        //行高
    
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
        
        //计算配图视图的大小（有原创的就计算原创的,有转发的就计算转发的）
        pictureViewSize = calcPictureViewSize(count: picUrls?.count)
        
        //设置被转发微博的文字
        retweetedText = "@" + (status.retweeted_status?.user?.screen_name ?? "") + ":\(status.retweeted_status?.text ?? "")"
        
        updateRowHeight()
    }
    
    //此description计算型属性的作用是: 返回 status 的具体描述信息，在debug时，可以看到模型的具体数据，如果不重写debug时查看不了
    var description: String {
        return status.description
    }
    
    //FIXME: 为什么要根据当前的视图模型内容计算行高,是为在用Instrument工具组中的 Core Animation 刷新频率的性能测试进提高tableView的性能
    //结果: 经刷新频率测试,性能确实有提升,刷新频率都在50-60之间,如果没做行高缓存,没有这么高
    ///根据当前的视图模型内容计算行高
    func updateRowHeight(){
        //原创微博: 顶部分割视图(12)+间距(12)+图像的高度(34)+间距(12)+正文高度(需要计算)+配图视图高度(计算)+间距(12)+底部视图高度(35)
        //原创微博: 顶部分割视图(12)+间距(12)+图像的高度(34)+间距(12)+正文高度(需要计算)+间距(12)+间距(12)+转发文本高度(需要计算)+配图视图高度(计算)+间距(12)+底部视图高度(35)
        
        let margin: CGFloat = 12
        let iconHeight: CGFloat = 34
        let toolbarHeight: CGFloat = 35
        var height:CGFloat = 0
        let viewSize = CGSize(width: UIScreen.cz_screenWidth() - 2 * margin, height: CGFloat(MAXFLOAT))
        let originalFont = UIFont.systemFont(ofSize: 15)
        let retweetedFont = UIFont.systemFont(ofSize: 14)
        
        //1:计算顶部位置
        height = 2 * margin + iconHeight + margin
        
        //2:计算正文的高度
        if let text = status.text {
            //参数1: 预期尺寸,宽度固定,高度尽量大
            //参数2: 选项，换行文本，统一使用 usesLineFragmentOrigin
            //参数3: 指定字体字典
            height += (text as NSString).boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: originalFont], context: nil).height
        }
        
        //3: 判断是否转发微博
        if status.retweeted_status != nil {
            height += 2 * margin
            //3.1 计算转发文本的高度
            if let text = retweetedText {
                height += (text as NSString).boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: retweetedFont], context: nil).height
            }
        }
        
        //4: 配图视图
        height += pictureViewSize.height
        height += margin
        
        //5: 底部工具栏
        height += toolbarHeight
        
        //6: 使用属性记录
        rowHeight = height
    }
    
    /// 使用单个图像,更新配图视图的大小
    ///
    /// - Parameter image: 网络缓存的单张图片
    func updateSingleImageSize(image: UIImage){
        var size = image.size
        
        //注意: 尺寸需要增加顶部的12个点,便于布局
        size.height += WBStatusPictureViewOutterMargin
        
        //重新设置配图视图大小
        pictureViewSize = size
        
        //更新行高
        updateRowHeight()
    }
    
    /// 计算指定数量的图片对应的配图视图的大小
    ///
    /// - Parameter count: 配图数量
    /// - Returns: 配图视图的大小
    private func calcPictureViewSize(count: Int?) -> CGSize{
        
        if count == 0 || count == nil {
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
