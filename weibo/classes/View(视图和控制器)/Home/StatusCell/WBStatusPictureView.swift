import UIKit

/// 微博首页配图视图
class WBStatusPictureView: UIView {
    
    //配图视图的数组
    var urls: [WBStatusPicture]? {
        didSet{
            //1: 隐藏所有的imageView
            for v in subviews {
                 v.isHidden = true
            }
            
            //2: 遍历urls数组，顺序设置图像
            var index = 0
            for url in urls ?? [] {
                
                //2.1 获取对应索引的 imageView
                let iv = subviews[index] as! UIImageView
                
                //2.2 如果是4张图像，进行处理
                if index == 1 && urls?.count == 4 {
                    index += 1 //跳1表示下一张图像在第二行显示
                }
                
                //2.3 加载图像
                iv.cz_setImage(urlString: url.thumbnail_pic, placeholderImage: nil)
                
                //2.4 显示图像,因为上面将所有的图像都隐藏了，所以需要显示
                iv.isHidden = false
                
                index += 1
            }
        }
    }
    
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
        
        //设置背景颜色
        backgroundColor = superview?.backgroundColor
        
        clipsToBounds = true //表示超出边界的内容不显示
        
        let count = 3
        let rect = CGRect(x: 0, y: WBStatusPictureViewOutterMargin, width: WBStatusPictureItemWidth, height: WBStatusPictureItemWidth)
        
        //循环创建9个imageView
        for i in 0..<9 {
            let iv = UIImageView()
            //设置contentMode
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            
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
