import UIKit
import UserNotifications
import SVProgressHUD
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupAdditions()
        loadAPPConfigInfo()
        sleep(2)
        window = UIWindow()
        window?.backgroundColor = UIColor.white
        window?.rootViewController = WBMainViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

///MARK - 从服务器加载应用程序配置信息,不需要回调,直接保存在磁盘上
extension AppDelegate{
    private func loadAPPConfigInfo(){
        //模拟异步加载配置信息
        DispatchQueue.global().async {
            //1: url
            let url = Bundle.main.url(forResource: "main.json", withExtension: nil)
            //2: 将url转为二进制数据
            let data = NSData(contentsOf: url!)
            //3: 将此模拟从网络上请求到的配置信息数据写入到沙盒
            let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] //取沙盒目录,[0]就不用解包了
            let jsonPath = (docDir as NSString).appendingPathComponent("main.json") //在文档目录下(Documents)生成main.json
            data?.write(toFile: jsonPath, atomically: true)
            print("加载应用程序配置信息完毕:\(jsonPath)")
        }
    }
}

// MARK - 设置应用程序额外信息
extension AppDelegate {
    
    private func setupAdditions(){
        //1: 设置SVProguressHUD显示Dialog的最小时间,时间越小越快关闭
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        
        //2: 设置网络加载器的进度条,会在状态栏显示一个小小的转圈进度条
        AFNetworkActivityIndicatorManager.shared().isEnabled = true
        
        //3: 设置用户授权显示通知
        // #available 是检查设备版本,如果是iOS 10.0 以上，用此种方式获取通知
        if #available(iOS 10.0, *) {
            //一定要导包 import UserNotifications,代码才能出来
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.carPlay,.sound]) { (success, error) in
                print("用户授权" + (success ? "成功" : "失败"))
            }
        } else {
            //iOS 10.0 以下,以下方式取得用户授权显示通知[状态栏上方的提示条/声音/BadgeNumber]
            let notifySettings = UIUserNotificationSettings(types: [.alert,.badge,.sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notifySettings)
        }
    }
}
