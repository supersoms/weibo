import UIKit

/// 刷新视图 - 负者刷新相关的UI显示和动画
class CZRefreshView: UIView {
    
    var refreshState: CZRefreshState = .Normal              //刷新状态
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!  //圆圈进度条
    @IBOutlet weak var tipIcon: UIImageView!                //上下拉提示图标
    @IBOutlet weak var tipLabel: UILabel!                   //上下拉提示文字
    
    class func refreshView() -> CZRefreshView{
        //将xib布局与当前view绑定在一起,相当于Android中的setContentView(R.layout.main)
        let nib = UINib(nibName: "CZRefreshView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! CZRefreshView
    }
}
