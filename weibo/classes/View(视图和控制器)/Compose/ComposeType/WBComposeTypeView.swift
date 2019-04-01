import UIKit
import pop

/// 撰写微博类型视图
class WBComposeTypeView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var closeBtnCenterXCons: NSLayoutConstraint!     //关闭按钮约束
    @IBOutlet weak var returnBtnCenterXCons: NSLayoutConstraint!    //返回前一页按钮y约束
    @IBOutlet weak var returnBtn: UIButton!                         //返回按钮

    /// 按钮数据数组
    private let buttonsInfo = [["imageName": "tabbar_compose_idea", "title": "文字", "clsName": "WBComposeViewController"],
                               ["imageName": "tabbar_compose_photo", "title": "照片/视频"],
                               ["imageName": "tabbar_compose_weibo", "title": "长微博"],
                               ["imageName": "tabbar_compose_lbs", "title": "签到"],
                               ["imageName": "tabbar_compose_review", "title": "点评"],
                               ["imageName": "tabbar_compose_more", "title": "更多", "actionName": "clickMore"],
                               ["imageName": "tabbar_compose_friend", "title": "好友圈"],
                               ["imageName": "tabbar_compose_wbcamera", "title": "微博相机"],
                               ["imageName": "tabbar_compose_music", "title": "音乐"],
                               ["imageName": "tabbar_compose_shooting", "title": "拍摄"]]
    
    ///完成回调
    private var completionCallBlock: ((_ clsName: String?)->())?
    
    //关闭视图
    @IBAction func closeBtn() {
        hideButtons()
    }
    
    class func composeTypeView() -> WBComposeTypeView {
        let nib = UINib(nibName: "WBComposeTypeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBComposeTypeView
        //因 XIB 加载，默认的大小是600*600，所以要设置 v.frame
        v.frame = UIScreen.main.bounds
        v.setupUI()
        return v
    }
    
    //显示当前视图
    func show(completion: @escaping (_ clsName: String?)->()){
        
        //>0: 记录闭包,在需要的时候执行
        completionCallBlock = completion
        
        //>1: 将当前视图添加到 根视图控制器 的 view
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else { //拿到根视图控制器(tableBarControll)
            return
        }
        
        //>2: 添加视图
        vc.view.addSubview(self)
        
        //>3: 开始动画
        showCurrentView()
    }
    
    //MARK: 监听方法
    @objc private func clickButton(selectedBtn: WBComposeTypeButton){
        //判断当前显示的视图
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        let v = scrollView.subviews[page]
        
        //遍历取到的视图(里面存放的是button Base view)，然后判断点击的是哪一个按钮，让选中的按钮放大，让未选中的按钮缩小
        for (i,btn) in v.subviews.enumerated(){
            
            //>1: 缩放动画：kPOPViewScaleXY 表示 XY 放大动画
            let scaleAnim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
            
            //如果点击的是当前的按钮，就放大2倍，没有点击的按钮就放大0.2倍
            let scale = (selectedBtn == btn) ? 2 : 0.6
            scaleAnim.toValue = NSValue(cgPoint: CGPoint(x: scale, y: scale))
            
            //设置动画持续时间
            scaleAnim.duration = 0.5
            
            //按钮添加动画
            btn.pop_add(scaleAnim, forKey: nil)
            
            //>2: 渐变动画 - 动画组
            let alphaAnim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            //将所有的按钮都变淡
            alphaAnim?.toValue = 0.2
            alphaAnim?.duration = 0.5
            btn.pop_add(alphaAnim, forKey: nil)
            
            //>3: 监听动画完成,然后当动画完成之后跳转到新的UI界面，就是对应的控制器
            if i == 0{
                alphaAnim?.completionBlock = { (_,_) -> () in
                    //需要执行完成闭包
                    self.completionCallBlock?(selectedBtn.clsName)
                }
            }
        }
    }
    
    /// 点击更多按钮
    @objc private func clickMore(){
        
        //>1: 将scrollView滚动到第二页
        scrollView.setContentOffset(CGPoint(x: scrollView.bounds.width, y: 0), animated: true)
        
        //>2: 处理底部按钮，让两个按钮分开
        returnBtn.isHidden = false
        let margin = scrollView.bounds.width / 6
        closeBtnCenterXCons.constant += margin     //关闭按钮往右移动
        returnBtnCenterXCons.constant -= margin    //返回按钮往左移动
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    
    /// 点击返回按钮
    @IBAction func clickReturn() {
        //>1: 将scrollView滚动到第1页
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        //2: 处理底部按钮，让两个按钮合并
        closeBtnCenterXCons.constant = 0     //关闭按钮恢复
        returnBtnCenterXCons.constant = 0    //返回按钮恢复
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
            self.returnBtn.alpha = 0
        }) { (_) in
            //当动画执行完毕之后再隐藏返回按钮
            self.returnBtn.isHidden = true
             self.returnBtn.alpha = 1
        }
    }
}

// MARK: - 动画方法扩展
private extension WBComposeTypeView {
    
    /// 动画显示当前视图
    private func showCurrentView(){
        //>1: 创建透明度的动画
        let anim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        //视图的透明度从0到1
        anim.fromValue = 0
        anim.toValue = 1
        //持续时间
        anim.duration = 0.25
        
        //>2: 添加到视图
        pop_add(anim, forKey: nil)
        
        showButtons()
    }
    
    /// 弹力动画显示所有的按钮
    private func showButtons(){
        //1: 获取 scrollView 的子视图的第0个视图
        let v = scrollView.subviews[0]
        
        //2: 遍历v中的所有的按钮
        for (i,btn) in v.subviews.enumerated(){
            
            //创建动画
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            
            //设置动画属性
            anim.fromValue = btn.center.x + 350
            anim.toValue = btn.center.y
            
            //设置动画的弹力系数, 取值范围(0-20)数值越大，弹性越大，默认值是4
            anim.springBounciness = 10
            
            //设置动画的弹力速度, 取值范围(0-20)数值越大，弹性越大，默认值是12
            anim.springSpeed = 10
            
            //设置动画启动时间,可以看到让每个按钮一起慢慢的向上弹的效果
            anim.beginTime = CACurrentMediaTime() + CFTimeInterval(i) * 0.025
            
            //添加动画
            btn.pop_add(anim, forKey: nil)
        }
    }
    
    //MARK: - 消除动画
    /// 隐藏按钮动画
    private func hideButtons(){
        
        //根据 contentOffset 判断当前显示的子视图
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        let v = scrollView.subviews[page]
        
        //遍历v中的所有按钮
        for (i, btn) in v.subviews.enumerated() {
            
            //创建衰减动画
            let anim: POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            
            //设置动画属性
            anim.fromValue = btn.center.y
            anim.toValue = btn.center.y + 350
            
            //设置时间
            anim.beginTime = CACurrentMediaTime() + CFTimeInterval(v.subviews.count - i) * 0.025
            
            //添加动画
            btn.layer.pop_add(anim, forKey: nil)
            
            //监听第0个按钮的动画，它是最后一个执行的动画
            if i == 0{
                anim.completionBlock = { (_,_) ->() in
                    self.hideCurrentView()
                }
            }
        }
    }
    
    /// 隐藏当前视图
    private func hideCurrentView(){
        //>1: 创建透明度的动画
        let anim: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        //视图的透明度从1到0
        anim.fromValue = 1
        anim.toValue = 0
        //持续时间
        anim.duration = 0.25
        
        //>2: 添加到视图
        pop_add(anim, forKey: nil)
        
        //>3: 添加完成监听方法,当pop完成之后的回调
        anim.completionBlock = { (_,_) ->() in
            self.removeFromSuperview()
        }
    }
}

private extension WBComposeTypeView {
    
    func setupUI() {
        
        //1: 强行更新布局，用于拿到 scrollView 的大小，如果不调用 layoutIfNeeded 是拿不到 scrollView 的大小的
        layoutIfNeeded()
        
        //2: 拿到 scrollView 的大小
        let rect = scrollView.bounds
        let width = scrollView.bounds.width
        for i in 0..<2 {
            
            //3: 向 scrollView 添加视图
            let v = UIView(frame: rect.offsetBy(dx: CGFloat(i) * width, dy: 0))
            
            //4: 向视图添加按钮
            addButtons(v: v, idx: i * 6)
            
            //5: 将视图添加到 scrollView
            scrollView.addSubview(v)
        }
        
        //设置scrollView, 这样才能让scrollView进行滚动
        scrollView.contentSize = CGSize(width: 2 * width, height: 0)
        scrollView.showsHorizontalScrollIndicator = false //在xib中设置也可以
        scrollView.showsHorizontalScrollIndicator = false //在xib中设置也可以
        scrollView.bounces = false
        scrollView.isScrollEnabled = false                //禁用滚动
    }
    
    /// 向v中添加按钮,按钮的数组索引从 idx 开始
    func addButtons(v: UIView, idx: Int) {
        //1: 从idx开始,添加6个按钮
        let count = 6
        
        for i in idx..<(idx + count) {
            
            if i >= buttonsInfo.count{
                break
            }
            
            //从数组中获取图片名称和title
            let dict = buttonsInfo[i]
            guard let imageName = dict["imageName"], let title = dict["title"] else {
                continue
            }

            //创建按钮
            let btn = WBComposeTypeButton.composeTypeButton(imageName: imageName, title: title)
            
            //将按钮添加到视图
            v.addSubview(btn)
            
            //为 更多按钮 添加监听方法，从字典里面取 actionName , if let就是判断不为空的守护
            if let actionName = dict["actionName"] {
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            } else {
                btn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
            }
            
            //设置要展现的类名
            btn.clsName = dict["clsName"]
        }
        
        //2: 布局按钮
        //2.1 准备常量
        let btnSize = CGSize(width: 100, height: 100)
        let margin = (v.bounds.size.width - 3 * btnSize.width) / 4
        for (i,btn) in v.subviews.enumerated() {
            let y: CGFloat = (i > 2) ? (v.bounds.height - btnSize.height) : 0
            let col = i % 3
            let x = CGFloat(col + 1) * margin + CGFloat(col) * btnSize.width
            btn.frame = CGRect(x: x, y: y, width: btnSize.width, height: btnSize.height)
        }
    }
}
