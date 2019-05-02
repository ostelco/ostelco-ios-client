//
//  BasicNetwork.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/2/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import PromiseKit

open class BasicNetwork {
    
    open func performRequest(_ request: Request) -> Promise<(data: Data, response: URLResponse)> {
        return request.generateRequest()
            .then {
                URLSession.shared.dataTask(.promise, with: $0)
            }
    }
    
    open func performValidatedRequest(_ request: Request) -> Promise<Data> {
        return self.performRequest(request)
            .map { data, response in
                try APIHelper.validateResponse(data: data, response: response)
            }
    }
}
