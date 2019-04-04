import Foundation

//日期格式化器 - 不要频繁的释放和创建，会影响性能
private let dateFormatter = DateFormatter()

extension Date {
    
    /// 计算与当前系统时间的偏差delta秒数的日期字符串
    static func dateString(delta: TimeInterval) -> String{
        let date = Date(timeIntervalSinceNow: delta)
        
        //指定日期格式
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: date)
    }
}
