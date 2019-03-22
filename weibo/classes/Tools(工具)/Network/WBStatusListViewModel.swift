import Foundation

//微博数据列表视图模型
/*
 使命: 负责微博数据的处理
 1: 字典转模型
 2: 上拉/下拉刷新数据处理
*/
class WBStatusListViewModel {
    
    //微博模型数组 懒加载
    lazy var statusList = [WBStatus]()
    
    //当微博数据通过模型转换为数组之后，需要返回给调用者，那此时就要用到闭包
    func loadStatus(completion: @escaping (_ success: Bool)->()){
        
        WBNetworkManager.shared.statusList { (list, isSuccess) in
            
            //1: 字典(map)转模型,有可能list为nil没数据，所以用??处理，然后通过 as? [WBStatus] 将array转为[WBStatus]
            guard let array = NSArray.yy_modelArray(with: WBStatus.self, json: list ?? []) as? [WBStatus] else {
                completion(isSuccess)
                print("array is nil")
                return
            }
            
            //2: 拼接数据
            self.statusList += array
            
            //3: 调用闭包告诉调用者成功
            completion(isSuccess)
        }
    }
}
