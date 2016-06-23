//
//  ServerPageViewController.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 09.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import UIKit

class DashboardViewController: UITableViewController, UISearchResultsUpdating {
    
    var server: Server?
    
    var client: BambooClient?
    
    private var page: Page<Result>?
    
    private var results: [Result] = [Result]() {
        didSet {
            let failed = self.results.filter() { element -> Bool in element.state == .Failed }.count
            if failed > 0 {
                self.tabBarItem.badgeValue = String(failed)
            }
            self.tableView.reloadData()
        }
    }
    
    private var items: [Result] = [Result]() {
        didSet {
            let failed = self.items.filter() { element -> Bool in element.state == .Failed }.count
            if failed > 0 {
                self.tabBarItem.badgeValue = String(failed)
            }
            self.tableView.reloadData()
        }
    }
    
    private let repository = ServerRepository()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var isSeachActive: Bool {
        get {
            return self.searchController.active && !(self.searchController.searchBar.text?.isEmpty)!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.server = self.repository.get()
        self.client = BambooClient(NSURL(string: (self.server?.location)!)!, username: (self.server?.username)!, password: (self.server?.password)!)
        self.refreshControl?.addTarget(self, action: #selector(DashboardViewController.refresh(_:)), forControlEvents: .ValueChanged)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        self.results.removeAll()
        self.fetchResults()
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
    
    private func fetchResults() {
        self.client?.result(self.page) {
            (error, page) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if let error = error {
                    self.alert(error)
                } else if let page = page {
                    self.page = page
                    self.results.appendContentsOf(page.results)
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.refresh(self.refreshControl!)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < self.results.count {
            let result = self.isSeachActive ? self.items[indexPath.row] : self.results[indexPath.row]
            let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")!
            cell.textLabel?.text = result.plan.shortName
            cell.detailTextLabel?.text = result.key
            cell.imageView?.image = UIImage(named: result.state.rawValue)
            return cell
        } else {
            return self.tableView.dequeueReusableCellWithIdentifier("extra")!
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isSeachActive ? self.items.count : (self.page != nil && self.page!.hasMore) ? self.results.count + 1 : self.results.count
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.reuseIdentifier == "extra" {
            self.fetchResults()
        }
    }
    
    @objc internal func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.items = self.results.filter { $0.plan.name.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString) }
    }

}
