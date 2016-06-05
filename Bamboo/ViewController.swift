//
//  ViewController.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 06.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    private let repository = ServerRepository()
    
    private var servers = [Server]()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.servers = self.repository.load()
        self.tableView.reloadData()
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
        cell.textLabel?.text = server.name
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tabBar" {
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)
            let index = indexPath?.row
            let server = self.servers[index!]
            self.repository.set(server)
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let update = UITableViewRowAction(style: .Normal, title: "Update", handler: self.update)
        let delete = UITableViewRowAction(style: .Default, title: "Delete", handler: self.delete)
        return [delete, update]
    }
    
    private func update(action: UITableViewRowAction, indexPath: NSIndexPath) {
        
    }
    
    private func delete(action: UITableViewRowAction, indexPath: NSIndexPath) {
        self.servers.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        self.repository.save(self.servers)
    }
}

