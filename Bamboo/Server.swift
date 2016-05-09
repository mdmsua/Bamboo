//
//  Server.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 06.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import Foundation

class Server: NSObject, NSCoding {
    
    let name: String
    
    let location: String
    
    let username: String
    
    let password: String
    
    init(name: String, location: String, username: String, password: String) {
        self.name = name
        self.location = location
        self.username = username
        self.password = password
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as! String
        let location = aDecoder.decodeObjectForKey("location") as! String
        let username = aDecoder.decodeObjectForKey("username") as! String
        let password = aDecoder.decodeObjectForKey("password") as! String
        self.init(name: name, location: location, username: username, password: password)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(location, forKey: "location")
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(password, forKey: "password")
    }
    
}