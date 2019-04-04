import Foundation

/// DAL: Data access layer 数据访问层
/// 使命: 负责处理数据库和网络数据，给listViewModel返回微博的字典数据
class WBStatusListDAL {
    
    /// 从本地数据库或者网络加载数据
    ///
    /// - Parameters:
    ///   - since_id: 下拉刷新id
    ///   - max_id: 上拉刷新id
    ///   - completion: 完成回调(微博的字典数组，是否成功)
    class func loadStatus(since_id: Int64 = 0, max_id: Int64 = 0, completion: @escaping (_ list:[[String: Any]]?, _ isSuccess: Bool)->()) {
        
        guard let userId = WBNetworkManager.shared.userAccount.uid else {
            return
        }
        
        //1: 检查本地数据库是否有数据，如果有，直接返回
        let array = SQLiteManager.shared.laodStatus(userId: userId, since_id: since_id, max_id: max_id)
        if array.count > 0 {
            completion(array, true)
            return
        }
        
        //2: 加载网络
        WBNetworkManager.shared.statusList(since_id: since_id, max_id: max_id) { (list, isSuccess) in
            
            //判断网络请求是否成功
            if !isSuccess {
                completion(nil, false)
                return
            }
            
            guard let list = list else {
                print("array is nil")
                completion(nil, false)
                return
            }
            
            //3: 加载完成之后，将网络数据[字典数组]同步写入缓存到数据库中
            SQLiteManager.shared.updateStatus(userId: userId, array: list)
            
            //4: 返回网络数据
            completion(list, isSuccess)
        }
    }
}
