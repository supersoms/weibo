import UIKit

//APP欢迎页视图,没有新版本时,显示欢迎页,加载XIB
class WBWecomeView: UIView {

    class func wecomeView() -> WBWecomeView {
        let nib = UINib(nibName: "WBWecomeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBWecomeView
        //从xib加载的视图,默认是600*600的,所以需要指定为屏幕(全屏)大小
        v.frame = UIScreen.main.bounds
        return v
    }
}
