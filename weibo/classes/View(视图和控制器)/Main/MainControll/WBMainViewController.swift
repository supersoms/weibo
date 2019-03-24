import UIKit
import SVProgressHUD

/// 主控制器
class WBMainViewController: UITabBarController {

    //定时器，用于定时检查新微博的数量
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildControllers()
        setupComposeButton()
        setupTimer()
        //设置新特性视图
        setupNewFeatureViews()
        //设置点击home首页按钮的代理
        delegate = self
        //注册接收 用户需要登录的通知
        NotificationCenter.default.addObserver(self, selector:#selector(userLogin), name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: nil)
    }
    
    deinit {
        //deinit相当Android中的Destroy()方法
        //定时器一定要销毁,所以在析构函数中实现,由系统调用,
        timer?.invalidate()
        
        //注销用户需要登录的通知
        NotificationCenter.default.removeObserver(self)
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
    
    @objc private func userLogin(n: Notification){
        print("用户登录通知: \(n)")
        //判断n.object是否有值，如果有值，提示用户重新登录
        
        var when = DispatchTime.now() //默认情况下不延时
        if n.object != nil {
            when = DispatchTime.now() + 2 //token过期,延时2秒再执行跳转到登录授权页面
            SVProgressHUD.setDefaultMaskType(.gradient) //设置进度条的渐变效果
            SVProgressHUD.showInfo(withStatus: "用户登录己经超时，需要重新登录!")
        }
        //当上面的dialog显示完成之后再过2秒跳转到授权登录页面
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            SVProgressHUD.setDefaultMaskType(.clear) //恢复进度条的原始效果
            //展现登陆控制器 - 通常会和 UINavigationController 连用，方便返回
            let vc = UINavigationController(rootViewController: WBOAuthViewController())
            self.present(vc, animated: true, completion: nil)
        }
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
        //> 1: 实例化Timer,每隔60秒会调用一下 updateTimer 这个方法
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    //时钟触发方法
    @objc private func updateTimer(){
        print("正在检测微博未读数")
        //如果没有登陆,直接返回
        if !WBNetworkManager.shared.userLogon {
            return
        }
        WBNetworkManager.shared.unreadCount { (unreadCount) in
            //>1: 当获取到未读数之后，设置首页 tabBarItem 的 badgeNumber
            self.tabBar.items?[0].badgeValue = unreadCount > 0 ? "\(unreadCount)" : nil
            
            //>2: 设置App的badgeNumber,从iOS8开始,需要用户授权之后才可以显示未读数
            UIApplication.shared.applicationIconBadgeNumber = unreadCount                                 
        }
    }
}

//判断是否是home首页，如果是首页，点击首页按钮滚动到顶部并且刷新数据
extension WBMainViewController : UITabBarControllerDelegate{
    
    /// 将要选择TabBarItem
    /// parameter tabBarController: tabBarController
    /// parameter viewController:   目标控制器
    /// return Bool:                是否切换到目标控制器
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("将要切换到\(viewController)")
        
        //TODO 如果是HomeViewController首页，同时有未读数，点击滚动到顶部并且加载数据，点击切换到其它按钮就不管
        //> 1: 获取控制器在数组中的索引
        let index = (children as NSArray).index(of: viewController)
        //> 2: 判断当前索引是首页，同时index也是首页，这就表示是重复点击首页的按钮
        if selectedIndex == 0 && index == selectedIndex{
            print("点击首页")
            //> 3: 让表格滚动到顶部
            //> 3.1 让表格滚动到顶部,需要先拿到控制器
            let nav = children[0] as! UINavigationController
            let vc = nav.children[0] as! WBHomeViewController
            //> 3.2 让tableView 滚动到顶部,需要除掉状态栏的高度
            vc.tableView?.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
            //> 4: 刷新数据
            //如果从别的tabBar的按钮点击过来，再次点击首页按钮，如果不能滚动到顶部，那就用DispatchQueue.main.asyncAfter()处理
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
//                vc.loadData()
//            }
            vc.loadData()
        }
        //判断目标控制器是否是 UIViewController
        return !viewController.isMember(of: UIViewController.self) //是否是哪个类但不包含子类
    }
}

//新特性试图处理
extension WBMainViewController {
    
    //设置新特性视图
    private func setupNewFeatureViews(){
        //判断用户是否登录,如是没登录不显示新特性
        if !WBNetworkManager.shared.userLogon {
            print("用户没有登录")
            return
        }
        
        
        //>1: 检查版本是否更新
        
        //>2: 如果更新,显示新特性,否则显示欢迎视图
        let v = isNewVersion ? WBNewFeature() : WBWecomeView.wecomeView()
        
        //>3: 添加视图
        view.addSubview(v)
    }
    
    /**
     版本号的科普
        - 在AppStore每次升级应用程序，版本号都需要增加
        - 版本号的组成: 由主版本号.次版本号.修订版本号
        - 各版本号的用处:
            -主版本号: 意味着大版本的修改,使用者也需要做大的适应
            -次版本号: 意味着小版本的修改,是某些函数或方法的使用或者参数有变化
            -修订版本号: 程序 / 框架内部bug的修改,不会对使用者造成任何影响
    */
    //使用计算型属性，计算型属性跟OC的只读方法一样，本身不会占用存储空间，它类似于一个函数
    private var isNewVersion: Bool{
        //>1: 取当前的版本号,当前的版本号保存在info.plist文件里
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        print("当前APP版本号: \(currentVersion)")
        
        //>2: 取保存在'Document'目录中的之前的版本号,最理想是保存在用户偏好
        let path: String = ("version" as NSString).cz_appendDocumentDir()
        let sandboxVersion = (try? String(contentsOfFile: path)) ?? ""
        print("沙盒版本: \(sandboxVersion)")
        
        //>3: 将当前版本号保存在沙盒中,文件名就是version
        _ = try? currentVersion.write(toFile: path, atomically: true, encoding: .utf8)
        
        //>4: 返回两个版本号是否一致
        return false
    }
}
