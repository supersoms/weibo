import Foundation

///单条微博的视图模型
class WBStatusViewModel {
    
    var status: WBStatus        //首页微博列表模型
    
    ///构造函数
    ///因为status定义时不是可选的，所以必须在init中初始化
    init(model: WBStatus) {
        self.status = model
    }
}
