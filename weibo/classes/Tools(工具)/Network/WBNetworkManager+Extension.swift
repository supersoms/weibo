import Foundation

// MARK: - 封装新浪微博的网络请求方法
extension WBNetworkManager {
    
    /// 加载微博数据字典数组
    /// parameter completion: 完成回调[list: 微博字典数组/是否成功]
    func statusList(completion: @escaping (_ list:[[String: Any]]?, _ isSuccess: Bool)->()){
        print("===开始加载数据===")
        let url = "https://api.weibo.com/2/statuses/home_timeline.json"
        let params = [String: Any]()
        WBNetworkManager.shared.tokenRequest(url: url, params: params) { (json, isSuccess) in
            //从json中获取 statuses 字典数组,如果 as? 失败,那result == nil
//            let result = json?["statuses"] as? [[String: Any]]
            let jsonString = json as? [String: Any]
            let result = jsonString?["statuses"] as? [[String : Any]]
            completion(result , isSuccess)
        }
    }
}
