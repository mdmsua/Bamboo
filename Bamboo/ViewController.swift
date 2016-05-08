//
//  ViewController.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 06.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    private var servers = [Server]()
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let decoded = self.userDefaults.objectForKey("servers") as? NSData {
            servers = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! [Server]
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.servers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let server = self.servers[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("server")! as UITableViewCell
        cell.textLabel?.text = server.Location
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

