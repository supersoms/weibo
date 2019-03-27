import UIKit

//新特性视图,在版本更新时,进行新特性的显示
class WBNewFeatureView: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //进入微博
    @IBAction func startStatus() {
        removeFromSuperview()
    }
    
    class func newFeatureView() -> WBNewFeatureView {
        //nibName: WBNewFeatureView 就是指定的xib文件名,xib中需要指定这个nibName
        let nib = UINib(nibName: "WBNewFeatureView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WBNewFeatureView //取0用解包
        v.frame = UIScreen.main.bounds
        return v
    }
    
    override func awakeFromNib() {
        //如果使用自动布局设置的界面，从xib加载默认是600*600大小
        //添加4个图片
        let imageCount = 4
        let rect = UIScreen.main.bounds //因为每张图片都是全屏的
        for i in 0..<imageCount{
            let imageName = "new_feature_\(i+1)"
            let iv = UIImageView(image: UIImage(named: imageName))
            //设置图片控件的大小为全屏
            iv.frame = rect.offsetBy(dx: CGFloat(i) * rect.width, dy: 0)
            scrollView.addSubview(iv)
        }
        
        //指定 scrollView 的属性
        scrollView.contentSize = CGSize(width: CGFloat(imageCount+1) * rect.width, height: rect.height)
        scrollView.bounces = false                          //弹簧效果: 左边不让看见
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false     //不显示垂直滚动指示器
        scrollView.showsHorizontalScrollIndicator = false   //不显示水平滚动指示器
        
        //设置代理,监听scrollView的滚动事件
        scrollView.delegate = self
        
        //默认不显示按钮，最后一张图片时显示
        startButton.isHidden = true
    }
}

extension WBNewFeatureView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       
        //1: 滚动到最后一屏,删除视图
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        //2: 判断是否是最后一页,当page为4时,表示最后一屏
        if page == scrollView.subviews.count{
            print("欢迎。。。。")
            removeFromSuperview()
        }
        
        //3: 如果是倒数第2页时,显示进入微博按钮
        startButton.isHidden = (page != scrollView.subviews.count - 1)
        print("当前第\(page)页")
    }
    
    //scrollView 一滚动立马就会调用
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //1: 一旦滚动(稍微动一点)就隐藏按钮
        startButton.isHidden = true
        
        //2: 计算当前的偏移量,是为了设置分页控件
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width + 0.5)
        
        //3: 设置分页控件
        pageControl.currentPage = page
        
        //4: 当滚动到界面的半屏之后,隐藏pageControl
        pageControl.isHidden = (page == scrollView.subviews.count)
        
        //5: 细节优化注意: 需要在xib中将 pageControl 的 User Interaction Enabled 勾支掉
    }
}
