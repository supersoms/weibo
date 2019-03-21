import UIKit

/// 基类控制器
class WBBaseViewController: UIViewController{

    //根据用户登陆的状态来是否显示访客视图,false表示用户未登陆
    var userLogon = false
    
    //访客视图信息
    var visitorInfo: [String: String]?
    
    //表格视图，如果用户没有登陆，就不创建
    var tableView: UITableView?
    
    //刷新控件
    var refreshControl: UIRefreshControl?
    
    //表示上拉刷新标记
    var isPullup = false
    
    //1: 自定义导航条
    lazy var navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 15, width: UIScreen.cz_screenWidth(), height: 64))
    
    //4: 自定义的导航条目
    lazy var navItem = UINavigationItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
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
    @objc func setupUI(){
        //view.backgroundColor = UIColor.cz_random()
        
        view.backgroundColor = UIColor.white
        //取消自动缩进，如果隐藏了导航栏会缩进20个点
        automaticallyAdjustsScrollViewInsets = false
        setupNavigationBar()
        
        //如果用户己登陆显示正常的视图，未登陆显示访客视图
        userLogon ? setupTableView() : setupVisiorView()
    }
    
    //添加设置表格视图
    private func setupTableView(){
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.insertSubview(tableView!, belowSubview: navigationBar) //tableView位于navigationBar下面
        //设置数据源&代理 -> 目的：子类直拉实现数据源的方法
        tableView?.dataSource = self
        tableView?.delegate = self
        
        //设置内容缩进
        tableView?.contentInset = UIEdgeInsets(top: (navigationBar.bounds.height-20), left: 0, bottom: 0, right: 0)
        //如果底部会遮住这样设置：bottom: tabBarController?.tabBar.bounds.height ?? 49,
        
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
        //给访客视图界面设置信息
        visiorView.visitorInfoDict = visitorInfo
        
        //添加访客视图的注册和登陆按钮的监听方法
        visiorView.registerBtn.addTarget(self, action: #selector(register), for: .touchUpInside)
        visiorView.loginBtn.addTarget(self, action: #selector(login), for: .touchUpInside)
    }
    
    //设置导航条
    private func setupNavigationBar(){
        //2: 添加导航条
        view.addSubview(navigationBar)
        //5: 将item设置给bar
        navigationBar.items=[navItem]
        //设置 navBar 的渲染颜色
        navigationBar.barTintColor = UIColor.cz_color(withHex: 0xF6F6F6)
        //设置 navBar 的字体颜色为深灰色
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
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
        
        print("secion:\(secion)")
    }
}

//访客视图监听方法
extension WBBaseViewController {
    @objc private func login(){
        print("用户登陆")
    }
    @objc private func register(){
        print("用户注册")
    }
}
