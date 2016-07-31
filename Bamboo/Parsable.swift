//
//  Parsable.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 21.06.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import Foundation

protocol Parsable {
    init?(_ json: [String: AnyObject])
}
