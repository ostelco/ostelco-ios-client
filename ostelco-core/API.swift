//  This file was automatically generated and should not be edited.

import Apollo

/// PrimeGQL namespace
public enum PrimeGQL {
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

  public final class RegionsQuery: GraphQLQuery {
    public let operationDefinition =
      "query Regions {\n  context {\n    __typename\n    regions {\n      __typename\n      ...regionDetailsFragment\n    }\n  }\n}"

    public var queryDocument: String { return operationDefinition.appending(RegionDetailsFragment.fragmentDefinition) }

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
          GraphQLField("regions", type: .list(.object(Region.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(regions: [Region?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "Context", "regions": regions.flatMap { (value: [Region?]) -> [ResultMap?] in value.map { (value: Region?) -> ResultMap? in value.flatMap { (value: Region) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
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

        public struct Region: GraphQLSelectionSet {
          public static let possibleTypes = ["RegionDetails"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(RegionDetailsFragment.self),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var regionDetailsFragment: RegionDetailsFragment {
              get {
                return RegionDetailsFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }
    }
  }

  public final class ProductsQuery: GraphQLQuery {
    public let operationDefinition =
      "query Products {\n  context {\n    __typename\n    products {\n      __typename\n      ...productFragment\n    }\n  }\n}"

    public var queryDocument: String { return operationDefinition.appending(ProductFragment.fragmentDefinition) }

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
          GraphQLField("products", type: .list(.object(Product.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(products: [Product?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "Context", "products": products.flatMap { (value: [Product?]) -> [ResultMap?] in value.map { (value: Product?) -> ResultMap? in value.flatMap { (value: Product) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var products: [Product?]? {
          get {
            return (resultMap["products"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Product?] in value.map { (value: ResultMap?) -> Product? in value.flatMap { (value: ResultMap) -> Product in Product(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Product?]) -> [ResultMap?] in value.map { (value: Product?) -> ResultMap? in value.flatMap { (value: Product) -> ResultMap in value.resultMap } } }, forKey: "products")
          }
        }

        public struct Product: GraphQLSelectionSet {
          public static let possibleTypes = ["Product"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(ProductFragment.self),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var productFragment: ProductFragment {
              get {
                return ProductFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }
    }
  }

  public final class ContextQuery: GraphQLQuery {
    public let operationDefinition =
      "query Context {\n  context {\n    __typename\n    customer {\n      __typename\n      id\n      contactEmail\n      nickname\n      referralId\n      analyticsId\n    }\n    regions {\n      __typename\n      ...regionDetailsFragment\n    }\n  }\n}"

    public var queryDocument: String { return operationDefinition.appending(RegionDetailsFragment.fragmentDefinition) }

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
          GraphQLField("regions", type: .list(.object(Region.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(customer: Customer, regions: [Region?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "Context", "customer": customer.resultMap, "regions": regions.flatMap { (value: [Region?]) -> [ResultMap?] in value.map { (value: Region?) -> ResultMap? in value.flatMap { (value: Region) -> ResultMap in value.resultMap } } }])
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

        public var regions: [Region?]? {
          get {
            return (resultMap["regions"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Region?] in value.map { (value: ResultMap?) -> Region? in value.flatMap { (value: ResultMap) -> Region in Region(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Region?]) -> [ResultMap?] in value.map { (value: Region?) -> ResultMap? in value.flatMap { (value: Region) -> ResultMap in value.resultMap } } }, forKey: "regions")
          }
        }

        public struct Customer: GraphQLSelectionSet {
          public static let possibleTypes = ["Customer"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(String.self))),
            GraphQLField("contactEmail", type: .nonNull(.scalar(String.self))),
            GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
            GraphQLField("referralId", type: .nonNull(.scalar(String.self))),
            GraphQLField("analyticsId", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: String, contactEmail: String, nickname: String, referralId: String, analyticsId: String) {
            self.init(unsafeResultMap: ["__typename": "Customer", "id": id, "contactEmail": contactEmail, "nickname": nickname, "referralId": referralId, "analyticsId": analyticsId])
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

          public var contactEmail: String {
            get {
              return resultMap["contactEmail"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "contactEmail")
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

          public var referralId: String {
            get {
              return resultMap["referralId"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "referralId")
            }
          }

          public var analyticsId: String {
            get {
              return resultMap["analyticsId"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "analyticsId")
            }
          }
        }

        public struct Region: GraphQLSelectionSet {
          public static let possibleTypes = ["RegionDetails"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(RegionDetailsFragment.self),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var regionDetailsFragment: RegionDetailsFragment {
              get {
                return RegionDetailsFragment(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }
    }
  }

  public final class PurchasesQuery: GraphQLQuery {
    public let operationDefinition =
      "query Purchases {\n  context {\n    __typename\n    purchases {\n      __typename\n      id\n      product {\n        __typename\n        ...productFragment\n      }\n      timestamp\n    }\n  }\n}"

    public var queryDocument: String { return operationDefinition.appending(ProductFragment.fragmentDefinition) }

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
          GraphQLField("purchases", type: .list(.object(Purchase.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(purchases: [Purchase?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "Context", "purchases": purchases.flatMap { (value: [Purchase?]) -> [ResultMap?] in value.map { (value: Purchase?) -> ResultMap? in value.flatMap { (value: Purchase) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var purchases: [Purchase?]? {
          get {
            return (resultMap["purchases"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Purchase?] in value.map { (value: ResultMap?) -> Purchase? in value.flatMap { (value: ResultMap) -> Purchase in Purchase(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Purchase?]) -> [ResultMap?] in value.map { (value: Purchase?) -> ResultMap? in value.flatMap { (value: Purchase) -> ResultMap in value.resultMap } } }, forKey: "purchases")
          }
        }

        public struct Purchase: GraphQLSelectionSet {
          public static let possibleTypes = ["Purchase"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(String.self))),
            GraphQLField("product", type: .nonNull(.object(Product.selections))),
            GraphQLField("timestamp", type: .nonNull(.scalar(Long.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: String, product: Product, timestamp: Long) {
            self.init(unsafeResultMap: ["__typename": "Purchase", "id": id, "product": product.resultMap, "timestamp": timestamp])
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

          public var product: Product {
            get {
              return Product(unsafeResultMap: resultMap["product"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "product")
            }
          }

          public var timestamp: Long {
            get {
              return resultMap["timestamp"]! as! Long
            }
            set {
              resultMap.updateValue(newValue, forKey: "timestamp")
            }
          }

          public struct Product: GraphQLSelectionSet {
            public static let possibleTypes = ["Product"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLFragmentSpread(ProductFragment.self),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var productFragment: ProductFragment {
                get {
                  return ProductFragment(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }
          }
        }
      }
    }
  }

  public final class BundlesQuery: GraphQLQuery {
    public let operationDefinition =
      "query Bundles {\n  context {\n    __typename\n    bundles {\n      __typename\n      id\n      balance\n    }\n  }\n}"

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
          GraphQLField("bundles", type: .list(.object(Bundle.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(bundles: [Bundle?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "Context", "bundles": bundles.flatMap { (value: [Bundle?]) -> [ResultMap?] in value.map { (value: Bundle?) -> ResultMap? in value.flatMap { (value: Bundle) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
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
      }
    }
  }

  public struct ProductFragment: GraphQLFragment {
    public static let fragmentDefinition =
      "fragment productFragment on Product {\n  __typename\n  sku\n  price {\n    __typename\n    amount\n    currency\n  }\n}"

    public static let possibleTypes = ["Product"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("sku", type: .nonNull(.scalar(String.self))),
      GraphQLField("price", type: .nonNull(.object(Price.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sku: String, price: Price) {
      self.init(unsafeResultMap: ["__typename": "Product", "sku": sku, "price": price.resultMap])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var sku: String {
      get {
        return resultMap["sku"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "sku")
      }
    }

    public var price: Price {
      get {
        return Price(unsafeResultMap: resultMap["price"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "price")
      }
    }

    public struct Price: GraphQLSelectionSet {
      public static let possibleTypes = ["Price"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("amount", type: .nonNull(.scalar(Int.self))),
        GraphQLField("currency", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(amount: Int, currency: String) {
        self.init(unsafeResultMap: ["__typename": "Price", "amount": amount, "currency": currency])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var amount: Int {
        get {
          return resultMap["amount"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "amount")
        }
      }

      public var currency: String {
        get {
          return resultMap["currency"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "currency")
        }
      }
    }
  }

  public struct RegionDetailsFragment: GraphQLFragment {
    public static let fragmentDefinition =
      "fragment regionDetailsFragment on RegionDetails {\n  __typename\n  region {\n    __typename\n    id\n    name\n  }\n  status\n  kycStatusMap {\n    __typename\n    JUMIO\n    MY_INFO\n    NRIC_FIN\n    ADDRESS_AND_PHONE_NUMBER\n  }\n  simProfiles {\n    __typename\n    eSimActivationCode\n    alias\n    iccId\n    status\n  }\n}"

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
        GraphQLField("eSimActivationCode", type: .nonNull(.scalar(String.self))),
        GraphQLField("alias", type: .nonNull(.scalar(String.self))),
        GraphQLField("iccId", type: .nonNull(.scalar(String.self))),
        GraphQLField("status", type: .nonNull(.scalar(SimProfileStatus.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(eSimActivationCode: String, alias: String, iccId: String, status: SimProfileStatus) {
        self.init(unsafeResultMap: ["__typename": "SimProfile", "eSimActivationCode": eSimActivationCode, "alias": alias, "iccId": iccId, "status": status])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
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

      public var alias: String {
        get {
          return resultMap["alias"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "alias")
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

      public var status: SimProfileStatus {
        get {
          return resultMap["status"]! as! SimProfileStatus
        }
        set {
          resultMap.updateValue(newValue, forKey: "status")
        }
      }
    }
  }
}