import UIKit

extension UIBarButtonItem{
    
    ///抽取便利构造函数, 创建UIBarButtonItem, 必须自定义Button, 用于设置'好友'|'下一个'等按钮按下时文字的高亮颜色效果
    /// - parameter isBack: 是否是返回按钮，如果是加上剪头
    convenience init(title: String, fontSize: CGFloat = 16, target: Any?, actionMethod: Selector, isBack: Bool = false) {
        //swift 调用 OC 返回 instancetype 的方法，判断不出是否可选，所以btn必须指定类型为UIButton
        let btn: UIButton = UIButton.cz_textButton(title, fontSize: fontSize, normalColor: UIColor.darkGray, highlightedColor: UIColor.orange)
        if isBack {
            let imageName = "navigationbar_back_withtext"
            btn.setImage(UIImage(named: imageName), for: UIControl.State(rawValue: 0))
            btn.setImage(UIImage(named: imageName+"_highlighted"), for: .highlighted)
            btn.sizeToFit() //自动调整字体的大小
        }
        btn.addTarget(target, action: actionMethod, for: .touchUpInside)
        //因为是便利构造函数，必须调用self.init()
        self.init(customView: btn)
    }
}
