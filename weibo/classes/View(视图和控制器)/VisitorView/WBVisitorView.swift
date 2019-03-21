import UIKit

///访客视图
class WBVisitorView: UIView {

    //访客视图的信息字典属性
    // - parameter dict:[imageName / message]
    // 提示：如果是首页 imageName ==""
    var visitorInfoDict: [String:String]? {
        didSet {
            guard let imageName = visitorInfoDict?["imageName"], let message = visitorInfoDict?["message"] else{
                print("imageName message is nil")
                return
            }
            //设置信息
            tipLabel.text = message
            //设置图像,首页不需要设置
            if imageName == "" {
                startAnimation()
                return
            }
            iconView.image = UIImage(named: imageName)
            //其它控制器的访客视图不需要显示小房子和遮罩，需要隐藏
            hoursIconView.isHidden = true
            maskIconView.isHidden = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //旋转图标动画,只有首页需要旋转动画
    private func startAnimation(){
        let anim = CABasicAnimation(keyPath: "transform.rotation") //transform.rotation 表示旋转
        anim.toValue = 2 * M_PI
        anim.repeatCount = MAXFLOAT //不停的旋转
        anim.duration = 15 //选择一圈持续的时间
        
        //当动画完成之后不删除，不然再从别的界面切换过来时，动画会己停止
        //> - 1: 当iconView被销毁，动画也会跟随一起销毁
        //> - 2: 经常用在循环播放动画上
        anim.isRemovedOnCompletion = false
        
        //动画设置好了之后，将动画添加到图层
        iconView.layer.add(anim, forKey: nil)
    }
    
    ///MARK - 私有控件
    //图像控件
    private lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
    
    //遮罩图像效果
    private lazy var maskIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
    
    //小房子
    private lazy var hoursIconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
    
    //提示标签
    private lazy var tipLabel: UILabel = UILabel.cz_label(withText: "关注一些人，回这里看看有什么惊喜", fontSize: 14, color: UIColor.darkGray)
    
    //注册按钮
    lazy var registerBtn: UIButton = UIButton.cz_textButton("注册", fontSize: 16, normalColor: UIColor.orange, highlightedColor: UIColor.black, backgroundImageName: "common_button_white_disable")
    
    //登陆按钮
    lazy var loginBtn: UIButton = UIButton.cz_textButton("登陆", fontSize: 16, normalColor: UIColor.darkGray, highlightedColor: UIColor.black, backgroundImageName: "common_button_white_disable")
}

/// MARK - 设置界面
extension WBVisitorView{
    func setupUI(){
        backgroundColor = UIColor.cz_color(withHex: 0xEDEDED)
        
        //1. 添加控件
        addSubview(iconView)
        addSubview(maskIconView)
        addSubview(hoursIconView)
        addSubview(tipLabel)
        addSubview(registerBtn)
        addSubview(loginBtn)
        
        //让tipLabel里面的文字居中显示
        tipLabel.textAlignment = .center
        
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
        //> 设置遮罩,使用VFL,比addConstraint多一个s
        //views: 定义VFL中的控件名称和实际名称映射关系
        //metrics: 定义VFL中()指定的常数映射关系
        let metrics = ["spacing": -35]
        let viewDict = ["maskIconView": maskIconView,"registerBtn": registerBtn]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskIconView]-0-|", options: [], metrics: nil, views: viewDict))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[maskIconView]-(spacing)-[registerBtn]", options: [], metrics: metrics, views: viewDict))
    }
}
