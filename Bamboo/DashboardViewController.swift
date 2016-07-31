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
            let failed = results.filter() {
                element -> Bool in element.state == .Failed
            }.count
            if failed > 0 {
                tabBarItem.badgeValue = String(failed)
            }
            tableView.reloadData()
        }
    }

    private var items: [Result] = [Result]() {
        didSet {
            let failed = items.filter() {
                element -> Bool in element.state == .Failed
            }.count
            if failed > 0 {
                tabBarItem.badgeValue = String(failed)
            }
            tableView.reloadData()
        }
    }

    private let repository = ServerRepository()

    private let searchController = UISearchController(searchResultsController: nil)

    private var isSeachActive: Bool {
        get {
            return searchController.active && !(searchController.searchBar.text?.isEmpty)!
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = UIView()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        refreshControl?.addTarget(self, action: #selector(loadDashboard), forControlEvents: .ValueChanged)
        definesPresentationContext = true
        server = repository.get()
        if let server = server {
            title = server.name
            client = BambooClient(NSURL(string: (server.location))!, username: server.username, password: server.password)
            if server.biometrics {
                if Biometrics.enabled {
                    Biometrics.authenticate("Access \(server.name) as \(server.username)") {
                        [unowned self] result in
                        dispatch_async(dispatch_get_main_queue()) {
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
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                        }
                    }
                } else {
                    askPassword(server) {
                        [unowned self ]result in
                        if result {
                            self.loadDashboard()
                        } else {
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }
                }
            } else {
                loadDashboard()
            }
        } else {
            navigationController?.popViewControllerAnimated(true)
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
        presentViewController(passwordAlert, animated: true, completion: nil)
    }

    @objc private func loadDashboard() {
        results.removeAll()
        fetchResults(true)
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

    private func fetchResults(refresh: Bool = false) {
        if refresh {
            refreshControl?.beginRefreshing()
        }
        client?.result(page) {
            (error, page) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                [unowned self] in
                if (refresh) {
                    self.refreshControl?.endRefreshing()
                }
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
        if indexPath.row < results.count {
            let result = isSeachActive ? items[indexPath.row] : results[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
            cell.textLabel?.text = result.plan.shortName
            cell.detailTextLabel?.text = result.key
            cell.imageView?.image = UIImage(named: result.state.rawValue)
            return cell
        } else {
            return tableView.dequeueReusableCellWithIdentifier("extra")!
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSeachActive ? items.count : (page != nil && page!.hasMore) ? results.count + 1 : results.count
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.reuseIdentifier == "extra" {
            fetchResults()
        }
    }

    @objc internal func updateSearchResultsForSearchController(searchController: UISearchController) {
        items = results.filter {
            $0.plan.name.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString)
        }
    }
    
    deinit {
        searchController.view.removeFromSuperview()
    }
}
