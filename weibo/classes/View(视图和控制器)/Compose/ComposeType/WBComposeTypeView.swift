import UIKit

/// 撰写微博类型视图
class WBComposeTypeView: UIView {

    class func composeTypeView() -> WBComposeTypeView {
        let nib = UINib(nibName: "WBComposeTypeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBComposeTypeView
        //因 XIB 加载，默认的大小是600*600，所以要设置 v.frame
        v.frame = UIScreen.main.bounds
        return v
    }
    
    //显示当前视图
    func show(){
        //>1: 将当前视图添加到 根视图控制器 的 view
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else { //拿到根视图控制器(tableBarControll)
            return
        }
        
        //>2: 添加视图
        vc.view.addSubview(self)
        
        
        
    }
}
