//
//  Info.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 08.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import Foundation

class Info {
    
    let version: String
    
    let edition: String
    
    let state: String
    
    init?(_ json: [NSObject: AnyObject]) {
        guard let version = json["version"] as? String else {
            return nil
        }
        guard let edition = json["edition"] as? String else {
            return nil
        }
        guard let state = json["state"] as? String else {
            return nil
        }
        self.version = version
        self.edition = edition
        self.state = state
    }
    
}