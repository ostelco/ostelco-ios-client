//
//  PushNotificationModel.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/20/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct PushNotificationContainer: Codable {
    public let alert: PushAlert?
    public let gcmMessageID: String?
    public let scanInfo: Scan?
    
    public enum CodingKeys: String, CodingKey {
        case alert = "aps"
        case gcmMessageID = "gcm.message_id"
        case scanInfo = "SCAN_INFORMATION"
    }
    
    public init?(dictionary: [AnyHashable: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
            return nil
        }
        
        guard let container = try? JSONDecoder().decode(PushNotificationContainer.self, from: jsonData) else {
            return nil
        }

        self = container
    }
}

public struct PushAlert: Codable {
    public let notification: PushNotification
    
    public enum CodingKeys: String, CodingKey {
        case notification = "alert"
    }
}

public struct PushNotification: Codable {
    public let title: String?
    public let body: String?
    public let data: [String: String]?
    
    public init(title: String?,
                body: String?,
                data: [String: String]?) {
        self.title = title
        self.body = body
        self.data = data
    }
}
