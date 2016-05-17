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
    
    var client: BambooClient?
    
    var results = [Result]()
    
    private let repository = ServerRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.server = self.repository.get()
        self.client = BambooClient(NSURL(string: (self.server?.location)!)!, username: (self.server?.username)!, password: (self.server?.password)!)
        self.refreshControl?.addTarget(self, action: #selector(DashboardViewController.refresh(_:)), forControlEvents: .ValueChanged)
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        self.client?.result() {
            (error, results) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if let error = error {
                    self.alert(error)
                } else if let results = results {
                    let failed = results.filter() { element -> Bool in element.state == .Failed }.count
                    if failed > 0 {
                        self.tabBarItem.badgeValue = String(failed)
                    }
                    self.results = results
                    self.tableView.reloadData()
                }
            }
        }
        sender.endRefreshing()
    }
    
    private func groupByPlan(array: [Result]) -> [String: [Result]] {
        var dictionary = [String: [Result]]()
        for element in array {
            let key = element.plan.shortName
            var array: [Result]? = dictionary[key]
            
            if (array == nil) {
                array = [Result]()
            }
            
            array!.append(element)
            dictionary[key] = array!
        }
        
        return dictionary
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.refresh(self.refreshControl!)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")!
        let result = self.results[indexPath.row]
        cell.textLabel?.text = result.plan.shortName
        cell.detailTextLabel?.text = result.key
        cell.imageView?.image = UIImage(named: result.state.rawValue)
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
}
