import UIKit

///访客视图
class WBVisitorView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///MARK - 私有控件
    //图像控件
    private lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
    
    //小房子
    private lazy var hoursIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
    
    //提示标签
    private lazy var tipLabel: UILabel = UILabel.cz_label(withText: "关注一些人，回这里看看有什么惊喜", fontSize: 14, color: UIColor.darkGray)
    
    //注册按钮
    private lazy var registerBtn: UIButton = UIButton.cz_textButton("注册", fontSize: 16, normalColor: UIColor.orange, highlightedColor: UIColor.black, backgroundImageName: "common_button_white_disable")
    
    //登陆按钮
    private lazy var loginBtn: UIButton = UIButton.cz_textButton("登陆", fontSize: 16, normalColor: UIColor.darkGray, highlightedColor: UIColor.black, backgroundImageName: "common_button_white_disable")
}

/// MARK - 设置界面
extension WBVisitorView{
    func setupUI(){
        backgroundColor = UIColor.white
        
        //1. 添加控件
        addSubview(iconView)
        addSubview(hoursIconView)
        addSubview(tipLabel)
        addSubview(registerBtn)
        addSubview(loginBtn)
        
        //2. 取消autoresizing
        for v in subviews {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let margin = CGFloat(20.0)
        
        //3. 自动布局
        //> 图像视图
        /**
         item: 指定视图
         attribute: 约束关系
         toItem: 参照哪个控件
         attribute: 参属性
         multiplier: 乘积
         constant: 约束数值
         */
        addConstraint(NSLayoutConstraint(item: iconView,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: iconView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -50))
        //> 小房子
        addConstraint(NSLayoutConstraint(item: hoursIconView, attribute: .centerX, relatedBy: .equal, toItem: iconView, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: hoursIconView, attribute: .centerY, relatedBy: .equal, toItem: iconView, attribute: .centerY, multiplier: 1.0, constant: 0))
        //> 提示标签 水平中心对齐
        addConstraint(NSLayoutConstraint(item: tipLabel, attribute: .centerX, relatedBy: .equal, toItem: iconView, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: tipLabel, attribute: .top, relatedBy: .equal, toItem: iconView, attribute: .bottom,
                                         multiplier: 1.0, constant: margin))
        //设置tipLabel的宽度为230
         addConstraint(NSLayoutConstraint(item: tipLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                          multiplier: 1.0, constant: 230))
        //> 注册按钮
        addConstraint(NSLayoutConstraint(item: registerBtn, attribute: .left, relatedBy: .equal, toItem: tipLabel, attribute: .left,
                                         multiplier: 1.0, constant: 0))
        //registerBtn控件的顶部参照于tipLabel控件的底部，margin对于Y轴来说，数字越大越往下
        addConstraint(NSLayoutConstraint(item: registerBtn, attribute: .top, relatedBy: .equal, toItem: tipLabel, attribute: .bottom,
                                         multiplier: 1.0, constant: margin))
        //设置registerBtn的宽度为20
        addConstraint(NSLayoutConstraint(item: registerBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1.0, constant: 60))
        //> 登陆按钮
        addConstraint(NSLayoutConstraint(item: loginBtn, attribute: .right, relatedBy: .equal, toItem: tipLabel, attribute: .right,
                                         multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: loginBtn, attribute: .top, relatedBy: .equal, toItem: tipLabel, attribute: .bottom,
                                         multiplier: 1.0, constant: margin))
        //设置loginBtn的宽度为20
        addConstraint(NSLayoutConstraint(item: loginBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1.0, constant: 60))
    }
}
