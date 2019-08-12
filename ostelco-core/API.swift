//  This file was automatically generated and should not be edited.

import Apollo

public enum RegionCode: RawRepresentable, Equatable, Hashable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case sg
  case no
  case us
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "SG": self = .sg
      case "NO": self = .no
      case "US": self = .us
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .sg: return "SG"
      case .no: return "NO"
      case .us: return "US"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: RegionCode, rhs: RegionCode) -> Bool {
    switch (lhs, rhs) {
      case (.sg, .sg): return true
      case (.no, .no): return true
      case (.us, .us): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct CreateAddressInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(address: String, phoneNumber: String) {
    graphQLMap = ["address": address, "phoneNumber": phoneNumber]
  }

  public var address: String {
    get {
      return graphQLMap["address"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "address")
    }
  }

  public var phoneNumber: String {
    get {
      return graphQLMap["phoneNumber"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "phoneNumber")
    }
  }
}

public struct CreateApplicationTokenInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(token: String, tokenType: String, applicationId: String) {
    graphQLMap = ["token": token, "tokenType": tokenType, "applicationID": applicationId]
  }

  public var token: String {
    get {
      return graphQLMap["token"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "token")
    }
  }

  public var tokenType: String {
    get {
      return graphQLMap["tokenType"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tokenType")
    }
  }

  public var applicationId: String {
    get {
      return graphQLMap["applicationID"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "applicationID")
    }
  }
}

public struct CreateCustomerInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(contactEmail: String, nickname: String) {
    graphQLMap = ["contactEmail": contactEmail, "nickname": nickname]
  }

  public var contactEmail: String {
    get {
      return graphQLMap["contactEmail"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contactEmail")
    }
  }

  public var nickname: String {
    get {
      return graphQLMap["nickname"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "nickname")
    }
  }
}

public struct CreateJumioScanInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(regionCode: RegionCode) {
    graphQLMap = ["regionCode": regionCode]
  }

  public var regionCode: RegionCode {
    get {
      return graphQLMap["regionCode"] as! RegionCode
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "regionCode")
    }
  }
}

public struct CreatePurchaseInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(sku: String, sourceId: String) {
    graphQLMap = ["sku": sku, "sourceId": sourceId]
  }

  public var sku: String {
    get {
      return graphQLMap["sku"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sku")
    }
  }

  public var sourceId: String {
    get {
      return graphQLMap["sourceId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sourceId")
    }
  }
}

public struct CreateSimProfileInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(regionCode: RegionCode, profileType: SimProfileType) {
    graphQLMap = ["regionCode": regionCode, "profileType": profileType]
  }

  public var regionCode: RegionCode {
    get {
      return graphQLMap["regionCode"] as! RegionCode
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "regionCode")
    }
  }

  public var profileType: SimProfileType {
    get {
      return graphQLMap["profileType"] as! SimProfileType
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "profileType")
    }
  }
}

public enum SimProfileType: RawRepresentable, Equatable, Hashable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case iphone
  case loltel
  case test
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "IPHONE": self = .iphone
      case "LOLTEL": self = .loltel
      case "TEST": self = .test
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .iphone: return "IPHONE"
      case .loltel: return "LOLTEL"
      case .test: return "TEST"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SimProfileType, rhs: SimProfileType) -> Bool {
    switch (lhs, rhs) {
      case (.iphone, .iphone): return true
      case (.loltel, .loltel): return true
      case (.test, .test): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct ResendEmailInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(regionCode: RegionCode, iccId: String) {
    graphQLMap = ["regionCode": regionCode, "iccId": iccId]
  }

  public var regionCode: RegionCode {
    get {
      return graphQLMap["regionCode"] as! RegionCode
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "regionCode")
    }
  }

  public var iccId: String {
    get {
      return graphQLMap["iccId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "iccId")
    }
  }
}

public struct ValidateNricInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(nric: String) {
    graphQLMap = ["nric": nric]
  }

  public var nric: String {
    get {
      return graphQLMap["nric"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "nric")
    }
  }
}

public enum CustomerRegionStatus: RawRepresentable, Equatable, Hashable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case pending
  case approved
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "PENDING": self = .pending
      case "APPROVED": self = .approved
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .pending: return "PENDING"
      case .approved: return "APPROVED"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: CustomerRegionStatus, rhs: CustomerRegionStatus) -> Bool {
    switch (lhs, rhs) {
      case (.pending, .pending): return true
      case (.approved, .approved): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum KycStatus: RawRepresentable, Equatable, Hashable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case pending
  case rejected
  case approved
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "PENDING": self = .pending
      case "REJECTED": self = .rejected
      case "APPROVED": self = .approved
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .pending: return "PENDING"
      case .rejected: return "REJECTED"
      case .approved: return "APPROVED"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: KycStatus, rhs: KycStatus) -> Bool {
    switch (lhs, rhs) {
      case (.pending, .pending): return true
      case (.rejected, .rejected): return true
      case (.approved, .approved): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum SimProfileStatus: RawRepresentable, Equatable, Hashable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case notReady
  case availableForDownload
  case downloaded
  case installed
  case enabled
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "NOT_READY": self = .notReady
      case "AVAILABLE_FOR_DOWNLOAD": self = .availableForDownload
      case "DOWNLOADED": self = .downloaded
      case "INSTALLED": self = .installed
      case "ENABLED": self = .enabled
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .notReady: return "NOT_READY"
      case .availableForDownload: return "AVAILABLE_FOR_DOWNLOAD"
      case .downloaded: return "DOWNLOADED"
      case .installed: return "INSTALLED"
      case .enabled: return "ENABLED"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SimProfileStatus, rhs: SimProfileStatus) -> Bool {
    switch (lhs, rhs) {
      case (.notReady, .notReady): return true
      case (.availableForDownload, .availableForDownload): return true
      case (.downloaded, .downloaded): return true
      case (.installed, .installed): return true
      case (.enabled, .enabled): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public final class AllBundlesQuery: GraphQLQuery {
  public let operationDefinition =
    "query AllBundles {\n  bundles {\n    __typename\n    id\n    balance\n  }\n}"

  public let operationName = "AllBundles"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("bundles", type: .list(.nonNull(.object(Bundle.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(bundles: [Bundle]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "bundles": bundles.flatMap { (value: [Bundle]) -> [ResultMap] in value.map { (value: Bundle) -> ResultMap in value.resultMap } }])
    }

    public var bundles: [Bundle]? {
      get {
        return (resultMap["bundles"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Bundle] in value.map { (value: ResultMap) -> Bundle in Bundle(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [Bundle]) -> [ResultMap] in value.map { (value: Bundle) -> ResultMap in value.resultMap } }, forKey: "bundles")
      }
    }

    public struct Bundle: GraphQLSelectionSet {
      public static let possibleTypes = ["Bundle"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("balance", type: .nonNull(.scalar(Long.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, balance: Long) {
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

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
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

public final class ProductsQuery: GraphQLQuery {
  public let operationDefinition =
    "query Products {\n  products {\n    __typename\n    ...productFields\n  }\n}"

  public let operationName = "Products"

  public var queryDocument: String { return operationDefinition.appending(ProductFields.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("products", type: .list(.nonNull(.object(Product.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(products: [Product]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "products": products.flatMap { (value: [Product]) -> [ResultMap] in value.map { (value: Product) -> ResultMap in value.resultMap } }])
    }

    public var products: [Product]? {
      get {
        return (resultMap["products"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Product] in value.map { (value: ResultMap) -> Product in Product(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [Product]) -> [ResultMap] in value.map { (value: Product) -> ResultMap in value.resultMap } }, forKey: "products")
      }
    }

    public struct Product: GraphQLSelectionSet {
      public static let possibleTypes = ["Product"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(ProductFields.self),
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

        public var productFields: ProductFields {
          get {
            return ProductFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class AllPurchasesQuery: GraphQLQuery {
  public let operationDefinition =
    "query AllPurchases {\n  purchases {\n    __typename\n    edges {\n      __typename\n      cursor\n      node {\n        __typename\n        ...purchaseFields\n      }\n    }\n  }\n}"

  public let operationName = "AllPurchases"

  public var queryDocument: String { return operationDefinition.appending(PurchaseFields.fragmentDefinition).appending(ProductFields.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("purchases", type: .object(Purchase.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(purchases: Purchase? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "purchases": purchases.flatMap { (value: Purchase) -> ResultMap in value.resultMap }])
    }

    /// Examples on pagination
    /// https://www.graphql-java-kickstart.com/tools/relay/
    /// https://facebook.github.io/relay/graphql/connections.htm
    /// https://blog.apollographql.com/explaining-graphql-connections-c48b7c3d6976
    public var purchases: Purchase? {
      get {
        return (resultMap["purchases"] as? ResultMap).flatMap { Purchase(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "purchases")
      }
    }

    public struct Purchase: GraphQLSelectionSet {
      public static let possibleTypes = ["UserPurchasesConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("edges", type: .list(.nonNull(.object(Edge.selections)))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(edges: [Edge]? = nil) {
        self.init(unsafeResultMap: ["__typename": "UserPurchasesConnection", "edges": edges.flatMap { (value: [Edge]) -> [ResultMap] in value.map { (value: Edge) -> ResultMap in value.resultMap } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var edges: [Edge]? {
        get {
          return (resultMap["edges"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Edge] in value.map { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge]) -> [ResultMap] in value.map { (value: Edge) -> ResultMap in value.resultMap } }, forKey: "edges")
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes = ["UserPurchasesEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .object(Node.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(cursor: String, node: Node? = nil) {
          self.init(unsafeResultMap: ["__typename": "UserPurchasesEdge", "cursor": cursor, "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cursor: String {
          get {
            return resultMap["cursor"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public var node: Node? {
          get {
            return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "node")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["Purchase"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(PurchaseFields.self),
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

            public var purchaseFields: PurchaseFields {
              get {
                return PurchaseFields(unsafeResultMap: resultMap)
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

public final class AllRegionsQuery: GraphQLQuery {
  public let operationDefinition =
    "query AllRegions($regionCode: RegionCode) {\n  customer {\n    __typename\n    regions(regionCode: $regionCode) {\n      __typename\n      ...regionDetailsFields\n    }\n  }\n}"

  public let operationName = "AllRegions"

  public var queryDocument: String { return operationDefinition.appending(RegionDetailsFields.fragmentDefinition).appending(SimProfileFields.fragmentDefinition) }

  public var regionCode: RegionCode?

  public init(regionCode: RegionCode? = nil) {
    self.regionCode = regionCode
  }

  public var variables: GraphQLMap? {
    return ["regionCode": regionCode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("customer", type: .object(Customer.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(customer: Customer? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "customer": customer.flatMap { (value: Customer) -> ResultMap in value.resultMap }])
    }

    public var customer: Customer? {
      get {
        return (resultMap["customer"] as? ResultMap).flatMap { Customer(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "customer")
      }
    }

    public struct Customer: GraphQLSelectionSet {
      public static let possibleTypes = ["Customer"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("regions", arguments: ["regionCode": GraphQLVariable("regionCode")], type: .list(.nonNull(.object(Region.selections)))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(regions: [Region]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Customer", "regions": regions.flatMap { (value: [Region]) -> [ResultMap] in value.map { (value: Region) -> ResultMap in value.resultMap } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// bundles: [Bundle!]!
      public var regions: [Region]? {
        get {
          return (resultMap["regions"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Region] in value.map { (value: ResultMap) -> Region in Region(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Region]) -> [ResultMap] in value.map { (value: Region) -> ResultMap in value.resultMap } }, forKey: "regions")
        }
      }

      public struct Region: GraphQLSelectionSet {
        public static let possibleTypes = ["RegionDetails"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(RegionDetailsFields.self),
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

          public var regionDetailsFields: RegionDetailsFields {
            get {
              return RegionDetailsFields(unsafeResultMap: resultMap)
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

public final class CreateAddressMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation CreateAddress($input: CreateAddressInput!) {\n  createAddress(input: $input) {\n    __typename\n    address {\n      __typename\n      ...addressFields\n    }\n  }\n}"

  public let operationName = "CreateAddress"

  public var queryDocument: String { return operationDefinition.appending(AddressFields.fragmentDefinition) }

  public var input: CreateAddressInput

  public init(input: CreateAddressInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createAddress", arguments: ["input": GraphQLVariable("input")], type: .object(CreateAddress.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createAddress: CreateAddress? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createAddress": createAddress.flatMap { (value: CreateAddress) -> ResultMap in value.resultMap }])
    }

    public var createAddress: CreateAddress? {
      get {
        return (resultMap["createAddress"] as? ResultMap).flatMap { CreateAddress(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "createAddress")
      }
    }

    public struct CreateAddress: GraphQLSelectionSet {
      public static let possibleTypes = ["CreateAddressPayload"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("address", type: .nonNull(.object(Address.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(address: Address) {
        self.init(unsafeResultMap: ["__typename": "CreateAddressPayload", "address": address.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var address: Address {
        get {
          return Address(unsafeResultMap: resultMap["address"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "address")
        }
      }

      public struct Address: GraphQLSelectionSet {
        public static let possibleTypes = ["Address"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(AddressFields.self),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(address: String, phoneNumber: String) {
          self.init(unsafeResultMap: ["__typename": "Address", "address": address, "phoneNumber": phoneNumber])
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

          public var addressFields: AddressFields {
            get {
              return AddressFields(unsafeResultMap: resultMap)
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

public final class CreateApplicationTokenMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation CreateApplicationToken($input: CreateApplicationTokenInput!) {\n  createApplicationToken(input: $input) {\n    __typename\n    applicationToken {\n      __typename\n      ...applicationTokenFields\n    }\n  }\n}"

  public let operationName = "CreateApplicationToken"

  public var queryDocument: String { return operationDefinition.appending(ApplicationTokenFields.fragmentDefinition) }

  public var input: CreateApplicationTokenInput

  public init(input: CreateApplicationTokenInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createApplicationToken", arguments: ["input": GraphQLVariable("input")], type: .object(CreateApplicationToken.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createApplicationToken: CreateApplicationToken? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createApplicationToken": createApplicationToken.flatMap { (value: CreateApplicationToken) -> ResultMap in value.resultMap }])
    }

    public var createApplicationToken: CreateApplicationToken? {
      get {
        return (resultMap["createApplicationToken"] as? ResultMap).flatMap { CreateApplicationToken(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "createApplicationToken")
      }
    }

    public struct CreateApplicationToken: GraphQLSelectionSet {
      public static let possibleTypes = ["CreateApplicationTokenPayload"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("applicationToken", type: .nonNull(.object(ApplicationToken.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(applicationToken: ApplicationToken) {
        self.init(unsafeResultMap: ["__typename": "CreateApplicationTokenPayload", "applicationToken": applicationToken.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var applicationToken: ApplicationToken {
        get {
          return ApplicationToken(unsafeResultMap: resultMap["applicationToken"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "applicationToken")
        }
      }

      public struct ApplicationToken: GraphQLSelectionSet {
        public static let possibleTypes = ["ApplicationToken"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(ApplicationTokenFields.self),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(token: String, tokenType: String, applicationId: String) {
          self.init(unsafeResultMap: ["__typename": "ApplicationToken", "token": token, "tokenType": tokenType, "applicationID": applicationId])
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

          public var applicationTokenFields: ApplicationTokenFields {
            get {
              return ApplicationTokenFields(unsafeResultMap: resultMap)
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

public final class CreateCustomerMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation CreateCustomer($input: CreateCustomerInput!) {\n  createCustomer(input: $input) {\n    __typename\n    customer {\n      __typename\n      ...customerFields\n    }\n  }\n}"

  public let operationName = "CreateCustomer"

  public var queryDocument: String { return operationDefinition.appending(CustomerFields.fragmentDefinition) }

  public var input: CreateCustomerInput

  public init(input: CreateCustomerInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createCustomer", arguments: ["input": GraphQLVariable("input")], type: .object(CreateCustomer.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createCustomer: CreateCustomer? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createCustomer": createCustomer.flatMap { (value: CreateCustomer) -> ResultMap in value.resultMap }])
    }

    public var createCustomer: CreateCustomer? {
      get {
        return (resultMap["createCustomer"] as? ResultMap).flatMap { CreateCustomer(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "createCustomer")
      }
    }

    public struct CreateCustomer: GraphQLSelectionSet {
      public static let possibleTypes = ["CreateCustomerPayload"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("customer", type: .nonNull(.object(Customer.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(customer: Customer) {
        self.init(unsafeResultMap: ["__typename": "CreateCustomerPayload", "customer": customer.resultMap])
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

      public struct Customer: GraphQLSelectionSet {
        public static let possibleTypes = ["Customer"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(CustomerFields.self),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, contactEmail: String, nickname: String, referralId: String, analyticsId: String) {
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

          public var customerFields: CustomerFields {
            get {
              return CustomerFields(unsafeResultMap: resultMap)
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

public final class CreateJumioScanMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation createJumioScan($input: CreateJumioScanInput!) {\n  createJumioScan(input: $input) {\n    __typename\n    jumioScan {\n      __typename\n      ...jumioScanFields\n    }\n  }\n}"

  public let operationName = "createJumioScan"

  public var queryDocument: String { return operationDefinition.appending(JumioScanFields.fragmentDefinition) }

  public var input: CreateJumioScanInput

  public init(input: CreateJumioScanInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createJumioScan", arguments: ["input": GraphQLVariable("input")], type: .object(CreateJumioScan.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createJumioScan: CreateJumioScan? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createJumioScan": createJumioScan.flatMap { (value: CreateJumioScan) -> ResultMap in value.resultMap }])
    }

    public var createJumioScan: CreateJumioScan? {
      get {
        return (resultMap["createJumioScan"] as? ResultMap).flatMap { CreateJumioScan(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "createJumioScan")
      }
    }

    public struct CreateJumioScan: GraphQLSelectionSet {
      public static let possibleTypes = ["CreateJumioScanPayload"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("jumioScan", type: .nonNull(.object(JumioScan.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(jumioScan: JumioScan) {
        self.init(unsafeResultMap: ["__typename": "CreateJumioScanPayload", "jumioScan": jumioScan.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var jumioScan: JumioScan {
        get {
          return JumioScan(unsafeResultMap: resultMap["jumioScan"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "jumioScan")
        }
      }

      public struct JumioScan: GraphQLSelectionSet {
        public static let possibleTypes = ["JumioScan"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(JumioScanFields.self),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, regionCode: RegionCode) {
          self.init(unsafeResultMap: ["__typename": "JumioScan", "id": id, "regionCode": regionCode])
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

          public var jumioScanFields: JumioScanFields {
            get {
              return JumioScanFields(unsafeResultMap: resultMap)
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

public final class CreatePurchaseMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation CreatePurchase($input: CreatePurchaseInput!) {\n  createPurchase(input: $input) {\n    __typename\n    purchase {\n      __typename\n      ...purchaseFields\n    }\n  }\n}"

  public let operationName = "CreatePurchase"

  public var queryDocument: String { return operationDefinition.appending(PurchaseFields.fragmentDefinition).appending(ProductFields.fragmentDefinition) }

  public var input: CreatePurchaseInput

  public init(input: CreatePurchaseInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createPurchase", arguments: ["input": GraphQLVariable("input")], type: .object(CreatePurchase.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createPurchase: CreatePurchase? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createPurchase": createPurchase.flatMap { (value: CreatePurchase) -> ResultMap in value.resultMap }])
    }

    public var createPurchase: CreatePurchase? {
      get {
        return (resultMap["createPurchase"] as? ResultMap).flatMap { CreatePurchase(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "createPurchase")
      }
    }

    public struct CreatePurchase: GraphQLSelectionSet {
      public static let possibleTypes = ["CreatePurchasePayload"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("purchase", type: .nonNull(.object(Purchase.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(purchase: Purchase) {
        self.init(unsafeResultMap: ["__typename": "CreatePurchasePayload", "purchase": purchase.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var purchase: Purchase {
        get {
          return Purchase(unsafeResultMap: resultMap["purchase"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "purchase")
        }
      }

      public struct Purchase: GraphQLSelectionSet {
        public static let possibleTypes = ["Purchase"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(PurchaseFields.self),
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

          public var purchaseFields: PurchaseFields {
            get {
              return PurchaseFields(unsafeResultMap: resultMap)
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

public final class CreateSimProfileMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation CreateSimProfile($input: CreateSimProfileInput!) {\n  createSimProfile(input: $input) {\n    __typename\n    simProfile {\n      __typename\n      ...simProfileFields\n    }\n  }\n}"

  public let operationName = "CreateSimProfile"

  public var queryDocument: String { return operationDefinition.appending(SimProfileFields.fragmentDefinition) }

  public var input: CreateSimProfileInput

  public init(input: CreateSimProfileInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createSimProfile", arguments: ["input": GraphQLVariable("input")], type: .object(CreateSimProfile.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createSimProfile: CreateSimProfile? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createSimProfile": createSimProfile.flatMap { (value: CreateSimProfile) -> ResultMap in value.resultMap }])
    }

    public var createSimProfile: CreateSimProfile? {
      get {
        return (resultMap["createSimProfile"] as? ResultMap).flatMap { CreateSimProfile(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "createSimProfile")
      }
    }

    public struct CreateSimProfile: GraphQLSelectionSet {
      public static let possibleTypes = ["CreateSimProfilePayload"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("simProfile", type: .nonNull(.object(SimProfile.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(simProfile: SimProfile) {
        self.init(unsafeResultMap: ["__typename": "CreateSimProfilePayload", "simProfile": simProfile.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var simProfile: SimProfile {
        get {
          return SimProfile(unsafeResultMap: resultMap["simProfile"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "simProfile")
        }
      }

      public struct SimProfile: GraphQLSelectionSet {
        public static let possibleTypes = ["SimProfile"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(SimProfileFields.self),
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

          public var simProfileFields: SimProfileFields {
            get {
              return SimProfileFields(unsafeResultMap: resultMap)
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

public final class CustomerQuery: GraphQLQuery {
  public let operationDefinition =
    "query Customer {\n  customer {\n    __typename\n    ...customerFields\n    regions {\n      __typename\n      ...regionDetailsFields\n    }\n  }\n}"

  public let operationName = "Customer"

  public var queryDocument: String { return operationDefinition.appending(CustomerFields.fragmentDefinition).appending(RegionDetailsFields.fragmentDefinition).appending(SimProfileFields.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("customer", type: .object(Customer.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(customer: Customer? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "customer": customer.flatMap { (value: Customer) -> ResultMap in value.resultMap }])
    }

    public var customer: Customer? {
      get {
        return (resultMap["customer"] as? ResultMap).flatMap { Customer(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "customer")
      }
    }

    public struct Customer: GraphQLSelectionSet {
      public static let possibleTypes = ["Customer"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(CustomerFields.self),
        GraphQLField("regions", type: .list(.nonNull(.object(Region.selections)))),
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

      /// bundles: [Bundle!]!
      public var regions: [Region]? {
        get {
          return (resultMap["regions"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Region] in value.map { (value: ResultMap) -> Region in Region(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Region]) -> [ResultMap] in value.map { (value: Region) -> ResultMap in value.resultMap } }, forKey: "regions")
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

        public var customerFields: CustomerFields {
          get {
            return CustomerFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Region: GraphQLSelectionSet {
        public static let possibleTypes = ["RegionDetails"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(RegionDetailsFields.self),
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

          public var regionDetailsFields: RegionDetailsFields {
            get {
              return RegionDetailsFields(unsafeResultMap: resultMap)
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

public final class DeleteCustomerMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation DeleteCustomer {\n  deleteCustomer {\n    __typename\n    customer {\n      __typename\n      ...customerFields\n    }\n  }\n}"

  public let operationName = "DeleteCustomer"

  public var queryDocument: String { return operationDefinition.appending(CustomerFields.fragmentDefinition) }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteCustomer", type: .object(DeleteCustomer.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteCustomer: DeleteCustomer? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteCustomer": deleteCustomer.flatMap { (value: DeleteCustomer) -> ResultMap in value.resultMap }])
    }

    public var deleteCustomer: DeleteCustomer? {
      get {
        return (resultMap["deleteCustomer"] as? ResultMap).flatMap { DeleteCustomer(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "deleteCustomer")
      }
    }

    public struct DeleteCustomer: GraphQLSelectionSet {
      public static let possibleTypes = ["DeleteCustomerPayload"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("customer", type: .nonNull(.object(Customer.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(customer: Customer) {
        self.init(unsafeResultMap: ["__typename": "DeleteCustomerPayload", "customer": customer.resultMap])
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

      public struct Customer: GraphQLSelectionSet {
        public static let possibleTypes = ["Customer"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(CustomerFields.self),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, contactEmail: String, nickname: String, referralId: String, analyticsId: String) {
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

          public var customerFields: CustomerFields {
            get {
              return CustomerFields(unsafeResultMap: resultMap)
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

public final class ResendEmailQuery: GraphQLQuery {
  public let operationDefinition =
    "query resendEmail($input: ResendEmailInput!) {\n  resendEmail(input: $input) {\n    __typename\n    simProfile {\n      __typename\n      ...simProfileFields\n    }\n  }\n}"

  public let operationName = "resendEmail"

  public var queryDocument: String { return operationDefinition.appending(SimProfileFields.fragmentDefinition) }

  public var input: ResendEmailInput

  public init(input: ResendEmailInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("resendEmail", arguments: ["input": GraphQLVariable("input")], type: .object(ResendEmail.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(resendEmail: ResendEmail? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "resendEmail": resendEmail.flatMap { (value: ResendEmail) -> ResultMap in value.resultMap }])
    }

    public var resendEmail: ResendEmail? {
      get {
        return (resultMap["resendEmail"] as? ResultMap).flatMap { ResendEmail(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "resendEmail")
      }
    }

    public struct ResendEmail: GraphQLSelectionSet {
      public static let possibleTypes = ["ResendEmailPayload"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("simProfile", type: .nonNull(.object(SimProfile.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(simProfile: SimProfile) {
        self.init(unsafeResultMap: ["__typename": "ResendEmailPayload", "simProfile": simProfile.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var simProfile: SimProfile {
        get {
          return SimProfile(unsafeResultMap: resultMap["simProfile"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "simProfile")
        }
      }

      public struct SimProfile: GraphQLSelectionSet {
        public static let possibleTypes = ["SimProfile"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(SimProfileFields.self),
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

          public var simProfileFields: SimProfileFields {
            get {
              return SimProfileFields(unsafeResultMap: resultMap)
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

public final class SimProfilesForRegionQuery: GraphQLQuery {
  public let operationDefinition =
    "query SimProfilesForRegion($regionCode: RegionCode!) {\n  customer {\n    __typename\n    regions(regionCode: $regionCode) {\n      __typename\n      simProfiles {\n        __typename\n        ...simProfileFields\n      }\n    }\n  }\n}"

  public let operationName = "SimProfilesForRegion"

  public var queryDocument: String { return operationDefinition.appending(SimProfileFields.fragmentDefinition) }

  public var regionCode: RegionCode

  public init(regionCode: RegionCode) {
    self.regionCode = regionCode
  }

  public var variables: GraphQLMap? {
    return ["regionCode": regionCode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("customer", type: .object(Customer.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(customer: Customer? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "customer": customer.flatMap { (value: Customer) -> ResultMap in value.resultMap }])
    }

    public var customer: Customer? {
      get {
        return (resultMap["customer"] as? ResultMap).flatMap { Customer(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "customer")
      }
    }

    public struct Customer: GraphQLSelectionSet {
      public static let possibleTypes = ["Customer"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("regions", arguments: ["regionCode": GraphQLVariable("regionCode")], type: .list(.nonNull(.object(Region.selections)))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(regions: [Region]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Customer", "regions": regions.flatMap { (value: [Region]) -> [ResultMap] in value.map { (value: Region) -> ResultMap in value.resultMap } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// bundles: [Bundle!]!
      public var regions: [Region]? {
        get {
          return (resultMap["regions"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Region] in value.map { (value: ResultMap) -> Region in Region(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Region]) -> [ResultMap] in value.map { (value: Region) -> ResultMap in value.resultMap } }, forKey: "regions")
        }
      }

      public struct Region: GraphQLSelectionSet {
        public static let possibleTypes = ["RegionDetails"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("simProfiles", type: .list(.nonNull(.object(SimProfile.selections)))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(simProfiles: [SimProfile]? = nil) {
          self.init(unsafeResultMap: ["__typename": "RegionDetails", "simProfiles": simProfiles.flatMap { (value: [SimProfile]) -> [ResultMap] in value.map { (value: SimProfile) -> ResultMap in value.resultMap } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var simProfiles: [SimProfile]? {
          get {
            return (resultMap["simProfiles"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [SimProfile] in value.map { (value: ResultMap) -> SimProfile in SimProfile(unsafeResultMap: value) } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [SimProfile]) -> [ResultMap] in value.map { (value: SimProfile) -> ResultMap in value.resultMap } }, forKey: "simProfiles")
          }
        }

        public struct SimProfile: GraphQLSelectionSet {
          public static let possibleTypes = ["SimProfile"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(SimProfileFields.self),
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

            public var simProfileFields: SimProfileFields {
              get {
                return SimProfileFields(unsafeResultMap: resultMap)
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

public final class ValidateNricQuery: GraphQLQuery {
  public let operationDefinition =
    "query ValidateNric($input: ValidateNricInput!) {\n  validateNric(input: $input) {\n    __typename\n    nric {\n      __typename\n      ...nricInfoFields\n    }\n  }\n}"

  public let operationName = "ValidateNric"

  public var queryDocument: String { return operationDefinition.appending(NricInfoFields.fragmentDefinition) }

  public var input: ValidateNricInput

  public init(input: ValidateNricInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("validateNric", arguments: ["input": GraphQLVariable("input")], type: .object(ValidateNric.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(validateNric: ValidateNric? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "validateNric": validateNric.flatMap { (value: ValidateNric) -> ResultMap in value.resultMap }])
    }

    /// TODO: Does not look like queries should have a payload like mutations, rather the direct type
    public var validateNric: ValidateNric? {
      get {
        return (resultMap["validateNric"] as? ResultMap).flatMap { ValidateNric(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "validateNric")
      }
    }

    public struct ValidateNric: GraphQLSelectionSet {
      public static let possibleTypes = ["ValidateNricPayload"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("nric", type: .nonNull(.object(Nric.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(nric: Nric) {
        self.init(unsafeResultMap: ["__typename": "ValidateNricPayload", "nric": nric.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var nric: Nric {
        get {
          return Nric(unsafeResultMap: resultMap["nric"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "nric")
        }
      }

      public struct Nric: GraphQLSelectionSet {
        public static let possibleTypes = ["NricInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(NricInfoFields.self),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(value: String) {
          self.init(unsafeResultMap: ["__typename": "NricInfo", "value": value])
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

          public var nricInfoFields: NricInfoFields {
            get {
              return NricInfoFields(unsafeResultMap: resultMap)
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

public struct ProductFields: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment productFields on Product {\n  __typename\n  sku\n  price {\n    __typename\n    amount\n    currency\n  }\n  presentation {\n    __typename\n    payeeLabel\n    priceLabel\n    productLabel\n    subTotal\n    subTotalLabel\n    tax\n    taxLabel\n  }\n  properties {\n    __typename\n    productClass\n  }\n}"

  public static let possibleTypes = ["Product"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("sku", type: .nonNull(.scalar(String.self))),
    GraphQLField("price", type: .nonNull(.object(Price.selections))),
    GraphQLField("presentation", type: .nonNull(.object(Presentation.selections))),
    GraphQLField("properties", type: .nonNull(.object(Property.selections))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(sku: String, price: Price, presentation: Presentation, properties: Property) {
    self.init(unsafeResultMap: ["__typename": "Product", "sku": sku, "price": price.resultMap, "presentation": presentation.resultMap, "properties": properties.resultMap])
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

  public var presentation: Presentation {
    get {
      return Presentation(unsafeResultMap: resultMap["presentation"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "presentation")
    }
  }

  public var properties: Property {
    get {
      return Property(unsafeResultMap: resultMap["properties"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "properties")
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

  public struct Presentation: GraphQLSelectionSet {
    public static let possibleTypes = ["Presentation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("payeeLabel", type: .scalar(String.self)),
      GraphQLField("priceLabel", type: .nonNull(.scalar(String.self))),
      GraphQLField("productLabel", type: .nonNull(.scalar(String.self))),
      GraphQLField("subTotal", type: .scalar(String.self)),
      GraphQLField("subTotalLabel", type: .scalar(String.self)),
      GraphQLField("tax", type: .scalar(String.self)),
      GraphQLField("taxLabel", type: .scalar(String.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(payeeLabel: String? = nil, priceLabel: String, productLabel: String, subTotal: String? = nil, subTotalLabel: String? = nil, tax: String? = nil, taxLabel: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "Presentation", "payeeLabel": payeeLabel, "priceLabel": priceLabel, "productLabel": productLabel, "subTotal": subTotal, "subTotalLabel": subTotalLabel, "tax": tax, "taxLabel": taxLabel])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var payeeLabel: String? {
      get {
        return resultMap["payeeLabel"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "payeeLabel")
      }
    }

    public var priceLabel: String {
      get {
        return resultMap["priceLabel"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "priceLabel")
      }
    }

    public var productLabel: String {
      get {
        return resultMap["productLabel"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "productLabel")
      }
    }

    public var subTotal: String? {
      get {
        return resultMap["subTotal"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "subTotal")
      }
    }

    public var subTotalLabel: String? {
      get {
        return resultMap["subTotalLabel"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "subTotalLabel")
      }
    }

    public var tax: String? {
      get {
        return resultMap["tax"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "tax")
      }
    }

    public var taxLabel: String? {
      get {
        return resultMap["taxLabel"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "taxLabel")
      }
    }
  }

  public struct Property: GraphQLSelectionSet {
    public static let possibleTypes = ["Properties"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("productClass", type: .scalar(String.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(productClass: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "Properties", "productClass": productClass])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var productClass: String? {
      get {
        return resultMap["productClass"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "productClass")
      }
    }
  }
}

public struct PurchaseFields: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment purchaseFields on Purchase {\n  __typename\n  id\n  product {\n    __typename\n    ...productFields\n  }\n  timestamp\n}"

  public static let possibleTypes = ["Purchase"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("product", type: .nonNull(.object(Product.selections))),
    GraphQLField("timestamp", type: .nonNull(.scalar(Long.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: GraphQLID, product: Product, timestamp: Long) {
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

  public var id: GraphQLID {
    get {
      return resultMap["id"]! as! GraphQLID
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
      GraphQLFragmentSpread(ProductFields.self),
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

      public var productFields: ProductFields {
        get {
          return ProductFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }
}

public struct AddressFields: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment addressFields on Address {\n  __typename\n  address\n  phoneNumber\n}"

  public static let possibleTypes = ["Address"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("address", type: .nonNull(.scalar(String.self))),
    GraphQLField("phoneNumber", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(address: String, phoneNumber: String) {
    self.init(unsafeResultMap: ["__typename": "Address", "address": address, "phoneNumber": phoneNumber])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var address: String {
    get {
      return resultMap["address"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "address")
    }
  }

  public var phoneNumber: String {
    get {
      return resultMap["phoneNumber"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "phoneNumber")
    }
  }
}

public struct ApplicationTokenFields: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment applicationTokenFields on ApplicationToken {\n  __typename\n  token\n  tokenType\n  applicationID\n}"

  public static let possibleTypes = ["ApplicationToken"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("token", type: .nonNull(.scalar(String.self))),
    GraphQLField("tokenType", type: .nonNull(.scalar(String.self))),
    GraphQLField("applicationID", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(token: String, tokenType: String, applicationId: String) {
    self.init(unsafeResultMap: ["__typename": "ApplicationToken", "token": token, "tokenType": tokenType, "applicationID": applicationId])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var token: String {
    get {
      return resultMap["token"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "token")
    }
  }

  public var tokenType: String {
    get {
      return resultMap["tokenType"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "tokenType")
    }
  }

  public var applicationId: String {
    get {
      return resultMap["applicationID"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "applicationID")
    }
  }
}

public struct JumioScanFields: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment jumioScanFields on JumioScan {\n  __typename\n  id\n  regionCode\n}"

  public static let possibleTypes = ["JumioScan"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("regionCode", type: .nonNull(.scalar(RegionCode.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: GraphQLID, regionCode: RegionCode) {
    self.init(unsafeResultMap: ["__typename": "JumioScan", "id": id, "regionCode": regionCode])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var id: GraphQLID {
    get {
      return resultMap["id"]! as! GraphQLID
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var regionCode: RegionCode {
    get {
      return resultMap["regionCode"]! as! RegionCode
    }
    set {
      resultMap.updateValue(newValue, forKey: "regionCode")
    }
  }
}

public struct RegionDetailsFields: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment regionDetailsFields on RegionDetails {\n  __typename\n  region {\n    __typename\n    id\n    name\n  }\n  status\n  kycStatusMap {\n    __typename\n    JUMIO\n    MY_INFO\n    NRIC_FIN\n    ADDRESS_AND_PHONE_NUMBER\n  }\n  simProfiles {\n    __typename\n    ...simProfileFields\n  }\n}"

  public static let possibleTypes = ["RegionDetails"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("region", type: .nonNull(.object(Region.selections))),
    GraphQLField("status", type: .nonNull(.scalar(CustomerRegionStatus.self))),
    GraphQLField("kycStatusMap", type: .nonNull(.object(KycStatusMap.selections))),
    GraphQLField("simProfiles", type: .list(.nonNull(.object(SimProfile.selections)))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(region: Region, status: CustomerRegionStatus, kycStatusMap: KycStatusMap, simProfiles: [SimProfile]? = nil) {
    self.init(unsafeResultMap: ["__typename": "RegionDetails", "region": region.resultMap, "status": status, "kycStatusMap": kycStatusMap.resultMap, "simProfiles": simProfiles.flatMap { (value: [SimProfile]) -> [ResultMap] in value.map { (value: SimProfile) -> ResultMap in value.resultMap } }])
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

  public var status: CustomerRegionStatus {
    get {
      return resultMap["status"]! as! CustomerRegionStatus
    }
    set {
      resultMap.updateValue(newValue, forKey: "status")
    }
  }

  public var kycStatusMap: KycStatusMap {
    get {
      return KycStatusMap(unsafeResultMap: resultMap["kycStatusMap"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "kycStatusMap")
    }
  }

  public var simProfiles: [SimProfile]? {
    get {
      return (resultMap["simProfiles"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [SimProfile] in value.map { (value: ResultMap) -> SimProfile in SimProfile(unsafeResultMap: value) } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [SimProfile]) -> [ResultMap] in value.map { (value: SimProfile) -> ResultMap in value.resultMap } }, forKey: "simProfiles")
    }
  }

  public struct Region: GraphQLSelectionSet {
    public static let possibleTypes = ["Region"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
      GraphQLField("name", type: .nonNull(.scalar(String.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: GraphQLID, name: String) {
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

    public var id: GraphQLID {
      get {
        return resultMap["id"]! as! GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    /// To keep ID field consistent, it needs to have the same field name and same
    /// field type and that conflicts if we want to use Enums like RegionCode. Better
    /// make a separate field to handle this
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
      GraphQLFragmentSpread(SimProfileFields.self),
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

      public var simProfileFields: SimProfileFields {
        get {
          return SimProfileFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }
}

public struct CustomerFields: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment customerFields on Customer {\n  __typename\n  id\n  contactEmail\n  nickname\n  referralId\n  analyticsId\n}"

  public static let possibleTypes = ["Customer"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
    GraphQLField("contactEmail", type: .nonNull(.scalar(String.self))),
    GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
    GraphQLField("referralId", type: .nonNull(.scalar(String.self))),
    GraphQLField("analyticsId", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: GraphQLID, contactEmail: String, nickname: String, referralId: String, analyticsId: String) {
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

  public var id: GraphQLID {
    get {
      return resultMap["id"]! as! GraphQLID
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

public struct SimProfileFields: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment simProfileFields on SimProfile {\n  __typename\n  eSimActivationCode\n  alias\n  iccId\n  status\n}"

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

public struct NricInfoFields: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment nricInfoFields on NricInfo {\n  __typename\n  value\n}"

  public static let possibleTypes = ["NricInfo"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("value", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(value: String) {
    self.init(unsafeResultMap: ["__typename": "NricInfo", "value": value])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var value: String {
    get {
      return resultMap["value"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "value")
    }
  }
}
