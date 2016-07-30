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
    
    let biometrics: Bool
    
    init(name: String, location: String, username: String, password: String, biometrics: Bool) {
        self.name = name
        self.location = location
        self.username = username
        self.password = password
        self.biometrics = biometrics
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as! String
        let location = aDecoder.decodeObjectForKey("location") as! String
        let username = aDecoder.decodeObjectForKey("username") as! String
        let password = aDecoder.decodeObjectForKey("password") as! String
        let biometrics = aDecoder.decodeObjectForKey("biometrics") as? Bool
        self.init(name: name, location: location, username: username, password: password, biometrics: biometrics ?? false)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(location, forKey: "location")
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(password, forKey: "password")
        aCoder.encodeObject(biometrics, forKey: "biometrics")
    }
    
}