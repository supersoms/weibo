import Foundation
import SDWebImage

//微博数据列表视图模型
/*
 使命: 负责微博数据的逻辑处理
 1: 字典转模型
 2: 上拉/下拉刷新数据处理
*/

//上拉刷新最大尝试次数
private let maxPullupTryTimes = 3

class WBStatusListViewModel {
    
    //微博模型数组 懒加载
    lazy var statusList = [WBStatusViewModel]()
    
    //上拉刷新错误次数
    private var pullupErrorTimes = 0
    
    /// 加载首页微博列表数据
    ///
    /// - Parameters:
    ///   - pullup: 是否上拉刷新标记pullup，true表示上拉刷新
    ///   - completion: 完成回调[网络请求是否成功, 是否刷新表格] 当微博数据通过模型转换为数组之后，需要返回给调用者，那此时就要用到闭包
    func loadStatus(pullup: Bool, completion: @escaping (_ success: Bool, _ shouldRefresh: Bool)->()){
        
        //判断是否是上拉刷新，同时检查刷新错误
        if pullup && pullupErrorTimes > maxPullupTryTimes{
            completion(true,false)
            return
        }
        
        //下拉刷新 since_id 如果是上拉刷新，since_id就是0，否则就是下拉刷新，那取出数组中第一条微博的id，如果数组第一条id为nil，值就是0
        let since_id = pullup ? 0 : (statusList.first?.status.id ?? 0) //因first后面带了?号，有可能没有这个id,所以再加个??取0的值
        //上拉刷 max_id 如果不是上拉刷新，那max_id为0就是不用设的意思，否则就是上拉刷新，那就取出数组中最后一条微博的id,如果取出的最后一条微博的id为nil，那值就是0
        let max_id = !pullup ? 0 : (statusList.last?.status.id ?? 0)
        
        WBNetworkManager.shared.statusList(since_id: since_id, max_id: max_id) { (list, isSuccess) in
            
            //0.先判断网络请求是否成功
            if !isSuccess {
                //网络请求失败,直接回调返回
                completion(false,false)
                return
            }
            
            //1.定义结果可变数组
            var array = [WBStatusViewModel]()
            
            //2.遍历返回的字典数组，字典转模型 -> 视图模型，将视图模型添加到数组
            for dict in list ?? [] {
                
                //2.1 创建微博模型
                let status = WBStatus()
                
                //2.2 使用字典设置模型数据
                status.yy_modelSet(with: dict)
                
                //2.3 使用'微博'模型创建'微博视图'模型
                let viewModel = WBStatusViewModel(model: status)
                
                //2.4 将viewModel添加到数组
                array.append(viewModel)
            }
            
            //1: 字典(map)转模型,有可能list为nil没数据，所以用??处理，然后通过 as? [WBStatus] 将array转为[WBStatus]
            //字典转模型就是将json数据映射给类WBStatus.self对象,那WBStatus.self就有数据了
//            guard let array = NSArray.yy_modelArray(with: WBStatus.self, json: list ?? []) as? [WBStatus] else {
//                completion(isSuccess,false)
//                print("array is nil")
//                return
//            }
            
            print("刷新了\(array.count)数据，数据为\(array)")
            
            //2: 拼接数据
            if pullup {
                //> 2.1 上拉刷新结束后，将结果拼接在数组的末尾
                self.statusList += array
            } else {
                //> 2.2 下拉刷新时，应该将数组放在数组最前面
                self.statusList = array + self.statusList
            }
            
            //3: 判断上拉刷新的数据量
            if pullup && array.count == 0 {
                self.pullupErrorTimes += 1
                completion(true,false)
            } else {
                self.cacheSingleImage(list: array,finished: completion)
                //3: 调用闭包告诉调用者成功
                //completion(isSuccess,true)
            }
        }
    }
    
    /// 缓存本次下载微博数据数组中的单张图片,多张图片不用缓存,直接用九宫格显示
    /// 应该缓存完单张图片之后，并且修改过配图的大小之后，再回调，才能够保存表格等比例显示单张图像
    /// - Parameter list: 本次下载的视图模型数组
    private func cacheSingleImage(list: [WBStatusViewModel], finished: @escaping (_ success: Bool, _ shouldRefresh: Bool)->()) {
        
        //TODO 使用调度组监听单张图片缓存实现
        //创建调度组
        let group = DispatchGroup()
        
        //记录数据的长度
        var length = 0
        
        //遍历数组,查找微博数据中有单张图像的进行缓存
        for vm in list{
            //>1: 判断图片数量
            if vm.picUrls?.count != 1 {
                continue
            }
            //>2: 获取图像模型
            guard let pic = vm.picUrls?[0].thumbnail_pic,
                let imageUrl = URL(string: pic) else {
                return
            }
            
            //调度组入组
            group.enter()
            
            //>3: 下载图像
            //>3.1 loadImage 是 SDWebImage 的核心方法
            //>3.2 下载完成之后会自动保存在沙盒中，文件路径是imageUrl的MD5
            //>3.3 如果沙盒中己经存在缓存的图像，后续使用 SDWebImage 通过 url 加载图像，都会加载本地沙盒的图像,不会发起网络请求，同时回调方法一样会调用
            //>3.4 注意点: 如果要缓存的图像累计很大，
            SDWebImageManager.shared().loadImage(with: imageUrl, options: [], progress: nil) { (image, data, error, sdImageCacheType, _, _) in
                
                //将图像转换为二进制数据
                if let image = image,  let data = image.pngData() {
                    length += data.count
                }
                
                print("缓存的图像是: \(image), 长度是: \(length)")
                
                //出组，一定要放在回调的最后一句
                group.leave()
            }
        }
        
        //监听调度组情况
        group.notify(queue: DispatchQueue.main) {
            print("图像缓存完成,长度为: \(length/1024) K")
            //执行闭包回调
            finished(true, true)
        }
    }
}
