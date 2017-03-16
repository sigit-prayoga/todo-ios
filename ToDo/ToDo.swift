//
//  ToDo.swift
//  ToDo
//
//  Created by Sigit Prayoga on 3/7/17.
//  Copyright © 2017 Sigit Prayoga. All rights reserved.
//

import Foundation

class ToDo {
    
    
    var title: String
    var done: Bool
    var id: String
    
    public init(title: String, done: Bool, id: String){
        self.title = title
        self.done = done
        self.id = id
    }
    
    public init(title: String)
    {
        self.title = title
        self.done = false
        self.id = ""
    }
    
    public init(json: AnyObject){
        // Get all the props
        self.title = json["todo"] as! String
        self.id = json["id"] as! String
        self.done = json["done"] as! Bool
    }
    
}
