import Foundation
import FMDB

private let maxDBCacheTime = -5 * 24 * 60 * 60 //数据库数据缓存时间为5天前,(-号表示从当前时间往前算，去掉-号表示加5天),以秒为时间
//private let maxDBCacheTime = -60                 //用于测试，-60表示一分钟前

/// SQLite管理器
/***
 1: 数据库本质上就是保存在沙盒中的一个文件，首先需要创建并打开数据库
 2: 创建数据表
 3: 增删改查
 开发数据库功能时，首先一定要在Navicat中测试SQL的正确性
 **/
class SQLiteManager {
    
    //创建数据库管理器单例对象
    static let shared = SQLiteManager()
    
    //数据库队列
    let queue: FMDatabaseQueue
    
    private init() {
        //建立在单例里面，要用FMDatabaseQueue，当单独执行数据库操作时用inDatabase(执行查询操作)，作批量数据操用时用inTransation(以事务的方式执行数据操作)
        //在此，我们是做批量数据操作
        
        let dbName = "status.db"
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path = (path as NSString).appendingPathComponent(dbName)
        print("数据库的路径: \(path)")
        //1: 创建数据库队列,同时创建或者打开数据库
        queue = FMDatabaseQueue(path: path)!
        
        //2: 打开数据表
        createTabel()
        
        //注册监听应用程序进入后台事件的通知，就是点击Home键进入后台事件
        NotificationCenter.default.addObserver(self, selector: #selector(automaticClearDBCache), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        //注销应用程序进入后台事件的通知
        NotificationCenter.default.removeObserver(self)
    }
    
    //实现自动清理缓存功能
    /***
     注意细节:
     // - 当SQLite的数据不断的增加数据，数据库文件的大小，会不断的增加
     // - 但是: 如果删除了数据，数据库的大小不会变小
     // - 如果要变小，可以通过如下做法:
     /// 1> 将数据库文件复制一个新的副本，status.db.old
     /// 2> 新建一个空的数据库文件
     /// 3> 自己编写SQL,从old表中将所有的数据读出写入到新的数据库中!
     **/
    @objc func automaticClearDBCache(){
        let dateString = Date.dateString(delta: TimeInterval(maxDBCacheTime))
        
        //准备SQL
        let sql = "DELETE FROM T_status WHERE createTime < ?;"
        
        //执行SQL
        queue.inDatabase { (db) in
            if db.executeUpdate(sql, withArgumentsIn: [dateString]) == true {
                print("删除了\(db.changes)条记录") //FMDB如果是自增长ID用lastInsertRowId,如果要删除和修改行数:用changes
            }
        }
    }
}

// MARK: - 创建数据表以及其他私有方法
extension SQLiteManager {
    
    /// 查询数据
    ///
    /// - Parameter sql: sql语句
    /// - Returns: 返回字典数组
    func selectData(sql:String) -> [[String:Any]] {
        //因查询数据不会更改数据，所以这里就用 inDatabase 即可，不用 inTransaction
        var array = [[String:Any]]()
        
        queue.inDatabase { (db) in
            guard let result = db.executeQuery(sql, withArgumentsIn: []) else {
                print("查询的结果为空!")
                return
            }
            //逐行 - 遍历结果集合
            while result.next() {
                
                //1: 列数
                let colCount = result.columnCount
                
                //2: 遍历所有列
                for col in 0..<colCount {
                    //name就是列名,value就是列名地应的值
                    guard let name = result.columnName(for: col),
                        let value = result.object(forColumnIndex: col) else {
                            return
                    }
                    array.append([name:value])
                }
            }
        }
        return array
    }
    
    //创建微博表
    func createTabel(){
        //第1步: 准备sql
        guard let path = Bundle.main.path(forResource: "status.sql", ofType: nil),
            let sql = try? String(contentsOfFile: path) else {
            print("sql path is nil")
            return
        }
        
        //第2步: 执行sql, FMDB的内部，它是串行队列，同步执行的
        queue.inDatabase { (db) in
            //只有在创表的时候，使用executeStatements执行多条语句，可以一次创建多个数据表
            //在执行增删改的时候，一定不要使用executeStatements方法，否则有可能会有sql注入的bug
            if db.executeStatements(sql) == true { //执行多条sql
                print("创建表成功!")
            } else {
                print("创建表想失败!")
            }
        }
    }
}

// MARK: - 微博数据操作
extension SQLiteManager{
    
    /// 新增或者修改微博数据，微博数据在刷新的时候，可能会出现重叠
    ///
    /// - Parameters:
    ///   - userId: 当前登录用户的id
    ///   - array: 当前从网络获取的微博字典的数组
    func updateStatus(userId: String, array:[[String: Any]]){
        //1: 准备sql
        /***
         statusId:  要保存的微博代号
         userId:    当前登录用户的id
         status:    完整微博字典的json二进制数据
         **/
        let sql = "INSERT OR REPLACE into T_status (statusId,userId,status) VALUES (?,?,?)"
        
        //2: 执行sql,多条数据时用 inTransaction，表示开启了事务，事务是为了保证数据的一致性，一旦失败可以回滚数据到初始状态
        /***
         rollBack: 可以回滚，bool的指针
         **/
        queue.inTransaction { (db, rollBack) in
            //遍历字典数组，逐条插入到 T_status 数据表中
            for dict in array {
                //从字典中获取statusId / 将字典序列化成二进制数据
                guard let statusId = dict["idstr"] as? String,
                    let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
                    //如果 statusId 和 jsonData 都是为nil，继续循环拿数据
                    continue
                }
                //执行sql
                if db.executeUpdate(sql, withArgumentsIn: [statusId,userId,jsonData]) == false {
                    //FIXME: 如果结果为false,需要回滚
                    rollBack.pointee = true
                    break
                }
            }
        }
    }
    
    /// 分页从数据库加载微博数据数组
    ///
    /// - Parameters:
    ///   - userId: 当前登录的用户账户
    ///   - since_id: 返回ID比since_id大的微博
    ///   - max_id: 返回ID小于max_id的微博
    /// - Returns: 微博的字典的数组,将数据库中 status 字断对应的二进制数据反序列化生成字典
    func laodStatus(userId:String, since_id: Int64 = 0, max_id: Int64 = 0) -> [[String : Any]] {
        
        //1: 准备sql
        var sql = "SELECT * from T_status WHERE userId = \(userId) \n"
        if since_id > 0 { //下拉刷新
            sql += "AND statusId > \(since_id) \n"
        } else if max_id > 0 {//上拉刷新
            sql += "AND statusId < \(max_id) \n"
        }
        sql += "ORDER BY statusId DESC LIMIT 20;"
        print("=====>"+sql)
        
        //2: 执行sql
        let result = selectData(sql: sql)
        
        //3: 遍历数组，将数组中的status反序列化 ->字典数组
        var array = [[String : Any]]()
        for dict in result {
            guard let status =  dict["status"] as? Data,
            //JSONSerialization.json 反序列化
            let json = try? JSONSerialization.jsonObject(with: status, options: []) as? [String : Any] else {
                continue
            }
            array.append(json ?? [:])
        }
        return array
    }
}
