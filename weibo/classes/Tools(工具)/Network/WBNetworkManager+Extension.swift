import Foundation

// MARK: - 封装新浪微博的网络请求方法
extension WBNetworkManager {
    
    /// 加载微博数据字典数组
    /// parameter since_id: API接口声明，若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
    /// parameter max_id: API接口声明，若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
    /// parameter completion: 完成回调[list: 微博字典数组/是否成功]
    func statusList(since_id: Int64 = 0, max_id: Int64 = 0, completion: @escaping (_ list:[[String: Any]]?, _ isSuccess: Bool)->()){
        print("===开始加载数据===")
        let url = "https://api.weibo.com/2/statuses/home_timeline.json"
        let params = ["since_id":since_id,"max_id":(max_id > 0 ? max_id - 1 : 0 )] //此两个参数是下拉刷新微博时用到的参数, 计算max_id，解决最后一条数据重复的bug
        
        WBNetworkManager.shared.tokenRequest(url: url, params: params) { (json, isSuccess) in
            //服务器返回的数据就是以时间倒序排序的
            //从json中获取 statuses 字典数组,如果 as? 失败,那result == nil
//            let result = json?["statuses"] as? [[String: Any]]
            let jsonString = json as? [String: Any]
            let result = jsonString?["statuses"] as? [[String : Any]]
            completion(result , isSuccess)
        }
    }
}
