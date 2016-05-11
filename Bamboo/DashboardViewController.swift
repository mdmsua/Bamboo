//
//  ServerPageViewController.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 09.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import UIKit

class DashboardViewController: UITableViewController {
    
    var server: Server?
    
    var client: RestClient?
    
    var results = [Result]()
    
    private let repository = ServerRepository()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.server = self.repository.get()
        client = RestClient(NSURL(string: (self.server?.location)!)!, username: (self.server?.username)!, password: (self.server?.password)!)
        self.client?.result() {
            (error, results) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.results = results!
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("result")!
        let result = self.results[indexPath.row]
        cell.textLabel?.text = result.key
        cell.imageView?.image = UIImage(named: result.state == .Successful ? "Ok" : "Cancel")
        return cell
    }
}
