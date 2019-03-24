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
    
    ///返回微博的未读数
    func unreadCount(completion:@escaping (_ unreadCount: Int)->()){
        guard let uid = userAccount.uid else {
            print("uid is nil")
            return
        }
        let url = "https://rm.api.weibo.com/2/remind/unread_count.json"
        let params = ["uid": uid]
        WBNetworkManager.shared.tokenRequest(url: url, params: params) { (json, isSuccess) in
            //> 1: 拿到字典
            let dict = json as? [String: Any]
            //> 2: 从json数据里面通过key: status 获取未读数据
            let status = dict?["status"] as? Int //在没有用as?Int转为Int之前,status的类型是Any?,所以要转为Int类型
            completion(status ?? 0)
        }
    }
}

// MARK: - 获取OAuth相关的方法
extension WBNetworkManager {
    
    //获取accessToken
    func getAccessToken(code:String){
        let url = "https://api.weibo.com/oauth2/access_token"
        //client_id: 申请应用时分配的AppKey
        //client_secret: 申请应用时分配的AppSecret
        //grant_type: 请求的类型，填写authorization_code
        //code: 授权码
        //redirect_uri: 重定向回调页面
        let params = ["client_id":WBAppKey,
                      "client_secret":WBAppSecret,
                      "grant_type":"authorization_code",
                      "code":code,
                      "redirect_uri":WBRedirectURI]
        request(method: .POST, url: url, params: params) { (json, isSuccess) in
            //返回的数据格式为: 这是一个字典
//            Optional({
//            "access_token" = "2.00qXUXgH0UvlTRc360822b2dKNqxFB";
//            "expires_in" = 157679999;
//            isRealName = true;
//            "remind_in" = 157679999;
//            uid = 7041518178;
//            })
            print("获取accessToken返回的json:\(json)")
            
            //直接使用字典设置 userAccount 的属性, 空字典是 [:]
            self.userAccount.yy_modelSet(with: json as? [String : Any] ?? [:]) //因json是Any?类型，所以要进行转换,
            print("将字典转为模型(类)之后userAccount数据为:\(self.userAccount)")
        }
    }
}
