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
    
    private init(alert: PushAlert, gcmMessageID: String, scanInfo: Scan) {
        self.alert = alert
        self.gcmMessageID = gcmMessageID
        self.scanInfo = scanInfo
    }
    
    public init?(dictionary: [AnyHashable: Any]) {
        // This is to account for the fact the SCAN_INFORMATION might be a string or it might be a dictionary like "aps"
        // I think this is caused by an iOS version change.
        if let alertString = dictionary["SCAN_INFORMATION"] as? String {
            do {
                let apsData = try JSONSerialization.data(withJSONObject: dictionary["aps"] as Any, options: .prettyPrinted)
                let alert = try JSONDecoder().decode(PushAlert.self, from: apsData)
                // swiftlint:disable:next force_cast
                let messageID = dictionary["gcm.message_id"] as! String
                
                let alertData = alertString.data(using: .utf8) ?? Data()
                let scan = try JSONDecoder().decode(Scan.self, from: alertData)
                
                self = PushNotificationContainer(alert: alert, gcmMessageID: messageID, scanInfo: scan)
            } catch {
                print(error)
                return nil
            }
        } else {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
                return nil
            }
            
            guard let container = try? JSONDecoder().decode(PushNotificationContainer.self, from: jsonData) else {
                return nil
            }
            self = container
        }
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
