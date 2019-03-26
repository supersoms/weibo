import UIKit
import SDWebImage

//APP欢迎页视图,没有新版本时,显示欢迎页,通过加载xib来实现
class WBWecomeView: UIView {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var tipLabel: UILabel!               //默认是隐藏的,当动画加载完成之后再显示
    @IBOutlet weak var bottomCons: NSLayoutConstraint!
    
    class func wecomeView() -> WBWecomeView {
        let nib = UINib(nibName: "WBWecomeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBWecomeView //取0用解包
        //从xib加载的视图,默认是 600 * 600 的,因为欢迎界面就是满屏,所以需要指定为屏幕(全屏)大小,指定bounds
        v.frame = UIScreen.main.bounds
        return v
    }
    
    //此方法是自动布局系统更新完成约束后,会自动调用此方法,此方法通常是对子视图布局进行修改
    //override func layoutSubviews() {
        
    //}
    
    //视图被添加到window上,表示视图己经显示
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        //因当前这个视图是使用自动布局来设置的，只是设置了约束
        //-: 当视图被添加到窗口上时，根据父视图的大小来计算约束值，更新控件位置
        //如果控件们的frame还没有计算好，此时调用动画里面的self.layoutIfNeeded()来更新约束时会将所有的约束一起动画，这是不对的,所以要在此处也调用一下self.layoutIfNeeded()
        self.layoutIfNeeded() //layoutIfNeeded会直接按照当前约束直接更新控件位置,执行完之后,控件所在位置就是xib中布局的位置
        
        bottomCons.constant = bounds.size.height - 200 //修改常数,就是将图片置顶
        
        //withDuration: 1.0 表示动画执行1秒，delay: 0 表示动画延迟0秒，usingSpringWithDamping: 0.7 弹力系数为0.7，initialSpringVelocity: 0 初始速度
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
            //执行动画代码，实现自动布局的动画
            //以下代码表示更新约束
            self.layoutIfNeeded()
        }) { (isCompletion) in
            //当上面的动画执行完成之后
            UIView.animate(withDuration: 1.0, animations: {
                self.tipLabel.alpha = 1
            }, completion: { (_) in
                //TODO 此处当显示文字动画完成之后跳转到首页
                self.removeFromSuperview()
            })
        }
    }
    
    //不能在此方法中去设置头像，因为此方法是刚刚从xib的二进制文件将视图加载完成,还没有和代码连线建立起关系,所以开发时千万不要在这个方法中处理UI
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("initWithCoder + \(iconView)")  //打印结果是: iconView为nil
    }
    
    //在此方法中加载用户头像
    override func awakeFromNib() {
        //>1: 获取url
        guard let imageURL = WBNetworkManager.shared.userAccount.avatar_large,let url = URL(string: imageURL) else {
            print("imageURL is nil")
            return
        }
        
        //>2: 设置头像 - 如果网络图片下载失败, 先显示 placeholderImage 占位图片, 如果不指定占位图片, 之前设置的图片会被清空！
        iconView.sd_setImage(with: url, placeholderImage: UIImage(named: "avatar_default_big"))
        
        //>3: 设置图片圆角
        iconView.layer.cornerRadius = iconView.bounds.width * 0.5
        iconView.layer.masksToBounds = true
    }
}
