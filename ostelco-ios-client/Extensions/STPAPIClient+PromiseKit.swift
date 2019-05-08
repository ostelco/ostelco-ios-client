//
//  STPAPIClient+PromiseKit.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import PromiseKit
import Stripe

extension STPAPIClient {
    
    enum Error: Swift.Error {
        case noSourceAndNoError
    }
    
    func promiseCreateSource(with payment: PKPayment) -> Promise<STPSource> {
        return Promise { seal in
            self.createSource(with: payment) { source, error in
                if let stripeError = error {
                    seal.reject(stripeError)
                    return
                }
                
                guard let source = source else {
                    seal.reject(Error.noSourceAndNoError)
                    return
                }
                
                seal.fulfill(source)
            }
        }
    }
}
