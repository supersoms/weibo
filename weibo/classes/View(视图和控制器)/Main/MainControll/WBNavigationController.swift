import UIKit

class WBNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //隐藏默认的 NavigationBar
        navigationBar.isHidden = true
    }
    
    /// 重写push方法，以实现隐藏底部Tabbar5个按钮，所有的push动作都会调用此方法
    ///
    /// - Parameters:
    ///   - viewController: 是被push的控制器，设置它的左侧按钮作为返回按钮
    ///   - animated:
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        //如果不是栈底控制器才需要隐藏
        if children.count > 0{
            //隐藏底部的Tabbar
            viewController.hidesBottomBarWhenPushed = true
            
            var title = "返回"
            //判断控制器的级数,只有一个子控制器时，显示第一个控制器的标题
            if children.count == 1{
                title = children.first?.title ?? "返回"
            }
            
            //判断控制器的类型,然后设置返回按钮,设置左侧按钮作为返回按钮
            if let vc = viewController as? WBBaseViewController{
                vc.navItem.leftBarButtonItem = UIBarButtonItem(title: title, target: self, actionMethod: #selector(back), isBack: true)
            }
        }
        super.pushViewController(viewController, animated: true)
    }
    
    //返回到上一级控制器
    @objc private func back(){
        popViewController(animated: true)
    }
}
