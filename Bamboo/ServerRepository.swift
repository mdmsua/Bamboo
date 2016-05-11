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
    
    private let all = "servers"
    
    private let one = "server"
    
    func load() -> [Server] {
        if let decoded = self.userDefaults.objectForKey(all) as? NSData {
            if let servers = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as? [Server] {
                return servers
            }
        }
        return [Server]()
    }
    
    func save(servers: [Server]) {
        let encoded = NSKeyedArchiver.archivedDataWithRootObject(servers)
        userDefaults.setObject(encoded, forKey: all)
        userDefaults.synchronize()
    }
    
    func get() -> Server? {
        if let decoded = self.userDefaults.objectForKey(one) as? NSData {
            if let server = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as? Server {
                return server
            }
        }
        return nil
    }
    
    func set(server: Server) {
        let encoded = NSKeyedArchiver.archivedDataWithRootObject(server)
        userDefaults.setObject(encoded, forKey: one)
        userDefaults.synchronize()
    }
    
    func add(server: Server) {
        var servers = self.load()
        servers.append(server)
        self.save(servers)
    }
    
}