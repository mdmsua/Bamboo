//
//  Page.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 21.06.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import Foundation

class Page<T:Parsable> {
    
    let size: Int
    
    let offset: Int
    
    let limit: Int
    
    let results: [T]
    
    var current: Int {
        return self.offset / self.limit
    }
    
    var hasMore: Bool {
        return self.size > self.offset + self.limit
    }
    
    var next: String? {
        return self.hasMore ? "max-result=\(self.limit)&start-index=\(self.offset + self.limit)" : nil
    }
    
    init?(_ json: [String: AnyObject]) {
        guard let results = json["results"] else {
            return nil
        }
        guard let size = results["size"] as? Int else {
            return nil
        }
        guard let offset = results["start-index"] as? Int else {
            return nil
        }
        guard let limit = results["max-result"] as? Int else {
            return nil
        }
        guard let result = results["result"] as? [[String: AnyObject]] else {
            return nil
        }
        
        self.size = size
        self.offset = offset
        self.limit = limit
        self.results = result.filter({ x in T(x) != nil }).map { T($0)! }
    }

}
