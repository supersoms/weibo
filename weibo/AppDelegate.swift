import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
