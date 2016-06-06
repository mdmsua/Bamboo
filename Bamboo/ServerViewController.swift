//
//  ServerViewController.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 07.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import UIKit

class ServerViewController: UITableViewController {
    
    private let repository = ServerRepository()
    
    @IBOutlet private weak var saveBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private weak var nameTextField: UITextField!
    
    @IBOutlet private weak var locationTextField: UITextField!
    
    @IBOutlet private weak var usernameTextField: UITextField!
    
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBAction private func textFieldEditingChanged() {
        self.saveBarButtonItem.enabled =
            !self.nameTextField.text!.isEmpty &&
            !self.locationTextField.text!.isEmpty &&
            !self.usernameTextField.text!.isEmpty &&
            !self.passwordTextField.text!.isEmpty
    }

    @IBAction private func saveBarButtonItemClicked(sender: AnyObject) {
        let name = self.nameTextField.text!
        let location = self.locationTextField.text!
        let username = self.usernameTextField.text!
        let password = self.passwordTextField.text!
        let url = NSURL(string: location)!
        let client = BambooClient(url, username: username, password: password)
        let overlay = self.presentActivityIndicatorOverlay()
        client.info() {
            (error, info) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                overlay.removeFromSuperview()
                if let error = error {
                    self.alert(error)
                } else if let _ = info {
                    let server = Server(name: name, location: location, username: username, password: password)
                    self.repository.update(server)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            
        }
    }
    
    @IBAction private func cancelBarButtonItemClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        if let server = self.repository.get() {
            self.nameTextField.text = server.name
            self.locationTextField.text = server.location
            self.usernameTextField.text = server.username
            self.passwordTextField.text = server.password
            self.textFieldEditingChanged()
        }
    }
}