//
//  Biometrics.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 03.07.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import Foundation
import LocalAuthentication

class Biometrics {

    enum PolicyEvaluationResult {
        case Success
        case Fallback
        case Cancel
    }

    private static let context = LAContext()

    private static func canEvaluatePolicy() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    static var enabled: Bool = Biometrics.canEvaluatePolicy()

    static func authenticate(message: String, handler: PolicyEvaluationResult -> Void) -> Void {
        context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: message) {
            (success, error) -> Void in
            if success {
                handler(.Success)
            } else if let error = error, laError = LAError(rawValue: error.code) {
                switch laError {
                case LAError.UserFallback:
                    handler(.Fallback)
                default:
                    handler(.Cancel)
                }
            }
        }
    }
}