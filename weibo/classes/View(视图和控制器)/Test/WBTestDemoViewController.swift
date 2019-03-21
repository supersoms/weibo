import UIKit

class WBTestDemoViewController: WBBaseViewController {
    
//    override func viewDidLoad() {
//        title = "第\(navigationController?.children.count ?? 0)个"
//    }
    
    //MARK - 监听方法
    ///继续push一个新的控制器(就是一直点击'下一个'按钮,一直会进行跳转)
    @objc private func showNext(){
        let vc = WBTestDemoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension WBTestDemoViewController{
    //设置右侧的控制器（就是设置右上角的下一个按钮）
    override func setupTableView() {
        super.setupTableView()
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "下一个", style: .plain, target: self, action: #selector(showNext))
        
        //自定义按钮实现按下时文字高亮效果
        navItem.rightBarButtonItem = UIBarButtonItem(title: "下一个", target: self, actionMethod: #selector(showNext))
    }
}
