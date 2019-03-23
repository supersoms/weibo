import Foundation

//微博数据列表视图模型
/*
 使命: 负责微博数据的处理
 1: 字典转模型
 2: 上拉/下拉刷新数据处理
*/

//上拉刷新最大尝试次数
private let maxPullupTryTimes = 3

class WBStatusListViewModel {
    
    //微博模型数组 懒加载
    lazy var statusList = [WBStatus]()
    
    //上拉刷新错误次数
    private var pullupErrorTimes = 0
    
    // - parameter pullup: 是否上拉刷新标记pullup，true表示上拉刷新
    // - parameter completion: 完成回调[网络请求是否成功, 是否刷新表格] 当微博数据通过模型转换为数组之后，需要返回给调用者，那此时就要用到闭包
    func loadStatus(pullup: Bool, completion: @escaping (_ success: Bool, _ shouldRefresh: Bool)->()){
        
        //判断是否是上拉刷新，同时检查刷新错误
        if pullup && pullupErrorTimes > maxPullupTryTimes{
            completion(true,false)
            return
        }
        
        //下拉刷新 since_id 如果是上拉刷新，since_id就是0，否则就是下拉刷新，那取出数组中第一条微博的id，如果数组第一条id为nil，值就是0
        let since_id = pullup ? 0 : (statusList.first?.id ?? 0) //因first后面带了?号，有可能没有这个id,所以再加个??取0的值
        //上拉刷 max_id 如果不是上拉刷新，那max_id为0就是不用设的意思，否则就是上拉刷新，那就取出数组中最后一条微博的id,如果取出的最后一条微博的id为nil，那值就是0
        let max_id = !pullup ? 0 : (statusList.last?.id ?? 0)
        
        WBNetworkManager.shared.statusList(since_id: since_id, max_id: max_id) { (list, isSuccess) in
            
            //1: 字典(map)转模型,有可能list为nil没数据，所以用??处理，然后通过 as? [WBStatus] 将array转为[WBStatus]
            guard let array = NSArray.yy_modelArray(with: WBStatus.self, json: list ?? []) as? [WBStatus] else {
                completion(isSuccess,false)
                print("array is nil")
                return
            }
            
            print("刷新了\(array.count)数据")
            
            //2: 拼接数据
            if pullup {
                //> 2.1 上拉刷新结束后，将结果拼接在数组的末尾
                self.statusList += array
            } else {
                //> 2.2 下拉刷新时，应该将数组放在数组最前面
                self.statusList = array + self.statusList
            }
            
            //3: 判断上拉刷新的数据量
            if pullup && array.count == 0 {
                self.pullupErrorTimes += 1
                completion(true,false)
            } else {
                //3: 调用闭包告诉调用者成功
                completion(isSuccess,true)
            }
        }
    }
}
