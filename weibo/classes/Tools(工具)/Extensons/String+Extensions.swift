import UIKit

extension String {
    
    /// 从当前字符串中提取链接和文本
    ///
    /// - Returns: 在swift中通过元组，可以同时返回多个值
    func cz_href() -> (link: String, text: String)? {
        //1: 匹配方案
        let pattern = "<a href=\"(.*?)\".*?>(.*?)</a>"
        
        //2: 创建正则表达式,并且匹配第一项
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []),
            let result = regx.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.characters.count)) else {
            return nil
        }
        
        //3: 获取结果
        let link = (self as NSString).substring(with: result.range(at: 1)) //1表示: 取第1个圆括号的匹配内容
        let text = (self as NSString).substring(with: result.range(at: 2))  //2表示: 取第2个圆括号的匹配内容
        
        print("获取的结果为: \(link)+---+\(text)")
        
        return (link, text)
    }
}
