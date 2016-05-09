//
//  ServerRepository.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 09.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import Foundation

class ServerRepository {
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private let key = "servers"
    
    func load() -> [Server] {
        if let decoded = self.userDefaults.objectForKey(key) as? NSData {
            if let servers = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as? [Server] {
                return servers
            }
        }
        return [Server]()
    }
    
    func save(servers: [Server]) {
        let encoded = NSKeyedArchiver.archivedDataWithRootObject(servers)
        userDefaults.setObject(encoded, forKey: key)
        userDefaults.synchronize()
    }
    
    func add(server: Server) {
        var servers = self.load()
        servers.append(server)
        self.save(servers)
    }
    
}