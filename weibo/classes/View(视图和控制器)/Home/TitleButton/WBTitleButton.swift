import UIKit

//自定义标题按钮
class WBTitleButton: UIButton {

    //重载构造函数
    //title如果是nil,就显示首页,如果不为nil就显示title和上下剪头图像
    init(title: String?){
        super.init(frame: CGRect())
        
        //>1: 判断title是否为nil
        if title == nil{
            setTitle("首页", for: .normal)
        } else {
            setTitle(title! + " ", for: .normal) //" "表示左边文字与图片中间的间距
            //>2: 设置图像
            setImage(UIImage(named: "navigationbar_arrow_down"), for: .normal) //正常状态为.normal或[]都OK
            setImage(UIImage(named: "navigationbar_arrow_up"), for: .selected) //选中的图标
        }
        
        //>3: 设置字体和颜色
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        setTitleColor(UIColor.darkGray, for: .normal)
        
        //>4: 设置大小
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //利用layoutSubviews方法重新布局子视图，重新调整按钮文字和图像的位置
    override func layoutSubviews() {
        //判断titleLabel和imageView是否同时存在
        guard let titleLabel = titleLabel,let imageView = imageView else{
            return
        }
        
        //最终的效果就是: 文字在左边，图标在右边
        //将titleLabel的x向左移动imageView的宽度，设置titleLabel的位置向左移
        titleLabel.frame = titleLabel.frame.offsetBy(dx: -imageView.bounds.width, dy: 0)
        
        //将imageView的x向右移动titleLable的宽度，设置imageView的位置向右移
        imageView.frame = imageView.frame.offsetBy(dx: titleLabel.bounds.width, dy: 0)
    }
}
