import UIKit

/// 自定义下拉刷新控件
class CZRefreshControll: UIControl {

    //下拉刷新控件的父视，下拉刷新控件应该适用于 UITableView / UICollectionView
    private weak var scrollView: UIScrollView?
    
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
    
    //所有KVO方法会统一调用此方法
    //在程序中,通常只监听某一个对象的某几个属性,如果属性太多,方法会很乱
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let sv = scrollView else {
            print("scrollView is nil")
            return
        }
        
        //初始高度就是0，-是取反,--得正
        let height = -(sv.contentInset.top + sv.contentOffset.y)
        
        //可以根据高度设置刷新控件的frame
        self.frame = CGRect(x: 0, y: -height, width: sv.bounds.width, height: height)
    }
    
    ///开始刷新
    func beginRefreshing(){
        
    }
    
    ///结束刷新
    func endRefreshing(){
        
    }
}

extension CZRefreshControll{
    
    private func setupUI(){
        backgroundColor = UIColor.orange
    }
}
