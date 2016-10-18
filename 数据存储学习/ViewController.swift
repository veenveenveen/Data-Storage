//
//  ViewController.swift
//  数据存储学习
//
//  Created by 黄启明 on 2016/10/18.
//  Copyright © 2016年 huatengIOT. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    lazy var documentDirectoryPath: String = {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths.first!
    }()
    
    let refreshInterval: TimeInterval = 10
    let refreshKey = "LastRefreshTime"
    
    var db: OpaquePointer? = nil
    var stmt: OpaquePointer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        directoryTest()
//        fileTest()
//        re()
//        opt()
//        archiveObject()
//        sqliteDatabase()
        coreData()
    }
    
    //Core Data:苹果公司推出的一种数据持久化解决方案 其原理是对SQLite的封装 不需要接触SQL语句 就可以对数据库进行操作
    //托管对象模型： Managed object model
    //持久化存储： Persistent store
    //持久化存储助理： Persistent store coordinator
    //托管对象上下文： Managed object context
    
    //构建持久存储栈
    /*
        1.建立模型文件（导入）
        2.建立CoreDataStack
        3.设置AppDelegate
     */
    /*
        1.如何创建实体
        2.如何插入数据
        3.如何查询数据
        4.如何统计数据
        5.如何修改数据
        6.如何删除数据
     
     */
    func coreData() {
        //1.建立实体
        //2.创建实体的类
        //3.数据操作
//        insertStus()
//        fetchStus()
//        countStus()
//        updateStus()
        deleteStus()
        fetchStus()
    }
    //插入数据
    func insertStus() {
        let str1 = ["a","b","c","d","e","f","g","h","i","j"]
        let str2 = ["01","02","03","04","05","06","07","08","09","10"]
        for i in 0..<100 {
            let sno = "\(1001+i)"
            let name = str1[i/10] + str2[i%10]
            let score = arc4random()%100
            insertSt(sno: sno, name: name, score: Int(score))
        }
        CoreDataStack.defaultStack().savtContext()
    }
    func insertSt(sno: String, name: String, score: Int) {
        //获取上下文
        let context = CoreDataStack.defaultStack().context
        //构建实体对象
        let stu = NSEntityDescription.insertNewObject(forEntityName: "Students", into: context) as! Student
        //设置相关属性
        stu.sno = sno
        stu.name = name
        stu.score = Int32(score)
    }
    //查询数据
    func fetchStus() {
        //获取上下文
        let context = CoreDataStack.defaultStack().context
        //构建抓取的请求
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Students")
        //指定按照学号（sno）升序排列
        let sort = NSSortDescriptor(key: "sno", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        request.sortDescriptors = [sort]
        //构建查询条件
//        request.predicate = NSPredicate(format: "score > 90")
//        request.predicate = NSPredicate(format: "name like 'a*'")
        do {
            let stus = (try context.fetch(request)) as! [Student]
            for stu in stus {
                print("\(stu.sno!),\(stu.name!),\(stu.score)")
            }
        } catch {
            print("Fetch failed ...")
        }
        
    }
    //统计信息
    func countStus() {
        //1.统计分数大于90的人数
//        //获取上下文
//        let context = CoreDataStack.defaultStack().context
//        //构建抓取请求
//        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Students")
//        request.predicate = NSPredicate(format: "score > 90")
//        request.resultType = .countResultType
//        do {
//            let entries = try context.fetch(request)
//            let count = entries.first
//            print("count: \(count!)")
//        } catch {
//            print("Fetch failed ...")
//        }
        //2.计算平均分数
        //获取上下文
        let context = CoreDataStack.defaultStack().context
        //构建抓取请求
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Students")
        request.resultType = .dictionaryResultType//指定返回结果为字典
        //构建表达式
        let desc = NSExpressionDescription()
        desc.name = "AverageScore"
        let args = [NSExpression(forKeyPath: "score")]
        desc.expression = NSExpression(forFunction: "average:", arguments: args)
        desc.expressionResultType = .floatAttributeType//指定返回值类型
        //将求平均值的表达式设置给request的属性
        request.propertiesToFetch = [desc]
        do {
            let entries = try context.fetch(request)
            let result = entries.first as! NSDictionary
            let averageScore = result["AverageScore"]
            print("average: \(averageScore!)")
        } catch  {
            print("fetch failed ...")
        }
    }
    //修改数据
    func updateStus() {
        let context = CoreDataStack.defaultStack().context
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Students")
        request.predicate = NSPredicate(format: "name like 'a*'")
        do {
            let students = (try context.fetch(request)) as! [Student]
            for stu in students {
                stu.score = 100
            }
        } catch {
            print("fetch failed ...")
        }
        //保存
        CoreDataStack.defaultStack().savtContext()
    }
    //删除数据
    func deleteStus() {
        let context = CoreDataStack.defaultStack().context
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Students")
        request.predicate = NSPredicate(format: "score < 60")
        do {
            let students = try context.fetch(request) as! [Student]
            for stu in students {
                context.delete(stu)
            }
        } catch {
            print("delete failed ...")
        }
        CoreDataStack.defaultStack().savtContext()
    }
    
    //SQLite数据库========================
    func sqliteDatabase() {
        //导入SQLite3
        //创建或打开数据库
        creatOrOpenDatebase()
        //创建学生表
        creatTable()
        //插入数据
        insertStudents()
        updateStudent()
        //查询数据
        queryStudents()
        sqlite3_close(db)
    }
    func creatOrOpenDatebase() {
        let path = "\(documentDirectoryPath)/test.sqlite3"
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("creat or open datebase failed ...")
            sqlite3_close(db)
        }
    }
    //创建表
    func creatTable() {
        let str: NSString = "create table if not exists Student(id integer primary key autoincrement, sno text, name text, score integer)"
        let sql = str.utf8String
        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK {
            print("creat table failed ...")
            sqlite3_close(db)
        }
    }
    //插入数据
    func insertStudents() {
        let str1 = ["a","b","c","d","e","f","g","h","i","j"]
        let str2 = ["01","02","03","04","05","06","07","08","09","10"]
        for i in 0..<100 {
            let sno = "\(1001+i)"
            let name = str1[i/10] + str2[i%10]
            let score = arc4random()%100
            insertStu(sno: sno, name: name, score: Int(score))
        }
    }
    func insertStu(sno: String, name: String, score: Int) {
        //准备sql语句
        let str: NSString = "insert into Student(sno, name, score) values(?, ?, ?)"
        let sql = str.utf8String
        //解析sql文本语句
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            print("insert data failed ...")
            sqlite3_close(db)
            return
        }
        //绑定参数
        let c_sno = (sno as NSString).utf8String
        let c_name = (name as NSString).utf8String
        sqlite3_bind_text(stmt, 1, c_sno, -1, nil)
        sqlite3_bind_text(stmt, 2, c_name, -1, nil)
        sqlite3_bind_int(stmt, 3, Int32(score))
        //执行sql语句
        if sqlite3_step(stmt) == SQLITE_ERROR {
            print("insert data failed ...")
            sqlite3_close(db)
        }
        else {
            //释放资源
            sqlite3_finalize(stmt)
        }
    }
    //查询数据
    func queryStudents() {
        let str: NSString = "select sno, name, score from Student where score > 60"
        let sql = str.utf8String
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            print("query data failed ...")
            sqlite3_close(db)
            return
        }
        while sqlite3_step(stmt) == SQLITE_ROW {
            let c_sno = sqlite3_column_text(stmt, 0)
//            let sno = NSString(utf8String: UnsafePointer<Int8>)
            let c_name = sqlite3_column_text(stmt, 1)
//            let name = NSString(utf8String: UnsafePointer(c_name!))
            let score = sqlite3_column_int(stmt, 2)
            print("\(c_sno),\(c_name),\(score)")
        }
    }
    //修改学生数据
    func updateStudent() {
        let str: NSString = "update Student set score = 100 where name like 'a%'"
//        let str: NSString = "delete from Student where score < 60 "    //删除学生数据
        let sql = str.utf8String
        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK  {
            print("update data failed ...")
            sqlite3_close(db)
        }
    }
    
    //编码对象(对象归档与解档)========================
    func archiveObject() {
        //归档操作
        let stu = Student1(sno: "1101", name: "xiaomi", score: 100)
        let path = "\(documentDirectoryPath)/student.data"
        NSKeyedArchiver.archiveRootObject(stu, toFile: path)//归档对象
        
        //解档操作
        let obj = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! Student
        print(obj.name)
        
    }
    
    //属性列表========================
    func opt() {
        optArray()
        optDict()
    }
    func optArray() {
        print("=========>>>Array")
        let namepath = "\(documentDirectoryPath)/names.plist"
        let names: NSArray = ["aaa","bbb","ccc","ddd","eee"]
        names.write(toFile: namepath, atomically: true)
        let entries = NSArray(contentsOfFile: namepath)
        print(entries!)
    }
    func optDict() {
        print("=========>>>Dict")
        let studentpath = "\(documentDirectoryPath)/studets.plist"
        let students: NSDictionary = ["sno":"1101", "name":"xiaomi", "score":100]
        students.write(toFile: studentpath, atomically: true)
        let entries = NSDictionary(contentsOfFile: studentpath)
        print(entries!)
    }
    
    //用户首选项========================
    func re () {
        if shouldRefresh() {
            refresh()
        }
        else {
            print("Load Caches ...")
        }
    }
    
    func refresh() {
        print("refresh ...")
        resetRefreshTime()
    }
    
    func resetRefreshTime() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(Date(), forKey: refreshKey)
        userDefaults.synchronize()
    }
    
    func shouldRefresh() -> Bool {
        let userDefaults = UserDefaults.standard
        let date = userDefaults.object(forKey: refreshKey) as? Date
        if date == nil {
            return true
        }
        else {
            let interval: TimeInterval = Date().timeIntervalSince(date!)
            return (interval > refreshInterval)
        }
    }
    
    //目录测试========================
    func directoryTest() {
        let path = "\(documentDirectoryPath)/Data"
        print(path)
        if !directoryExistAtPath(path: path) {
            creatDirectoryAtPath(path: path)
            _ = directoryExistAtPath(path: path)
            
        }
        if directoryExistAtPath(path: path) {
            deleteDirectoryAtPath(path: path)
            print("delete directory successed ...")
            _ = directoryExistAtPath(path: path)
        }
    }
    //判断目录是否存在
    func directoryExistAtPath(path: String) -> Bool {
        let fileManager = FileManager.default
        let result = fileManager.fileExists(atPath: path)
        if result {
            print("directory exists ...")
        }
        else {
            print("directory not exists ...")
        }
        return result
    }
    //创建新目录
    func creatDirectoryAtPath(path: String) {
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        }
        catch {
            print("creat directory failed ...")
        }
    }
    //删除目录
    func deleteDirectoryAtPath(path: String) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            print("delete directory failed ...")
        }
    }
    
    func getPath() {
        let path = NSHomeDirectory()
        print("Home: \(path)")
        
        let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        print("Document: \(path1!)")
        
        let path2 = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
        print("Library: \(path2!)")
        
        let path3 = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        print("Caches: \(path3!)")
        
        let path4 = NSTemporaryDirectory()
        print("Temp: \(path4)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController {
    //文件测试========================
    func fileTest() {
        let filePath = "\(documentDirectoryPath)/data.txt"
        print(filePath)
        if !fileExistAtPath(path: filePath) {
            creatFileAtPath(path: filePath)
            print("creat file successed ...")
            _ = fileExistAtPath(path: filePath)
        }
        
        if fileExistAtPath(path: filePath) {
            deleteFileAtPath(path: filePath)
            print("delete file successed ...")
            _ = fileExistAtPath(path: filePath)
        }
    }
    //文件是否存在
    func fileExistAtPath(path: String) -> Bool {
        let fileManager = FileManager.default
        let result = fileManager.fileExists(atPath: path)
        if result {
            print("file exists ...")
        }
        else {
            print("file not exists ...")
        }
        return result
    }
    //创建新文件
    func creatFileAtPath(path: String) {
        let fileManager = FileManager.default
        fileManager.createFile(atPath: path, contents: nil, attributes: nil)
    }
    //删除文件
    func deleteFileAtPath(path: String) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            print("delete file failed ...")
        }
    }

}

