//
//  CoreDataStack.swift
//  数据存储学习
//
//  Created by 黄启明 on 2016/10/18.
//  Copyright © 2016年 huatengIOT. All rights reserved.
//

import CoreData

//构建数据持久化栈
class CoreDataStack: NSObject {
    //MARK: - properties
    let context: NSManagedObjectContext
    let coordiantor: NSPersistentStoreCoordinator
    let model: NSManagedObjectModel
    let store: NSPersistentStore?
    
    static func defaultStack() -> CoreDataStack {
        return instance
    }
    
    private static let instance = CoreDataStack()
    
    private override init() {
        //构建托管对象模型
        let bundle = Bundle.main
        let modelURL = bundle.url(forResource: "CoreDataTest", withExtension: "momd")!
        model = NSManagedObjectModel(contentsOf: modelURL)!
        //构建持久化存储助理
        coordiantor = NSPersistentStoreCoordinator(managedObjectModel: model)
        //构建托管对象上下文，并且将助理连接到上下文
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordiantor
        //构建持久化存储
        let manager = FileManager.default
        let urls = manager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = urls.first
        let storeURL = documentsURL?.appendingPathComponent("CoreDataTest")
        store = try! coordiantor.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
    }
    
    func savtContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("save failed")
            }
        }
    }
    
}
