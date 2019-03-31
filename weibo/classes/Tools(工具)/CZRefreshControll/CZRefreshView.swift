import UIKit

/// 刷新视图 - 负者刷新相关的UI显示和动画
class CZRefreshView: UIView {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!  //圆圈进度条
    @IBOutlet weak var tipIcon: UIImageView!                //上下拉提示图标
    @IBOutlet weak var tipLabel: UILabel!                   //上下拉提示文字
    
}
