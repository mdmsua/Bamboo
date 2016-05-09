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
    
    @IBOutlet private weak var doneButton: UIButton!
    
    @IBOutlet private weak var nameTextField: UITextField!
    
    @IBOutlet private weak var locationTextField: UITextField!
    
    @IBOutlet private weak var usernameTextField: UITextField!
    
    @IBOutlet private weak var passwordTextField: UITextField!
    
    @IBAction private func textFieldEditingChanged() {
        doneButton.enabled =
            self.nameTextField.text?.characters.count > 0 &&
            self.locationTextField.text?.characters.count > 0 &&
            self.usernameTextField.text?.characters.count > 0 &&
            self.passwordTextField.text?.characters.count > 0
    }

    @IBAction func doneButtonClicked(sender: AnyObject) {
        let name = self.nameTextField.text!
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
                    let server = Server(name: name, location: location, username: username, password: password)
                    self.repository.add(server)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
            
        }
    }
}