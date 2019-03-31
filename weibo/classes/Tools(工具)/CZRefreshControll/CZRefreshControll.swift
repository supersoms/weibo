import UIKit

private let CZRefreshOffset: CGFloat = 60    //刷新状态切换的临界点

/// 下拉刷新控件的3种刷新状态
///
/// - Normal: 普通状态: 什么都不做
/// - Pulling: 超过临界点，如果放手，将要刷新
/// - WillRefresh: 用户超过临界点，并且放手
enum CZRefreshState {
    case Normal
    case Pulling
    case WillRefresh
}

/// 自定义下拉刷新控件，专门负者刷新相关的逻辑处理
class CZRefreshControll: UIControl {

    //下拉刷新控件的父视，下拉刷新控件应该适用于 UITableView / UICollectionView
    private weak var scrollView: UIScrollView?
    
    //懒加载创建刷新视图对象
    private lazy var refreshView: CZRefreshView = CZRefreshView.refreshView()
    
    init(){
        super.init(frame:CGRect())
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //希望用户用xib开发时,需要调用以下代码
        super.init(coder:aDecoder)
        setupUI()
    }
    
    ///willMove 被addSubview方法调用
    ///1:当添加到父视图的时候,newSuperview 是 父视图
    ///2:当父视图被移除时,newSuperview 是 nil
    /// - Parameter newSuperview: newSuperview
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        //判断父视图的类型
        guard let sv = newSuperview as? UIScrollView else {
            //如果执行到这里, 表示父视图 sv = newSuperview 不是 UIScrollView, 直接返回
            return
        }
        scrollView = sv
        
        //KVO监听父视图的 contentOffset,观察者模式
        /***
            参数1: 监听的对象
         **/
        //以下这行代码的意思: scrollView 它要添加一个监听者,由谁来负者监听喃,由self来负者监听,监听 scrollView 的 contentOffset 的变化
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }
    
    //本视图从父视图上删除
    //提示:所有的下拉刷新框架都是监听父视图的 contentOffset
    override func removeFromSuperview() {
        //删除KVO监听,不删除程序会崩溃
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        super.removeFromSuperview()
    }
    
    //所有KVO方法会统一调用此方法
    //在程序中,通常只监听某一个对象的某几个属性,如果属性太多,方法会很乱
    //FIXME: 观察者模式,在不需要的时候,都需要释放,开发者模式在开发中主要有两种
    /***
     1:通知中心
     2:KVO
     **/
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let sv = scrollView else {
            print("scrollView is nil")
            return
        }
        
        //初始高度就是0，-是取反,--得正
        let height = -(sv.contentInset.top + sv.contentOffset.y)
        
        if height < 0 {
            return
        }
        
        //可以根据高度设置刷新控件的frame
        self.frame = CGRect(x: 0, y: -height, width: sv.bounds.width, height: height)
        
        //判断临界点，只需要判断一次
        if sv.isDragging { //用户的手正在拖拽下拉刷新控件
            if height > CZRefreshOffset && (refreshView.refreshState == .Normal) { //如果超过临界点并且它的状态是普通的，设置为正在下拉状态
                print("放手即可刷新")
                refreshView.refreshState = .Pulling
            } else if height <= CZRefreshOffset && (refreshView.refreshState == .Pulling) {
                print("继续使劲...")
                //如果高度小于临界点并且它的状态是下拉，回到普通状态
                refreshView.refreshState = .Normal
            }
        } else {
            //放手 - 判断是否超过临界点
            if refreshView.refreshState == .Pulling {
                print("我要准备开始刷新了")
                beginRefreshing()
            }
        }
    }
    
    ///开始刷新
    func beginRefreshing(){
        print("开始刷新")
        
        //判断父视图
        guard let sv = scrollView else{
            print("sv is nil")
            return
        }
        
        //判断是否正在刷新,如果正在刷新，直接返回
        if refreshView.refreshState == .WillRefresh{
            return
        }
        
        //设置刷新视图的状态
        refreshView.refreshState = .WillRefresh
        
        //调整表格的间距,让整个刷新视图能够显示出来
        //解决方法: 修改表格的contentInset
        var inset = sv.contentInset
        inset.top += CZRefreshOffset
        sv.contentInset = inset
    }
    
    ///结束刷新
    func endRefreshing(){
        
    }
}

extension CZRefreshControll{
    
    private func setupUI(){
        backgroundColor = superview?.backgroundColor
        
        // 设置超出边界不显示,让刷新控件默认不显示
        //clipsToBounds = true
        
        // 添加视图对象
        addSubview(refreshView)
        
        //原生自动布局: 设置xib控件的自动布局,需要指定宽高约束,让下拉刷新控件居中
        //提示: iOS程序员一定要会原生自动布局写法,因为如果自己开发框架,不能用任何的自动布局框架
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: refreshView.bounds.width))
        addConstraint(NSLayoutConstraint(item: refreshView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: refreshView.bounds.height))
    }
}
