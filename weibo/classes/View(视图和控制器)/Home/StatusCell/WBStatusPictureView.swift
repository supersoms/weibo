import UIKit

/// 微博首页配图视图
class WBStatusPictureView: UIView {

    @IBOutlet weak var heightCons: NSLayoutConstraint!      //配置的高度

    override func awakeFromNib() {
        setupUI()
    }
}

// MARK: - 设置界面
extension WBStatusPictureView{
    
    //在配图的时候有如下原则
    /**
     1: Cell中所有的控件都是提前准备好
     2: 设置的时候根据数据是否显示
     3: 不要动态的创建控件，不然会影响显示的性能
    */
    private func setupUI(){
        
        clipsToBounds = true //表示超出边界的内容不显示
        
        let count = 3
        let rect = CGRect(x: 0, y: WBStatusPictureViewOutterMargin, width: WBStatusPictureItemWidth, height: WBStatusPictureItemWidth)
        
        //循环创建9个imageView
        for i in 0..<9 {
            let iv = UIImageView()
            iv.backgroundColor = UIColor.red
            //行 --> 对应的是y
            let row = CGFloat(i / count)
            //列 --> 对应的是x
            let col = CGFloat(i % count)
            let xOffset = col * (WBStatusPictureItemWidth + WBStatusPictureViewInnerMargin)
            let yOffset = row * (WBStatusPictureItemWidth + WBStatusPictureViewInnerMargin)
            iv.frame = rect.offsetBy(dx:xOffset , dy: yOffset)
            addSubview(iv)
        }
    }
}
