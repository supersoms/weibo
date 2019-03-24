import UIKit

private let accountInfoFile : NSString = "useraccount.json"

//用户账户信息
class WBUserAccount: NSObject {
    
    //以下的属性必须跟接口返回的属性名一致，不然无法映射
    //访问令牌
    @objc var access_token: String? //= "2.00qXUXgH0UvlTRc360822b2dKNqxFB"
    
    //用户id
    @objc var uid: String?
    
    //过期时间，单位秒，开发者5年(每次登陆之后，都是5年)，使用者3天(会从第1次登陆开始递减)
    @objc var expires_in: TimeInterval = 0 {
        didSet {
            //通过didSet给expiresDate赋值，格式化的数据为：expiresDate = 2024-03-22 05:51:03 +0000;
            expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    
    //是否是真名
    @objc var isRealName: String?
    
    //过期日期
    @objc var expiresDate: Date?
    
    //用户昵称 来源接口: 获取用户的个人信息接口show.json
    @objc var screen_name: String?
    
    //用户头像地址（大图）180×180像素 来源接口: 获取用户的个人信息接口show.json
    @objc var avatar_large: String?
    
    override var description: String{
        return yy_modelDescription()
    }
    
    override init() {
        super.init()
        //1: 从磁盘沙盒加载保存的用户信息
        //加载磁盘文件到二进制数据，如果失败直接返回
        guard let path = accountInfoFile.cz_appendDocumentDir(),
            let data = NSData(contentsOfFile: path),
            let dict = try? JSONSerialization.jsonObject(with: data as Data, options: []) as? [String: Any] else{
                return
        }
        //2: 使用字典给当前的模型的属性设置值,用户是否登陆的关键代码
        self.yy_modelSet(with: dict ?? [:])
        
        //3: token有效期的过期处理: 判断token是否过期,取出对象的有效期与当前的日期进行比较,如果有效期与当前日期降序比较，小
        //expiresDate = Date(timeIntervalSinceNow: -3600 * 24) //减1天
        if self.expiresDate?.compare(Date()) != .orderedDescending{
            print("token己过期")
            //token己过期，清空token
            access_token = nil
            uid = nil
            //删除用户文件
            _ = try? FileManager.default.removeItem(atPath: path)
        }
    }
    
    //将用户信息用json保存到沙盒
    func saveAccount(){
        //1: 模型(类对象)转为字典,此时的self就是WBUserAccount
        var dict = (self.yy_modelToJSONObject() as? [String: Any]) ?? [:]
        //删除 expires_in key
        dict.removeValue(forKey: "expires_in")
        
        //2: 字典序列化
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
              let filePath = accountInfoFile.cz_appendDocumentDir() else {
            return
        }
        
        //3: 写入磁盘,放在文档目录下
        (data as NSData).write(toFile: filePath, atomically: true)
        
        print("用户账户信息保存成功! 文件保存在: \(filePath)")
    }
}
