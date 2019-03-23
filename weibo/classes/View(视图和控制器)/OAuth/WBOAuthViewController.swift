import UIKit

//通过 webView 加载新浪微博授权页面控制器
class WBOAuthViewController: UIViewController {

    private lazy var webView = UIWebView()
    
    override func loadView() {
        view = webView
        view.backgroundColor = UIColor.white
        
        //设置导航栏
        title = "登录新浪微博"
        //设置导航栏左侧按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", target: self, actionMethod: #selector(back), isBack: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK - 监听返回方法,关闭UI界面
    @objc private func back(){
        //因为是 present 进来的，所以用dismiss
        dismiss(animated: true, completion: nil)
    }
}
