import UIKit

private let cellId = "cellId" //表示只有此类全局可以访问

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
        
        print("准备刷新，最后一条数据为: \(self.listViewModel.statusList.last?.text)")
        
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
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
}

//为表格绑定数据源方法
extension WBHomeViewController {
    
    //具体的数据源方法实现，不需要super
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //1: 取cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        //2: 设置cell，其实就相当于Android中的先取得Id,然后于给这个id控件设置相应的数据
        cell.textLabel?.text = listViewModel.statusList[indexPath.row].text
        //3: 返回cell
        return cell
    }
}
