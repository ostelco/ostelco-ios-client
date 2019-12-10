//
//  TokenProvider.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import PromiseKit

public protocol TokenProvider {
    
    func getToken() -> Promise<String>
    func forceRefreshToken() -> Promise<String>
}
