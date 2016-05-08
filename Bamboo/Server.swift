//
//  Server.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 06.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import Foundation

class Server: NSObject, NSCoding {
    
    let Location: String
    
    let Username: String
    
    let Password: String
    
    init(Location: String, Username: String, Password: String) {
        self.Location = Location
        self.Username = Username
        self.Password = Password
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let location = aDecoder.decodeObjectForKey("location") as! String
        let username = aDecoder.decodeObjectForKey("username") as! String
        let password = aDecoder.decodeObjectForKey("password") as! String
        self.init(Location: location, Username: username, Password: password)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(Location, forKey: "location")
        aCoder.encodeObject(Username, forKey: "username")
        aCoder.encodeObject(Password, forKey: "password")
    }
    
}