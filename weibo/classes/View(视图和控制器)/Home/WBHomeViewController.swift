import UIKit

private let cellId = "cellId" //表示只有此类全局可以访问

/// 首页
class WBHomeViewController: WBBaseViewController {
    
    //懒加载了微博数据数组
    private lazy var statusList = [String]()
    
    //显示好友
    @objc private func showFriends(){
        print("正在显示好友")
        let vc = WBTestDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //加载首页数据，重写父类的方法
    override func loadData() {
        
        WBNetworkManager.shared.statusList { (list, isSuccess) in
            print(list)
        }
        
        print("开始加载数据")
        //模拟延迟加载数据 -> dispatch_after
        //在当前时间的基础上加 2 秒，实现延迟的效果
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            
            //生成测试数据
            for i in 0..<15 {
                if self.isPullup {
                    self.statusList.append("上拉数据\(i)")//上拉的话，数据追加到底部
                } else {
                    self.statusList.insert(i.description, at: 0) //下拉的话，每次将数据插入到数组的顶部
                }
            }
            print("刷新表格数据")
            
            //刷新完成之后结束刷新
            self.refreshControl?.endRefreshing()
            self.isPullup = false
            //刷新表格
            self.tableView?.reloadData()
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
        return statusList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //1: 取cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        //2: 设置cell，其实就相当于Android中的先取得Id,然后于给这个id控件设置相应的数据
        cell.textLabel?.text = statusList[indexPath.row]
        //3: 返回cell
        return cell
    }
}
