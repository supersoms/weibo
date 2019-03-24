import UIKit
import SVProgressHUD

//通过 webView 加载新浪微博授权页面控制器
class WBOAuthViewController: UIViewController {

    private lazy var webView = UIWebView()
    
    override func loadView() {
        view = webView
        view.backgroundColor = UIColor.white
        
        //取消webView的滚动,这样就拖拉不了webView了,新浪服务器返回的授权页面默认就是手机全屏
        webView.scrollView.isScrollEnabled = false
        //设置代码, 用于监听webView加载页面的请求
        webView.delegate = self
        
        //设置导航栏
        title = "登录新浪微博"
        //设置导航栏左侧按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", target: self, actionMethod: #selector(back), isBack: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", target: self, actionMethod: #selector(autoFill))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //1: 加载授权页面
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(WBAppKey)&redirect_uri=\(WBRedirectURI)"
        guard let url = URL(string: urlString) else {
            return
        }
        //2: 建立请求
        let request = URLRequest(url: url)
        //3: 加载请求
        webView.loadRequest(request)
    }
    
    //MARK - 监听返回方法,关闭UI界面
    @objc private func back(){
        SVProgressHUD.dismiss()
        //因为是 present 进来的，所以用dismiss
        dismiss(animated: true, completion: nil)
    }
    
    //MARK - 自动填充用户名和密码, webView的注入, 直接通过 js 修改 本地浏览器中缓存的页面内容
    //点击登陆按钮, 执行submit()
    @objc private func autoFill(){
        //准备js
        let js = "document.getElementById('userId').value = '18312588609';" + "document.getElementById('passwd').value = 'mark007';"
        
        //让 webView 执行 js
        webView.stringByEvaluatingJavaScript(from: js)
    }
}

//监听webView加载页面的请求
extension WBOAuthViewController : UIWebViewDelegate {
    
    //webView 将要加载页面的请求方法
    /// - parameter webView:          webView
    /// - parameter request:          要加载的请求
    /// - parameter navigationType:   导航类型
    /// - return:                     是否加载request,true表示都加载
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        //print("===加载请求===:\(request.url?.absoluteString)")
        // 加载请求:Optional("http://www.baidu.com/?code=b8e93bf9e4e3a3ac67b366e01dee6eee")
        //> 1: 如果请求地址包含重定向地址:http://www.baidu.com就不加载页面了/否则加载页面
        if request.url?.absoluteString.hasPrefix(WBRedirectURI) == false {//返回的是可选项 true/false/nil,为false表示不是baidu,继续加载页面
            return true
        }
        //> 2: 从http://www.baidu.com回调地址中获取授权码code
        //print("===加载请求===:\(request.url?.query)") //query就是URL中?后面的所有部分
        if request.url?.query?.hasPrefix("code=") == false {//为false表示不包含code,表示授权失败
            print("用户授权失败或己取消授权")
            back()
            return false
        }
        //> 3: 代码走到此处，url中一定有查询字符串并且包含code授权码，从query字符串中取出授权码
        let code = request.url?.query?.substring(from: "code=".endIndex) ?? ""
        print("授权码为: \(code)")
        //> 4: 使用授权码获取AccessToken
        WBNetworkManager.shared.getAccessToken(code: code)
        return false  //false为不加载http://www.baidu.com重定向回调页面
    }
    
    //开始加载页面的请求时，显示进度条
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    //加载完成后，关闭进度条
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}
