import UIKit

/// 基类控制器
class WBBaseViewController: UIViewController{
    
    //访客视图信息
    var visitorInfo: [String: String]?
    
    //表格视图，如果用户没有登陆，就不创建
    var tableView: UITableView?
    
    //刷新控件
    var refreshControl: UIRefreshControl?
    
    //表示上拉刷新标记
    var isPullup = false
    
    //1: 自定义导航条
    lazy var navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.cz_screenWidth(), height: 64))
    
    //4: 自定义的导航条目
    lazy var navItem = UINavigationItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        //用户登陆之后，才加载数据，否则啥也不干
        WBNetworkManager.shared.userLogon ? loadData() : ()
        
        //注册接收 用户登录成功的通知
        NotificationCenter.default.addObserver(self, selector:#selector(loginSuccess), name: NSNotification.Name(rawValue: WBUserLoginSuccessNotification), object: nil)
    }
    
    deinit {
        //注销用户登录成功的通知
        NotificationCenter.default.removeObserver(self)
    }
    
    ///3: 重写 title 的didSet方法
    override var title: String?{
        didSet{
            navItem.title = title
        }
    }
    
    //加载数据，由子类去实现
    @objc func loadData(){
        refreshControl?.endRefreshing() //如果子类不实现loadData()方法，默认就关闭刷新控件
    }
}

///MARK - 设置界面
extension WBBaseViewController{
    @objc private func setupUI(){
        
        view.backgroundColor = UIColor.white
        //取消自动缩进，如果隐藏了导航栏会缩进20个点
        automaticallyAdjustsScrollViewInsets = false
        setupNavigationBar()
        
        //如果用户己登陆显示正常的视图，未登陆显示访客视图
        WBNetworkManager.shared.userLogon ? setupTableView() : setupVisiorView()
    }
    
    //添加设置表格视图,只有用户登陆成功之后才会显示
    @objc func setupTableView(){
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.insertSubview(tableView!, belowSubview: navigationBar) //tableView位于navigationBar下面
        //设置数据源&代理 -> 目的：子类直拉实现数据源的方法
        tableView?.dataSource = self
        tableView?.delegate = self
        
        //设置内容缩进
        tableView?.contentInset = UIEdgeInsets(top: (navigationBar.bounds.height-20), left: 0, bottom: 0, right: 0)
        //如果底部会遮住这样设置：bottom: tabBarController?.tabBar.bounds.height ?? 49,
        
        //当登录成功之后,tabView的滚动指示器是从状态栏开始的，需要修改指示器的缩进
        tableView?.scrollIndicatorInsets = tableView!.contentInset
        
        //设置刷新控件
        refreshControl = UIRefreshControl()      //初始化刷新控件
        tableView?.addSubview(refreshControl!)   //将刷新控件添加到tableView控件上,因将refreshControl添加到tableView是必选的，所以强解包
        
        //为刷新控件refreshControl添加监听方法
        /**
         When a user has pulled-to-refresh, the UIRefreshControl fires its UIControlEventValueChanged event.
         当用户下拉刷新控件时触发UIControlEventValueChanged事件
        */
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }
    
    //设置访客视图
    private func setupVisiorView(){
        let visiorView = WBVisitorView(frame: view.bounds)
        view.insertSubview(visiorView, belowSubview: navigationBar)
        //1: 给访客视图界面设置信息
        visiorView.visitorInfoDict = visitorInfo
        
        //2: 添加访客视图的注册和登陆按钮的监听方法
        visiorView.registerBtn.addTarget(self, action: #selector(register), for: .touchUpInside)
        visiorView.loginBtn.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        //3: 设置导航条按钮(注册与登陆)
        navItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: .plain, target: self, action: #selector(register))
        navItem.rightBarButtonItem = UIBarButtonItem(title: "登陆", style: .plain, target: self, action: #selector(login))
    }
    
    //设置导航条
    private func setupNavigationBar(){
        //2: 添加导航条
        view.addSubview(navigationBar)
        //5: 将item设置给bar
        navigationBar.items=[navItem]
        //设置整个 navBar 条子的背景颜色
        if WBNetworkManager.shared.userLogon {
             navigationBar.barTintColor = UIColor.cz_color(withHex: 0xffffff) //用户己登陆，设置整个导航条背景颜色为白色
        } else{
             navigationBar.barTintColor = UIColor.cz_color(withHex: 0xEDEDED) //用户己登陆，设置整个导航条背景颜色为灰色
        }
        //设置 navBar 中间标题字体的颜色为深灰色
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        //设置左上角与右上角系统按钮的文字颜色
        navigationBar.tintColor = UIColor.orange
    }
}

//注意
//1: extension中不能有属性
//2: extension中不能重写父类的方法
extension WBBaseViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 //因为基类不负责数据实现，所以返回0
    }
    
    //基数只是准备方法，子类去实现
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell() //这里的return 返回一个对象只是保证没有语法错误
    }
    
    //在显示最后一行的时候作上拉刷新
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //判断indexPath是否是最后一行
        // - 1: 取出row,row表示当前是第几行数据
        let row = indexPath.row
        // - 2: 取出最后一行
        let secion = tableView.numberOfSections - 1
        
        if row < 0 || secion < 0{
            return
        }
        // - 3: 取总共有多少行数
        let count = tableView.numberOfRows(inSection: secion)
        
        //如果是最后一行同时没有开始上拉刷新
        if row == (count - 1) && !isPullup {
            print("上拉刷新")
            isPullup = true
            //开始刷新
            loadData()
        }
    }
}

//访客视图监听方法
extension WBBaseViewController {
    
    @objc private func login(){
        //发送用户需要登录的通知
        NotificationCenter.default.post(name: Notification.Name(WBUserShouldLoginNotification), object: nil)
    }
    
    @objc private func register(){
        print("用户注册")
    }
    
    /// 登录成功之后的处理逻辑
    ///
    /// - Parameter n: 通知对象
    @objc private func loginSuccess(n: Notification){
        print("用户登录成功的通知: \(n)")
        
        //清除左上角的注册与右上角的登录按钮
        navItem.leftBarButtonItem = nil
        navItem.rightBarButtonItem = nil
        
        //登录成功之后更新UI界面,将访客视图替换为表格视图,需要重新设置UI
        //在访问 view 的 getter 时,如果view == nil时会调用loadView方法,而loadView方法执行完执行viewDidLoad方法
        view = nil
        
        //因会重新执行viewDidLoad方法,所以需要注销用户登录成功的通知,不然会重复注册通知,那到时通知会发送多次,避免通知被重复注册
        NotificationCenter.default.removeObserver(self)
    }
}
