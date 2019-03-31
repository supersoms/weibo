import UIKit

/// 刷新视图 - 负者刷新相关的UI显示和动画
class CZRefreshView: UIView {
    
    /***
     iOS系统中，UIView封装的旋转动画
     - 默认是顺时针旋转
     - 就近原则
     - 要想实现同方向旋转，需要调整一个非常小的数字(近)
     - 如果想实现360度旋转，需要核心动画CABaseAnimation
     **/
    var refreshState: CZRefreshState = .Normal { //刷新状态
        didSet {
            switch refreshState {
            case .Normal:
                tipIcon.isHidden = false
                indicator.stopAnimating()
                tipLabel.text = "继续使劲拉..."
                UIView.animate(withDuration: 0.25) {
                   self.tipIcon.transform = CGAffineTransform.identity //恢复成初始状态
                }
            case .Pulling:
                tipLabel.text = "放手就刷新..."
                UIView.animate(withDuration: 0.25) {
                    //pi是180度旋转，- 0.001是为了解决顺时针旋转，实现同方向旋转
                    self.tipIcon.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI - 0.001))
                }
            case .WillRefresh:
                tipLabel.text = "正在刷新..."
                //隐藏上下拉提示图标
                tipIcon.isHidden = true
                //显示圆圈进度条
                indicator.startAnimating()
            }
        }
    }
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!  //圆圈进度条
    @IBOutlet weak var tipIcon: UIImageView!                //上下拉提示图标
    @IBOutlet weak var tipLabel: UILabel!                   //上下拉提示文字
    
    class func refreshView() -> CZRefreshView{
        //将xib布局与当前view绑定在一起,相当于Android中的setContentView(R.layout.main)
        let nib = UINib(nibName: "CZRefreshView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! CZRefreshView
    }
}
