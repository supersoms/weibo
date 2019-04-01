import UIKit

private let originalCellId = "originalCellId"   //原创微博可重用cell id,表示只有此类全局可以访问
private let retweetedCellId = "retweetedCellId" //被转发微博可重用cell id,表示只有此类全局可以访问

/// 首页
class WBHomeViewController: WBBaseViewController {
    
    //懒加载,创建了一个微博列表数组模型对象
    private lazy var listViewModel = WBStatusListViewModel()
    
    //显示好友
    @objc private func showFriends(){
        print("正在显示好友")
        let vc = WBTestDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //加载首页数据，重写父类的方法
    override func loadData() {
        
        //添加此方法,解决网络慢不好的情况下,白屏的问题
        refreshControl?.beginRefreshing()

        listViewModel.loadStatus(pullup: self.isPullup) { (isSuccess,shouldRefresh) in

            print("加载数据结束")

            //刷新完成之后结束刷新
            self.refreshControl?.endRefreshing()
            self.isPullup = false
            //如果shouldRefresh为真表示还有数据，需要刷新表格
            if shouldRefresh {
                self.tableView?.reloadData()
            }
        }
    }
}

///MARK - 重写父类setupUI()方法设置界面
extension WBHomeViewController {
    
    override func setupTableView() {
        super.setupTableView()
        
        //自定义按钮实现按下时文字高亮效果
        navItem.leftBarButtonItem = UIBarButtonItem(title: "好友", target: self, actionMethod: #selector(showFriends))
        
        //注册原型 cell
//        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        //使用自定义的 cell
        tableView?.register(UINib(nibName: "WBStatusNormalCell", bundle: nil), forCellReuseIdentifier: originalCellId)
        
        tableView?.register(UINib(nibName: "WBStatusRetweetedCell", bundle: nil), forCellReuseIdentifier: retweetedCellId)
        
        //设置行高为自动行高,如果取消了,就得走代理方法 func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//        tableView?.rowHeight = UITableView.automaticDimension
        //设置预估行高
        tableView?.estimatedRowHeight = 300
        
        //取消微博正文内容底部的分割线
        tableView?.separatorStyle = .none
        
        setupNavTitle()
    }
    
    //设置Home主页的导航栏的中间标题
    private func setupNavTitle(){
        let title = WBNetworkManager.shared.userAccount.screen_name
        let button = WBTitleButton(title: title)
        navItem.titleView = button
        button.addTarget(self, action: #selector(clickTitleButton), for: .touchUpInside)
    }
    
    @objc func clickTitleButton(btn: UIButton){
        //设置选中状态
        btn.isSelected = !btn.isSelected
    }
}

//为表格绑定数据源方法
extension WBHomeViewController {
    
    //具体的数据源方法实现，不需要super
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //1: 取出视图模型,根据视图模型判断可重用cell
        let vm = listViewModel.statusList[indexPath.row]
        
        //2: 取cell
        let cellId = (vm.status.retweeted_status != nil) ? retweetedCellId : originalCellId
        
        //3: 设置cell，其实就相当于Android中的先取得Id,然后于给这个id控件设置相应的数据
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! WBStatusCell
        cell.viewModel = vm
        
        //4: 返回cell
        return cell
    }
    
    //默认情况下，没有override，在swift2.0中没有关系，但在swift3.0以上没有override表示父类没有此方法，此方法不会被调用, swift4.0 不用写也可以调用,
    //调用了此方法，表示在别处计算了行高的逻辑 updateRowHeight()
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //1: 根据 indexPath 获取视图模型
        let vm = listViewModel.statusList[indexPath.row]
        //2: 返回计算好的行高
        return vm.rowHeight
    }
}
