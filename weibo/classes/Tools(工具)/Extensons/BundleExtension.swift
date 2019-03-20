import Foundation

extension Bundle{
    //2: 计算型属性类型于函数，特点：没有参数但有返回值。通过计算型属性返回命名空间字符串，此种方式更常用，更直观明了
    var namespac: String{
        return infoDictionary?["CFBundleName"] as? String ?? ""
    }
}
