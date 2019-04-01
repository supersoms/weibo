import UIKit

//UIControl 内l置了 touchupInside 事件响应
class WBComposeTypeButton: UIControl {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    /// 点击按钮要展现控制器的类名
    var clsName:String?
    
    /// 按钮布局加载对应的 xib 布局，使用图片名称/标题创建按钮
    class func composeTypeButton(imageName: String, title: String) -> WBComposeTypeButton {
        let nib = UINib(nibName: "WBComposeTypeButton", bundle: nil)
        let buttonBaseLayoutView = nib.instantiate(withOwner: nil, options: nil)[0] as! WBComposeTypeButton
        buttonBaseLayoutView.imageView.image = UIImage(named: imageName)
        buttonBaseLayoutView.titleLabel.text = title
        return buttonBaseLayoutView
    }
    
}
