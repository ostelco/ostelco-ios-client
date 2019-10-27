//
//  OstelcoAnalytics.swift
//  ostelco-ios-client
//
//  Created by mac on 4/29/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import ostelco_core
import FirebaseAnalytics
import Crashlytics

public class OstelcoAnalytics {
    
    enum AnalyticsError: Swift.Error, LocalizedError {
        case eventNameIsEmpty
        
        var localizedDescription: String {
            switch self {
            case .eventNameIsEmpty:
                return "Event name in analytics event is empty"
            }
        }
    }
    
    static func logEvent(_ event: AnalyticsEvent) {
        if event.name.isEmpty {
            var meta = event.metadata
            meta["name"] = event.name as NSObject
            meta["className"] = String(describing: event) as NSObject
            ApplicationErrors.log(AnalyticsError.eventNameIsEmpty, withAdditionalUserInfo: meta)
        } else {
            Analytics.logEvent(event.name, parameters: event.metadata)
        }
    }
    
    static func setUserId(_ id: String) {
        Analytics.setUserID(id)
    }
}

enum AnalyticsEvent {
    
    case signInFlowStarted
    case signIn
    case legalStuffAgreed
    case nicknameEntered
    case signup
    case permissionLocationGranted
    case permissionLocationDenied
    case permissionNotificationsGranted
    case permissionNotificationsDenied
    case getNewRegionFlowStarted(regionCode: String, countryCode: String)
    case identificationMethodChosen(regionCode: String, countryCode: String, ekycMethod: String)
    case identificationPendingValidation(regionCode: String, countryCode: String, ekycMethod: String)
    case identificationSuccessful(regionCode: String, countryCode: String, ekycMethod: String)
    case identificationFailed(regionCode: String, countryCode: String, ekycMethod: String, failureReason: String)
    case esimSetupStarted(regionCode: String, countryCode: String)
    case esimSetupCompleted(regionCode: String, countryCode: String)
    case logout
    case buyDataFlowStarted
    case setupApplePay
    case addToCart(name: String, sku: String, countryCode: String, amount: Decimal, currency: String)
    case ecommercePurchase(currency: String, value: Decimal, tax: Decimal)
    case ecommercePurchaseFailed(failureReason: String)
    
    var name: String {
        switch self {
        case .addToCart:
            return AnalyticsEventAddToCart
        case .ecommercePurchase:
            return AnalyticsEventEcommercePurchase
        case .ecommercePurchaseFailed:
            return "purchase_failed"
        default:
            return String(describing: self).components(separatedBy: "(")[0].snakeCased() ?? ""
        }
    }
    
    var metadata: [String: Any] {
        switch self {
        case .getNewRegionFlowStarted(let regionCode, let countryCode):
            return ["region_code": regionCode, "country_code": countryCode]
        case .identificationMethodChosen(let regionCode, let countryCode, let ekycMethod):
            return ["region_code": regionCode, "country_code": countryCode, "ekyc_method": ekycMethod]
        case .identificationPendingValidation(let regionCode, let countryCode, let ekycMethod):
            return ["region_code": regionCode, "country_code": countryCode, "ekyc_method": ekycMethod]
        case .identificationSuccessful(let regionCode, let countryCode, let ekycMethod):
            return ["region_code": regionCode, "country_code": countryCode, "ekyc_method": ekycMethod]
        case .identificationFailed(let regionCode, let countryCode, let ekycMethod, let failureReason):
            return ["region_code": regionCode, "country_code": countryCode, "ekyc_method": ekycMethod, "failure_reaon": failureReason]
        case .esimSetupStarted(let regionCode, let countryCode):
            return ["region_code": regionCode, "country_code": countryCode]
        case .esimSetupCompleted(let regionCode, let countryCode):
            return ["region_code": regionCode, "country_code": countryCode]
        case .addToCart(let name, let sku, let countryCode, let amount, let currency):
            return [
                "quantity": "1",
                "item_categgory":
                "one-time-purchase",
                "item_name": name,
                "item_sku": sku,
                "item_location": countryCode,
                "value": NSDecimalNumber(decimal: amount).stringValue,
                "price": NSDecimalNumber(decimal: amount).stringValue,
                "currency": currency
            ]
        case .ecommercePurchase(let currency, let value, let tax):
            return [
                "currency": currency,
                "value": Double(truncating: value as NSNumber),
                "tax": Double(truncating: tax as NSNumber)
            ]
        case .ecommercePurchaseFailed(let failureReason):
            return ["failure_reason": failureReason]
        default:
            return [:]
        }
    }
}
