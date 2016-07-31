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
    
    @IBOutlet private weak var biometricsSwitch: UISwitch!
    
    @IBAction private func textFieldEditingChanged() {
        saveBarButtonItem.enabled =
            !nameTextField.text!.isEmpty &&
            !locationTextField.text!.isEmpty &&
            !usernameTextField.text!.isEmpty &&
            !passwordTextField.text!.isEmpty
    }

    @IBAction private func saveBarButtonItemClicked(sender: AnyObject) {
        let name = nameTextField.text!
        let location = locationTextField.text!
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        let url = NSURL(string: location)!
        let client = BambooClient(url, username: username, password: password)
        let overlay = presentActivityIndicatorOverlay()
        client.info() {
            (error, info) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                [unowned self] in
                overlay.removeFromSuperview()
                if let error = error {
                    self.alert(error)
                } else if let _ = info {
                    let server = Server(name: name, location: location, username: username, password: password, biometrics: self.biometricsSwitch.on)
                    self.repository.update(server)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            
        }
    }
    
    @IBAction private func cancelBarButtonItemClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        if let server = repository.get() {
            nameTextField.text = server.name
            locationTextField.text = server.location
            usernameTextField.text = server.username
            passwordTextField.text = server.password
            biometricsSwitch.on = server.biometrics
            textFieldEditingChanged()
        }
    }
}
