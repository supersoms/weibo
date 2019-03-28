import SDWebImage

extension UIImageView {
    
    /// 隔离 SDWebImage 设置图像函数
    ///
    /// - Parameters:
    ///   - urlString: url
    ///   - placeholderImage: 占位图像
    ///   - isAvater:  是否是头像
    func cz_setImage(urlString: String?, placeholderImage: UIImage?, isAvater: Bool = false){
        guard let urlString = urlString, let url = URL(string: urlString) else {
            print("url is nil")
            //设置占位图
            image = placeholderImage
            return
        }
        
        //[weak self]以防调用以下代码时会出现循环引用，解决循环引用
        sd_setImage(with: url, placeholderImage: placeholderImage, options: [], progress: nil) { [weak self](image, error, type, url) in
            //在此完成回调，- 判断是否是头像，如果是头像处理成圆角
            if isAvater && image != nil{
                self?.image = image?.cz_avatarImage(size: self?.bounds.size)
            }
        }
    }
}

