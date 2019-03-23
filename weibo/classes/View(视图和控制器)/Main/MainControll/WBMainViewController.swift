import UIKit

/// 主控制器
class WBMainViewController: UITabBarController {

    //定时器，用于定时检查新微博的数量
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildControllers()
        setupComposeButton()
        setupTimer()
        //设置点击home按钮的代理
        delegate = self
    }
    
    //定时器一定要销毁,所以在析构函数中实现,由系统调用
    deinit {
        timer?.invalidate()
    }
    
    /**
     portrait: 竖屏(英文单词意思为肖像)
     landscape:横屏(英文单词意思为风景画)
     - 使用代码控制屏幕的方向
     - 设置支持的方向之后，当前的控制器及子控制器都会遵守这个方向
     - 如果播放视频，通常是通过modal自定义转场展现的
    */    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    //MARK: - 为撰写按钮添加监听方法
    //private修饰符：能够保证方法私有，仅被当前对象访问，不允许外部访问，保证方法的安全
    //@objc修饰符：允许此函数在运行时通过OC的消息机制被调用，即便此函数是私有了，但在运行时OC还是可以访问它
    @objc private func composeButtonStatus(){
        print("撰写微博")
    }
    
    ///MARK - 生成 + 号撰写按钮 私有控件
    private lazy var composeButton: UIButton = UIButton.cz_imageButton("tabbar_compose_icon_add", backgroundImageName: "tabbar_compose_button")
    
}

//MARK: - 设置界面
extension WBMainViewController{
    
    //设置撰写+号按钮
    private func setupComposeButton(){
        //1：将+号按钮添加到tabbar上
        tabBar.addSubview(composeButton)
        //2：设置按钮的位置,计算按钮的宽度
        let count = CGFloat(children.count) //获取子控件的个数
        //减1是为了去掉iPhone的容错点让w宽度小了1个点，那按钮就会大1个点，将向内缩进的宽度减少，能够让按钮的宽度变大，盖住容错点
        let width = tabBar.bounds.width / count  //先获取整个tabBar的宽度，再除以几个子控件，得出一个子控件的宽度
        //insetBy()正数向内缩进，负数向外扩展
        composeButton.frame = tabBar.bounds.insetBy(dx: 2 * width, dy: 0) //水平的往里面缩：因为+号按钮在中间，所以就是宽度*2
        //为composeButton按钮添加监听事件
        composeButton.addTarget(self, action: #selector(composeButtonStatus), for: .touchUpInside)
    }
    
    // 设置所有子控制器
    private func setupChildControllers(){
        
        //从沙盒中获取应用程序配置信息
        //> 1: 获取沙盒的json路径
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] //取沙盒目录,[0]就不用解包了
        let jsonPath = (docDir as NSString).appendingPathComponent("main.json") //在文档目录下(Documents)生成main.json
        //> 2: 加载 data
        var data = NSData(contentsOfFile: jsonPath)
        //> 3: 判断 data 是否有内容，如果没有，说明本地沙盒没有文件
        if data == nil {
            //> 4: 从bundle加载配置json数据
            let path = Bundle.main.path(forResource: "main.json", ofType: nil)
            data = NSData(contentsOfFile: path!)
            return
        }
        
        // 将json数据反序列化转换成数组
        guard let array = try? JSONSerialization.jsonObject(with: data! as Data, options: []) as? [[String: Any]]  else {
                print("path is nil")
                return
        }
        var arrayM = [UIViewController]()
        for dict in array! {
            arrayM.append(controller(dict: dict))
        }
        viewControllers = arrayM //Tabbar才有这个属性
    }
    
    // 使用字典创建一个子控制器
    // param dict: map
    // return : 子控制器
    private func controller(dict:[String: Any]) -> UIViewController {
        //1: 获取字典内容
        guard let clsName = dict["clsName"] as? String, let title = dict["title"] as? String, let imageName = dict["imageName"] as? String,
            let cls = NSClassFromString(Bundle.main.namespac+"."+clsName) as? WBBaseViewController.Type,
            let visitorDict = dict["visitorInfo"] as? [String:String] else {
            print("clsName, title, imageName is nil ")
            return UIViewController()
        }
        //2: 创建视图控制器，到这里，cls和title,imageName都不为空了,
        let vc = cls.init()
        vc.title = title
        
        //设置控制器的访客信息字典, 给访客视图界面对象赋值
        vc.visitorInfo = visitorDict
        
        //3: 动态设置Tabbar的默认图标与按下的效果图标
        vc.tabBarItem.image = UIImage(named: "tabbar_" + imageName) //Tabbar默认图标
        vc.tabBarItem.selectedImage = UIImage(named: "tabbar_" + imageName + "_selected") //Tabbar按下的效果图标
        //4.1: 设置 Tabbar 的标题字体颜色，当点击按下时颜色为橙色高亮
        vc.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.orange], for: .highlighted)
        //4.2: 设置 Tabbar 的标题字体的大小，系统默认是12号字体
        vc.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], for: UIControl.State(rawValue:0))
        
        let nav = WBNavigationController(rootViewController:vc)
        return nav
    }
}

//定时器的相关方法
extension WBMainViewController {
    
    private func setupTimer(){
        //> 1: 实例化Timer,每隔8秒会调用一下 updateTimer 这个方法
        timer = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    //时钟触发方法
    @objc private func updateTimer(){
        WBNetworkManager.shared.unreadCount { (unreadCount) in                                  
            //>1: 当获取到未读数之后，设置首页 tabBarItem 的 badgeNumber
            self.tabBar.items?[0].badgeValue = unreadCount > 0 ? "\(unreadCount)" : nil
            
            //>2: 设置App的badgeNumber,从iOS8开始,需要用户授权之后才可以显示未读数
            UIApplication.shared.applicationIconBadgeNumber = unreadCount                                 
        }
    }
}

extension WBMainViewController : UITabBarControllerDelegate{
    
    /// 将要选择TabBarItem
    /// parameter tabBarController: tabBarController
    /// parameter viewController:   目标控制器
    /// return Bool:                是否切换到目标控制器
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("将要切换到\(viewController)")
        //判断目标控制器是否是 UIViewController
        return !viewController.isMember(of: UIViewController.self) //是否是哪个类但不包含子类
    }
}
