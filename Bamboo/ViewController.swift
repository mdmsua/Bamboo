//
//  ViewController.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 06.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UITableViewController {

    private let repository = ServerRepository()

    private var servers = [Server]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        servers = repository.load()
        tableView.reloadData()
        navigationItem.leftBarButtonItem = editButtonItem()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let server = servers[indexPath.row]
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
        if segue.identifier == "create" {
            repository.set(nil)
        } else if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPathForCell(cell)
            let index = indexPath?.row
            let server = servers[index!]
            repository.set(server)
        }
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            servers.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            repository.save(servers)
        }
    }

}

