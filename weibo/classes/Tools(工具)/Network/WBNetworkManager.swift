import UIKit
import AFNetworking //导入就Pods目录里面框架文件夹的名字

//swift中的枚举支持任意数据类型
enum WBHTTPMethod {
    case GET
    case POST
}

//网络管理工具
class WBNetworkManager: AFHTTPSessionManager {
    
    static let shared = WBNetworkManager() //这样一个单例就写完了
    
    //访问令牌，所有微博网络请求，都基于此令牌(登陆除外)
    var accessToken: String? = "2.00qXUXgH0UvlTR6f94cf5e470z8gAh"
    //用户微博id,后面会讲到怎么取这个uid
    var uid : String? = ""
    
    //专门拼接token的网络请求方法，建立tokenRequest()方法，单独处理token字典
    func tokenRequest(method: WBHTTPMethod = .GET, url: String, params: [String: Any], completion: @escaping (_ json:Any?, _ isSucess:Bool)->()){
        //处理token字典
        //>0: 判断token是否为nil，如果为nil直接返回
        guard let token = accessToken else {
             //FIXME: 发送通知,提示用户登录
            print("token is nil,需要登录")
            completion(nil,false)
            return
        }
        
        //>1: 判断params参数字典是否为nil,如果为nil，新建一个字典
        var params = params
        if params == nil {
            params = [String: Any]()
        }
        
        params["access_token"] = token
      
        //调用request()发起真正的网络请求
        request(url: url, params: params, completion: completion)
    }
    
    
    ///使用一个函数封装 AFN 的 GET / POST 请求
    /// - parameter method:     GET/POS
    /// - parameter url:        url
    /// - parameter params:     参数字典
    /// - parameter completion: 完成回调[json(这个json有可能是字典/数组), 是否成功]
    func request(method: WBHTTPMethod = .GET, url: String, params: [String: Any], completion: @escaping (_ json:Any?, _ isSucess:Bool)->()) {
        
        //定义数据请求成功的闭包successCall回调
        let successCall = { (task: URLSessionDataTask, jsonData: Any?) ->() in
            completion(jsonData, true) //调用闭包实现将数据回传到UI界面
        }
         //定义数据请求失败的闭包failureCall回调
        let failureCall = { (task: URLSessionDataTask?, error: Error) ->() in
            
            //针对token过期,服务器返回403的状态码处理
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                print("token 过期了")
                //FIXME: 发送通知(本方法不知道被谁调用,谁接收到通知就谁处理)
            }
            
            print("网络请求错误: \(error)")
            completion(nil, false)
        }
        
        if method == .GET {
            get(url, parameters: params, progress: nil, success: successCall, failure: failureCall)
        } else {
            post(url, parameters: params, progress: nil, success: successCall, failure: failureCall)
        }
    }
}
