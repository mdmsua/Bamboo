//
//  Result.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 11.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import Foundation

class Plan {
    
    let key: String
    
    let name: String
    
    init?(_ json: [NSObject: AnyObject]) {
        guard let key = json["key"] as? String else {
            return nil
        }
        guard let name = json["name"] as? String else {
            return nil
        }
        self.key = key
        self.name = name
    }
    
}