//
//  Result.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 11.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import Foundation

class Result {
    
    let plan: Plan
    
    let id: Int
    
    let key: String
    
    let state: State
    
    init?(_ json: [NSObject: AnyObject]) {
        guard let key = json["key"] as? String else {
            return nil
        }
        guard let id = json["id"] as? Int else {
            return nil
        }
        guard let plan = json["plan"] as? [NSObject: AnyObject] else {
            return nil
        }
        guard let state = json["state"] as? String else {
            return nil
        }
        if let plan = Plan(plan) {
            self.plan = plan
        } else {
            return nil
        }
        if let state = State(rawValue: state) {
            self.state = state
        } else {
            return nil
        }
        self.key = key
        self.id = id
    }
    
}

enum State: String {
    case Successful
    case Failed
}