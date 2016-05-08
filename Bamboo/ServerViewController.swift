//
//  ServerViewController.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 07.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import UIKit

class ServerViewController: UITableViewController {
    
    @IBOutlet private weak var doneButton: UIButton!
    
    @IBOutlet private weak var locationTextField: UITextField!
    
    @IBOutlet private weak var usernameTextField: UITextField!
    
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBAction private func textFieldEditingChanged() {
        doneButton.enabled =
            self.locationTextField.text?.characters.count > 0 &&
            self.usernameTextField.text?.characters.count > 0 &&
            self.passwordTextField.text?.characters.count > 0
    }

    @IBAction func doneButtonClicked(sender: AnyObject) {
        let location = self.locationTextField.text!
        let username = self.usernameTextField.text!
        let password = self.passwordTextField.text!
        let url = NSURL(string: location)!
        let client = RestClient(url, username: username, password: password)
        let overlay = self.presentActivityIndicatorOverlay()
        client.info() {
            (error, info) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                overlay.removeFromSuperview()
                if let error = error {
                    self.alert(error)
                } else if let _ = info {
                    let server = Server(Location: location, Username: username, Password: password)
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    var servers = [Server]()
                    if let decoded = userDefaults.objectForKey("servers") as? NSData {
                        servers = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! [Server]
                    }
                    servers.append(server)
                    let encoded = NSKeyedArchiver.archivedDataWithRootObject(servers)
                    userDefaults.setObject(encoded, forKey: "servers")
                    userDefaults.synchronize()
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
            
        }
    }
}