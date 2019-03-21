import UIKit

/// 主控制器
class WBMainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildControllers()
        setupComposeButton()
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
        let width = tabBar.bounds.width / count - 1  //先获取整个tabBar的宽度，再除以几个子控件，得出一个子控件的宽度
        //insetBy()正数向内缩进，负数向外扩展
        composeButton.frame = tabBar.bounds.insetBy(dx: 2 * width, dy: 0) //水平的往里面缩：因为+号按钮在中间，所以就是宽度*2
        //为composeButton按钮添加监听事件
        composeButton.addTarget(self, action: #selector(composeButtonStatus), for: .touchUpInside)
    }
    
    // 设置所有子控制器
    private func setupChildControllers(){
        
        //以下这些图标与文字信息，现在很多APP是通过请求网络Json数据来动态处理的
        let array: [[String: Any]] = [
            ["clsName": "WBHomeViewController", "title": "首页", "imageName": "home", "visitorInfo":["imageName":"","message":"关注一些人，回这里看看有什么惊喜"]],
            ["clsName": "WBMessageViewController", "title": "消息", "imageName": "message_center","visitorInfo":["imageName":"visitordiscover_image_message","message":"登录后，别人评论你的微博，发给你的消息，都会显示在这里"]],
            ["clsName": "UIViewController"],
            ["clsName": "WBDiscoverViewController", "title": "发现", "imageName": "discover","visitorInfo":["imageName":"visitordiscover_image_message","message":"登录后，最新，最热微博尽在掌握"]],
            ["clsName": "WBProfileViewController", "title": "我", "imageName": "profile","visitorInfo":["imageName":"visitordiscover_image_profile","message":"登录后，你的微博，相册，个人资料会显示在这里"]]
            ]
        //将这些配置信息写入到沙盒中，就是写入文件中
        (array as NSArray).write(toFile: "/Users/qilin/Desktop/weibo.plist", atomically: true)
        
        //将数组转为Json序列化,options:表示输出有格式的json
        let data = try! JSONSerialization.data(withJSONObject: array, options: [.prettyPrinted])
        (data as NSData).write(toFile: "/Users/qilin/Desktop/weibo.json", atomically: true)
        
        
        
        var arrayM = [UIViewController]()
        for dict in array{
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
