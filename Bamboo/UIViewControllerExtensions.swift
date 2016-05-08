//
//  UIViewControllerExtensions.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 08.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func alert(error: NSError, handler: ((UIAlertAction) -> Void)? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: handler))
        self.presentViewController(alertController, animated: true, completion: completion)
    }
    
    func presentActivityIndicatorOverlay() -> UIView {
        let overlayView = UIView(frame: UIScreen.mainScreen().bounds)
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicatorView.center = overlayView.center
        activityIndicatorView.startAnimating()
        overlayView.addSubview(activityIndicatorView)
        self.navigationController?.view.addSubview(overlayView)
        return overlayView
    }
    
}