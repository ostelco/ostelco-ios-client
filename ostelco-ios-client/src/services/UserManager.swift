//
//  DataManager.swift
//  ostelco-ios-client
//
//  Created by mac on 3/12/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

class UserManager {
    static let sharedInstance = UserManager()
    
    var authToken: String?
    var user: CustomerModel?
 
    func clear() {
        authToken = nil
    }
}
