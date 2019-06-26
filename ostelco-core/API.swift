//  This file was automatically generated and should not be edited.

import Apollo

public enum CustomerRegionStatus: RawRepresentable, Equatable, Hashable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case approved
  case pending
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "APPROVED": self = .approved
      case "PENDING": self = .pending
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .approved: return "APPROVED"
      case .pending: return "PENDING"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: CustomerRegionStatus, rhs: CustomerRegionStatus) -> Bool {
    switch (lhs, rhs) {
      case (.approved, .approved): return true
      case (.pending, .pending): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum KycStatus: RawRepresentable, Equatable, Hashable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case approved
  case pending
  case rejected
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "APPROVED": self = .approved
      case "PENDING": self = .pending
      case "REJECTED": self = .rejected
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .approved: return "APPROVED"
      case .pending: return "PENDING"
      case .rejected: return "REJECTED"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: KycStatus, rhs: KycStatus) -> Bool {
    switch (lhs, rhs) {
      case (.approved, .approved): return true
      case (.pending, .pending): return true
      case (.rejected, .rejected): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum SimProfileStatus: RawRepresentable, Equatable, Hashable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case availableForDownload
  case downloaded
  case enabled
  case installed
  case notReady
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "AVAILABLE_FOR_DOWNLOAD": self = .availableForDownload
      case "DOWNLOADED": self = .downloaded
      case "ENABLED": self = .enabled
      case "INSTALLED": self = .installed
      case "NOT_READY": self = .notReady
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .availableForDownload: return "AVAILABLE_FOR_DOWNLOAD"
      case .downloaded: return "DOWNLOADED"
      case .enabled: return "ENABLED"
      case .installed: return "INSTALLED"
      case .notReady: return "NOT_READY"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SimProfileStatus, rhs: SimProfileStatus) -> Bool {
    switch (lhs, rhs) {
      case (.availableForDownload, .availableForDownload): return true
      case (.downloaded, .downloaded): return true
      case (.enabled, .enabled): return true
      case (.installed, .installed): return true
      case (.notReady, .notReady): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public final class GetContextQuery: GraphQLQuery {
  public let operationDefinition =
    "query GetContext {\n  context {\n    __typename\n    customer {\n      __typename\n      nickname\n      contactEmail\n    }\n    bundles {\n      __typename\n      id\n      balance\n    }\n    regions {\n      __typename\n      region {\n        __typename\n        id\n        name\n      }\n      status\n      kycStatusMap {\n        __typename\n        JUMIO\n        MY_INFO\n        NRIC_FIN\n        ADDRESS_AND_PHONE_NUMBER\n      }\n      simProfiles {\n        __typename\n        iccId\n        eSimActivationCode\n        status\n        alias\n      }\n    }\n    subscriptions {\n      __typename\n      msisdn\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["QueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("context", type: .nonNull(.object(Context.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(context: Context) {
      self.init(unsafeResultMap: ["__typename": "QueryType", "context": context.resultMap])
    }

    public var context: Context {
      get {
        return Context(unsafeResultMap: resultMap["context"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "context")
      }
    }

    public struct Context: GraphQLSelectionSet {
      public static let possibleTypes = ["Context"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("customer", type: .nonNull(.object(Customer.selections))),
        GraphQLField("bundles", type: .list(.object(Bundle.selections))),
        GraphQLField("regions", type: .list(.object(Region.selections))),
        GraphQLField("subscriptions", type: .list(.object(Subscription.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(customer: Customer, bundles: [Bundle?]? = nil, regions: [Region?]? = nil, subscriptions: [Subscription?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Context", "customer": customer.resultMap, "bundles": bundles.flatMap { (value: [Bundle?]) -> [ResultMap?] in value.map { (value: Bundle?) -> ResultMap? in value.flatMap { (value: Bundle) -> ResultMap in value.resultMap } } }, "regions": regions.flatMap { (value: [Region?]) -> [ResultMap?] in value.map { (value: Region?) -> ResultMap? in value.flatMap { (value: Region) -> ResultMap in value.resultMap } } }, "subscriptions": subscriptions.flatMap { (value: [Subscription?]) -> [ResultMap?] in value.map { (value: Subscription?) -> ResultMap? in value.flatMap { (value: Subscription) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var customer: Customer {
        get {
          return Customer(unsafeResultMap: resultMap["customer"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "customer")
        }
      }

      public var bundles: [Bundle?]? {
        get {
          return (resultMap["bundles"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Bundle?] in value.map { (value: ResultMap?) -> Bundle? in value.flatMap { (value: ResultMap) -> Bundle in Bundle(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Bundle?]) -> [ResultMap?] in value.map { (value: Bundle?) -> ResultMap? in value.flatMap { (value: Bundle) -> ResultMap in value.resultMap } } }, forKey: "bundles")
        }
      }

      public var regions: [Region?]? {
        get {
          return (resultMap["regions"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Region?] in value.map { (value: ResultMap?) -> Region? in value.flatMap { (value: ResultMap) -> Region in Region(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Region?]) -> [ResultMap?] in value.map { (value: Region?) -> ResultMap? in value.flatMap { (value: Region) -> ResultMap in value.resultMap } } }, forKey: "regions")
        }
      }

      public var subscriptions: [Subscription?]? {
        get {
          return (resultMap["subscriptions"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Subscription?] in value.map { (value: ResultMap?) -> Subscription? in value.flatMap { (value: ResultMap) -> Subscription in Subscription(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Subscription?]) -> [ResultMap?] in value.map { (value: Subscription?) -> ResultMap? in value.flatMap { (value: Subscription) -> ResultMap in value.resultMap } } }, forKey: "subscriptions")
        }
      }

      public struct Customer: GraphQLSelectionSet {
        public static let possibleTypes = ["Customer"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
          GraphQLField("contactEmail", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(nickname: String, contactEmail: String) {
          self.init(unsafeResultMap: ["__typename": "Customer", "nickname": nickname, "contactEmail": contactEmail])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nickname: String {
          get {
            return resultMap["nickname"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "nickname")
          }
        }

        public var contactEmail: String {
          get {
            return resultMap["contactEmail"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "contactEmail")
          }
        }
      }

      public struct Bundle: GraphQLSelectionSet {
        public static let possibleTypes = ["Bundle"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("balance", type: .nonNull(.scalar(Long.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: String, balance: Long) {
          self.init(unsafeResultMap: ["__typename": "Bundle", "id": id, "balance": balance])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return resultMap["id"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var balance: Long {
          get {
            return resultMap["balance"]! as! Long
          }
          set {
            resultMap.updateValue(newValue, forKey: "balance")
          }
        }
      }

      public struct Region: GraphQLSelectionSet {
        public static let possibleTypes = ["RegionDetails"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("region", type: .nonNull(.object(Region.selections))),
          GraphQLField("status", type: .scalar(CustomerRegionStatus.self)),
          GraphQLField("kycStatusMap", type: .object(KycStatusMap.selections)),
          GraphQLField("simProfiles", type: .list(.object(SimProfile.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(region: Region, status: CustomerRegionStatus? = nil, kycStatusMap: KycStatusMap? = nil, simProfiles: [SimProfile?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "RegionDetails", "region": region.resultMap, "status": status, "kycStatusMap": kycStatusMap.flatMap { (value: KycStatusMap) -> ResultMap in value.resultMap }, "simProfiles": simProfiles.flatMap { (value: [SimProfile?]) -> [ResultMap?] in value.map { (value: SimProfile?) -> ResultMap? in value.flatMap { (value: SimProfile) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var region: Region {
          get {
            return Region(unsafeResultMap: resultMap["region"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "region")
          }
        }

        public var status: CustomerRegionStatus? {
          get {
            return resultMap["status"] as? CustomerRegionStatus
          }
          set {
            resultMap.updateValue(newValue, forKey: "status")
          }
        }

        public var kycStatusMap: KycStatusMap? {
          get {
            return (resultMap["kycStatusMap"] as? ResultMap).flatMap { KycStatusMap(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "kycStatusMap")
          }
        }

        public var simProfiles: [SimProfile?]? {
          get {
            return (resultMap["simProfiles"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [SimProfile?] in value.map { (value: ResultMap?) -> SimProfile? in value.flatMap { (value: ResultMap) -> SimProfile in SimProfile(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [SimProfile?]) -> [ResultMap?] in value.map { (value: SimProfile?) -> ResultMap? in value.flatMap { (value: SimProfile) -> ResultMap in value.resultMap } } }, forKey: "simProfiles")
          }
        }

        public struct Region: GraphQLSelectionSet {
          public static let possibleTypes = ["Region"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: String, name: String) {
            self.init(unsafeResultMap: ["__typename": "Region", "id": id, "name": name])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: String {
            get {
              return resultMap["id"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String {
            get {
              return resultMap["name"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }
        }

        public struct KycStatusMap: GraphQLSelectionSet {
          public static let possibleTypes = ["KycStatusMap"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("JUMIO", type: .scalar(KycStatus.self)),
            GraphQLField("MY_INFO", type: .scalar(KycStatus.self)),
            GraphQLField("NRIC_FIN", type: .scalar(KycStatus.self)),
            GraphQLField("ADDRESS_AND_PHONE_NUMBER", type: .scalar(KycStatus.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(jumio: KycStatus? = nil, myInfo: KycStatus? = nil, nricFin: KycStatus? = nil, addressAndPhoneNumber: KycStatus? = nil) {
            self.init(unsafeResultMap: ["__typename": "KycStatusMap", "JUMIO": jumio, "MY_INFO": myInfo, "NRIC_FIN": nricFin, "ADDRESS_AND_PHONE_NUMBER": addressAndPhoneNumber])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var jumio: KycStatus? {
            get {
              return resultMap["JUMIO"] as? KycStatus
            }
            set {
              resultMap.updateValue(newValue, forKey: "JUMIO")
            }
          }

          public var myInfo: KycStatus? {
            get {
              return resultMap["MY_INFO"] as? KycStatus
            }
            set {
              resultMap.updateValue(newValue, forKey: "MY_INFO")
            }
          }

          public var nricFin: KycStatus? {
            get {
              return resultMap["NRIC_FIN"] as? KycStatus
            }
            set {
              resultMap.updateValue(newValue, forKey: "NRIC_FIN")
            }
          }

          public var addressAndPhoneNumber: KycStatus? {
            get {
              return resultMap["ADDRESS_AND_PHONE_NUMBER"] as? KycStatus
            }
            set {
              resultMap.updateValue(newValue, forKey: "ADDRESS_AND_PHONE_NUMBER")
            }
          }
        }

        public struct SimProfile: GraphQLSelectionSet {
          public static let possibleTypes = ["SimProfile"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("iccId", type: .nonNull(.scalar(String.self))),
            GraphQLField("eSimActivationCode", type: .nonNull(.scalar(String.self))),
            GraphQLField("status", type: .nonNull(.scalar(SimProfileStatus.self))),
            GraphQLField("alias", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(iccId: String, eSimActivationCode: String, status: SimProfileStatus, alias: String) {
            self.init(unsafeResultMap: ["__typename": "SimProfile", "iccId": iccId, "eSimActivationCode": eSimActivationCode, "status": status, "alias": alias])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var iccId: String {
            get {
              return resultMap["iccId"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "iccId")
            }
          }

          public var eSimActivationCode: String {
            get {
              return resultMap["eSimActivationCode"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "eSimActivationCode")
            }
          }

          public var status: SimProfileStatus {
            get {
              return resultMap["status"]! as! SimProfileStatus
            }
            set {
              resultMap.updateValue(newValue, forKey: "status")
            }
          }

          public var alias: String {
            get {
              return resultMap["alias"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "alias")
            }
          }
        }
      }

      public struct Subscription: GraphQLSelectionSet {
        public static let possibleTypes = ["Subscription"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("msisdn", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(msisdn: String) {
          self.init(unsafeResultMap: ["__typename": "Subscription", "msisdn": msisdn])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var msisdn: String {
          get {
            return resultMap["msisdn"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "msisdn")
          }
        }
      }
    }
  }
}