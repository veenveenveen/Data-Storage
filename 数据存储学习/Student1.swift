//
//  Student.swift
//  数据存储学习
//
//  Created by 黄启明 on 2016/10/18.
//  Copyright © 2016年 huatengIOT. All rights reserved.
//

import UIKit

class Student1: NSObject, NSCoding {
    
    var sno: String!
    var name: String!
    var score: Int!
    
    init(sno: String, name: String, score: Int) {
        self.sno = sno
        self.name = name
        self.score = score
    }
    
    //编码的时候调用
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sno, forKey: "sno")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(score, forKey: "score")
    }
    //解码的时候调用
    
    required init?(coder aDecoder: NSCoder) {
        sno = aDecoder.decodeObject(forKey: "sno") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        score = aDecoder.decodeObject(forKey: "score") as! Int
    }
}
