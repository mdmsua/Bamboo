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
            let failed = self.results.filter() {
                element -> Bool in element.state == .Failed
            }.count
            if failed > 0 {
                self.tabBarItem.badgeValue = String(failed)
            }
            self.tableView.reloadData()
        }
    }

    private var items: [Result] = [Result]() {
        didSet {
            let failed = self.items.filter() {
                element -> Bool in element.state == .Failed
            }.count
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

    private func loadDashboard() {
        self.client = BambooClient(NSURL(string: (self.server?.location)!)!, username: (self.server?.username)!, password: (self.server?.password)!)
        self.refreshControl?.addTarget(self, action: #selector(DashboardViewController.refresh(_:)), forControlEvents: .ValueChanged)
        self.refreshControl?.beginRefreshing()
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.refresh(self.refreshControl!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.server = self.repository.get()
        if server!.biometrics {
            if Biometrics.enabled {
                Biometrics.authenticate("Please use Touch ID to access \(server!.name)") {
                    result in
                    if result == .Success {
                        self.loadDashboard()
                    } else if result == .Fallback {
                        self.askPassword(self.server!) {
                            result in
                            if result {
                                self.loadDashboard()
                            } else {
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }
                }
            } else {
                self.askPassword(server!) {
                    result in
                    if result {
                        self.loadDashboard()
                    } else {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            }
        } else {
            self.loadDashboard()
        }
    }

    private func askPassword(server: Server, result: Bool -> Void) -> Void {
        let passwordAlert = UIAlertController(title: "\(server.name) requires authentication", message: "Enter password for \(server.username)", preferredStyle: .Alert)
        passwordAlert.addTextFieldWithConfigurationHandler {
            textField -> Void in
            textField.secureTextEntry = true
            textField.placeholder = "Password"
        }
        let authorizeAction = UIAlertAction(title: "Authorize", style: .Default) {
            _ -> Void in
            result(passwordAlert.textFields![0].text == server.password)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            _ -> Void in
            result(false)
        }
        passwordAlert.addAction(authorizeAction)
        passwordAlert.addAction(cancelAction)
        self.presentViewController(passwordAlert, animated: true, completion: nil)
    }

    @objc private func refresh(sender: UIRefreshControl) {
        self.results.removeAll()
        self.fetchResults()
        sender.endRefreshing()
    }

    private func groupByPlan(array: [Result]) -> [String:[Result]] {
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
        self.items = self.results.filter {
            $0.plan.name.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString)
        }
    }
    
    deinit {
        self.searchController.view.removeFromSuperview()
    }
}
