//
//  Student+CoreDataProperties.swift
//  数据存储学习
//
//  Created by 黄启明 on 2016/10/18.
//  Copyright © 2016年 huatengIOT. All rights reserved.
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Students");
    }

    @NSManaged public var sno: String?
    @NSManaged public var name: String?
    @NSManaged public var score: Int32

}
