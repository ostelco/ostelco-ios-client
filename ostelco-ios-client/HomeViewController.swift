//
//  HomeViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import Siesta
import SiestaUI
import Foundation
import os
import Stripe
import Netverify
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController, ResourceObserver, PKPaymentAuthorizationViewControllerDelegate {

  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var balanceText: UILabel!
  @IBOutlet weak var productButton: UIButton!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var eKYCScanButton: UIButton!

  var paymentSucceeded = false;
  var product: ProductModel?;

  @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
    ostelcoAPI.bundles.load().onCompletion({_ in
      refreshControl.endRefreshing()
    })
  }

  // TODO: Customize text in status overlay to reflect error message
  let statusOverlay = ResourceStatusOverlay()

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    ostelcoAPI.bundles.loadIfNeeded()
    ostelcoAPI.products.loadIfNeeded()
  }

  override func viewDidLayoutSubviews() {
    statusOverlay.positionToCoverParent()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    balanceLabel.isHidden = true
    balanceLabel.textColor = ThemeManager.currentTheme().mainColor
    balanceText.textColor = ThemeManager.currentTheme().mainColor

    productButton.isHidden = true

    statusOverlay.embed(in: self)

    // TODO: Figure out how to handle case where bundles API fails
    ostelcoAPI.bundles
      .addObserver(self)
      .addObserver(statusOverlay)

    // TODO: Figure out how to handle case where products API fails
    ostelcoAPI.products
      .addObserver(self)
      .addObserver(statusOverlay)

    let refreshControl = scrollView.addRefreshControl(target: self,
                                                      action: #selector(handleRefresh(_:)))
    refreshControl.tintColor = ThemeManager.currentTheme().mainColor

    refreshControl.attributedTitle =
      NSAttributedString(string: "Refresh balance",
                         attributes: [
                          NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().mainColor,
                          NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-UltraLight",
                                                              size: 36.0)! ])
    self.scrollView.alwaysBounceVertical = true
  }

  func converByteToGB(_ bytes:Int64) -> String {
    let formatter:ByteCountFormatter = ByteCountFormatter()
    formatter.countStyle = .decimal
    formatter.zeroPadsFractionDigits = true
    return formatter.string(fromByteCount: Int64(bytes))
  }

  func resourceChanged(_ resource: Resource, event: ResourceEvent) {

    // TODO: Handle below errors in a better way
    guard let bundles = resource.jsonArray as? [BundleModel] else {
      // print("Error: Could not cast response to model...")

      guard var products = resource.jsonArray as? [ProductModel] else {
        // print("Error: Could not cast response to model...")
        productButton.isHidden = true
        return
      }

      dump(products)

      products = products.filter { $0.presentation.isDefault == "true" }

      dump(products)

      if products.count < 1 {
        print("Error: Could not find a default product.")
        productButton.isHidden = true
      } else {
        product = products[0]
        productButton.setTitle("\(product!.presentation.label) \(product!.presentation.price)", for: .normal)
        productButton.isHidden = false
      }
      return
    }

    if bundles.count < 1 {
      print("Error: Could not find any bundles")
      balanceLabel.text = "?"
    } else {
      let bundle = bundles[0]
      balanceLabel.text = self.converByteToGB(bundle.balance)
    }
    balanceLabel.isHidden = false
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func topUp(_ sender: Any) {
    self.handleApplePayButtonTapped();
  }

  @IBAction func start_eKYCScan(_ sender: Any) {
    self.startNetverify();
  }

  func handleApplePayButtonTapped() {

    let merchantIdentifier = Environment().configuration(.AppleMerchantId)
    os_log("Merchant identifier: %{public}@ country: SG currency: %{public}@ label: %{public}@ amount: %{public}@", merchantIdentifier, product!.price.currency, product!.presentation.label, "\(product!.price.amount)")
    let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: "SG", currency: product!.price.currency)

    os_log("device supports apple pay: %{public}@", "\(Stripe.deviceSupportsApplePay())")
    os_log("can make payment: %{public}@", "\(PKPaymentAuthorizationViewController.canMakePayments())")

    if (!Stripe.deviceSupportsApplePay()) {
      self.showAlert(title: "Payment Error", msg: "Device not supported.")
      return
    }
    if (!PKPaymentAuthorizationViewController.canMakePayments()) {
      self.showAlert(title: "Payment Error", msg: "Wallet empty or does not contain any of the supported card types. Should give user option to open apple wallet to add a card.")
      return
    }
    // Configure the line items on the payment request
    paymentRequest.paymentSummaryItems = [
      PKPaymentSummaryItem(label: self.product!.presentation.label, amount: Decimal(Double(self.product!.price.amount) / 100.0) as NSDecimalNumber),
      // The final line should represent your company;
      // it'll be prepended with the word "Pay" (i.e. "Pay iHats, Inc $50")
      // PKPaymentSummaryItem(label: "iHats, Inc", amount: 50.00),
    ]

    // Continued in next step
    if Stripe.canSubmitPaymentRequest(paymentRequest) {
      // Setup payment authorization view controller
      let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
      paymentAuthorizationViewController!.delegate = self

      // Present payment authorization view controller
      present(paymentAuthorizationViewController!, animated: true)
    }
    else {
      // There is a problem with your Apple Pay configuration
      os_log("There is a problem with your Apple Pay configuration")
      // TODO: Report error to bug reporting system
      #if DEBUG
      #if targetEnvironment(simulator)
      self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay in test mode on simulator is supposed to work. Don't know why it failed.")
      #else
      self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay in test mode on real devices has not been tested yet.")
      #endif
      #else
      #if targetEnvironment(simulator)
      self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay in production mode on simulator does not work.")
      #else
      self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay in production mode failed for unknown reason.")
      #endif
      #endif
    }
  }

  func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
    STPAPIClient.shared().createSource(with: payment) { (source: STPSource?, error: Error?) in
      guard let source = source, error == nil else {
        // Present error to user...
        self.showAlert(title: "Failed to create stripe source", msg: "\(error!.localizedDescription)")
        return
      }

      ostelcoAPI.products.child(self.product!.sku).child("purchase").withParam("sourceId", source.stripeID).request(.post)
        .onProgress({ progress in
          os_log("Progress %{public}@", "\(progress)")
        })
        .onSuccess({ result in
          os_log("Successfully bought a product %{public}@", "\(result)")
          ostelcoAPI.purchases.invalidate()
          ostelcoAPI.bundles.invalidate()
          ostelcoAPI.bundles.load()
          self.paymentSucceeded = true
          completion(.success)
        })
        .onFailure({ error in
          // TODO: Report error to server
          // TODO: fix use of insecure unwrapping, can cause application to crash
          os_log("Failed to buy product with sku %{public}@, got error: %{public}@", self.product!.sku, "\(error)")
          self.showAlert(title: "Failed to buy product with ostelcoAPI", msg: "\(error.localizedDescription)")
          self.paymentSucceeded = false
          completion(.failure)
        })
        .onCompletion({ _ in
          // UIViewController.removeSpinner(spinner: sv)
        })
    }
  }

  func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
    // Dismiss payment authorization view controller
    dismiss(animated: true, completion: {
      if (self.paymentSucceeded) {
        // Show a receipt page...
        os_log("Show receipt page?")
      }
    })
  }

  @IBAction func lastScanStatus(_ sender: Any) {
    let scanStatus = ostelcoAPI.scanStatus(scanId: self.merchantScanReference)
    scanStatus.load().onCompletion { info in
      guard let scanInformation = scanStatus.latestData?.content as? ScanInformation else {
        os_log("Resource changed but returned data was empty for ScanInformation.")
        print("Resource changed but returned data was empty for ScanInformation. \(String(describing: (scanStatus.latestData)))")
        return
      }
      print("Scan Information =", scanInformation.scanId, scanInformation.status)
      self.showAlert(title: "Scan Information", msg: "Scan Id: \(scanInformation.scanId) \nScan Status:\(scanInformation.status)")
    }
  }



  func startNetverify() -> Void {
    getnewScanId() { (scanId, error) in
      if let scanId: String = scanId {
        print("Retrieved \(scanId)")
        self.merchantScanReference = scanId
        self.createNetverifyController()
        if let netverifyVC = self.netverifyViewController {
          self.present(netverifyVC, animated: true, completion: nil)
        } else {
          self.showAlert(title: "Netverify Mobile SDK", msg: "NetverifyViewController is nil")
        }
      } else if let error: Error = error {
        print("Error received \(error)")
      }
    }
  }

  var netverifyViewController:NetverifyViewController?
  var customUIController:NetverifyUIController?
  var merchantScanReference:String = "240296a9-88d6-4979-820a-a227985d1a9f"

}

extension HomeViewController: NetverifyViewControllerDelegate {
  func getnewScanId(_ completion: @escaping (String?, Error?) -> Void) {
    let baseUrl = Environment().configuration(PlistKey.ServerURL)
    let newScanIdUrl = "\(baseUrl)/customer/new-ekyc-scanId/sgp"
    let headers: HTTPHeaders = [
      "Authorization": ostelcoAPI.authToken!,
      "Accept": "application/json"
    ]

    AF.request(newScanIdUrl, method: .get, headers: headers)
      .validate(statusCode: 200..<300)
      .responseData { response in
        switch response.result {
        case .success:
          print("Validation Successful")
          let decoder = JSONDecoder()
          do {
            let data = try decoder.decode(ScanInformation.self, from: response.data!)
            print("Data: \(data)")
          } catch {
            print("Data decoding error: \(error)")
          }
          let json = JSON(response.data ?? Data())
          print("\(json)")
          completion(json["scanId"].string, nil)
        case .failure(let error):
          print(error)
          completion(nil, error)
        }
    }
  }
  func createNetverifyConfiguration() -> NetverifyConfiguration {
    let config:NetverifyConfiguration = NetverifyConfiguration()
    //Provide your API token
    config.merchantApiToken = "xxxx"
    //Provide your API secret
    config.merchantApiSecret = "xxxx"

    config.merchantScanReference = self.merchantScanReference

    config.requireVerification = true

    //You can enable face match during the ID verification for a specific transaction. This setting overrides your default Jumio merchant settings.
    config.requireFaceMatch = true

    //You can get the current SDK version using the method below.
    print("\(self.netverifyViewController?.sdkVersion() ?? "")")

    return config
  }

  func createNetverifyController() -> Void {

    //prevent SDK to be initialized on Jailbroken devices
    if JMDeviceInfo.isJailbrokenDevice() {
      return
    }

    //Setup the Configuration for Netverify
    let config:NetverifyConfiguration = createNetverifyConfiguration()
    //Set the delegate that implements NetverifyViewControllerDelegate
    config.delegate = self

    //Perform the following call as soon as your app’s view controller is initialized. Create the NetverifyViewController instance by providing your Configuration with required merchant API token, merchant API secret and a delegate object.


    self.netverifyViewController = NetverifyViewController(configuration: config)
    if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
      self.netverifyViewController?.modalPresentationStyle = UIModalPresentationStyle.formSheet;  // For iPad, present from sheet
    }
  }
  func netverifyViewController(_ netverifyViewController: NetverifyViewController, didFinishWith documentData: NetverifyDocumentData, scanReference: String) {
    print("NetverifyViewController finished successfully with scan reference: %@", scanReference);
    let selectedCountry:String = documentData.selectedCountry
    let selectedDocumentType:NetverifyDocumentType = documentData.selectedDocumentType
    var documentTypeStr:String
    switch (selectedDocumentType) {
    case .driverLicense:
      documentTypeStr = "DL"
      break;
    case .identityCard:
      documentTypeStr = "ID"
      break;
    case .passport:
      documentTypeStr = "PP"
      break;
    case .visa:
      documentTypeStr = "Visa"
      break;
    default:
      documentTypeStr = ""
      break;
    }

    //id
    let idNumber:String? = documentData.idNumber
    let personalNumber:String? = documentData.personalNumber
    let issuingDate:Date? = documentData.issuingDate
    let expiryDate:Date? = documentData.expiryDate
    let issuingCountry:String? = documentData.issuingCountry
    let optionalData1:String? = documentData.optionalData1
    let optionalData2:String? = documentData.optionalData2

    //person
    let lastName:String? = documentData.lastName
    let firstName:String? = documentData.firstName
    let dateOfBirth:Date? = documentData.dob
    let gender:NetverifyGender = documentData.gender
    var genderStr:String;
    switch (gender) {
    case .unknown:
      genderStr = "Unknown"

    case .F:
      genderStr = "female"

    case .M:
      genderStr = "male"

    case .X:
      genderStr = "Unspecified"

    default:
      genderStr = "Unknown"
    }

    let originatingCountry:String? = documentData.originatingCountry

    //address
    let street:String? = documentData.addressLine
    let city:String? = documentData.city
    let state:String? = documentData.subdivision
    let postalCode:String? = documentData.postCode

    // Raw MRZ data
    let mrzData:NetverifyMrzData? = documentData.mrzData

    let message:NSMutableString = NSMutableString.init()
    message.appendFormat("Selected Country: %@", selectedCountry)
    message.appendFormat("\nDocument Type: %@", documentTypeStr)
    if (idNumber != nil) { message.appendFormat("\nID Number: %@", idNumber!) }
    if (personalNumber != nil) { message.appendFormat("\nPersonal Number: %@", personalNumber!) }
    if (issuingDate != nil) { message.appendFormat("\nIssuing Date: %@", issuingDate! as CVarArg) }
    if (expiryDate != nil) { message.appendFormat("\nExpiry Date: %@", expiryDate! as CVarArg) }
    if (issuingCountry != nil) { message.appendFormat("\nIssuing Country: %@", issuingCountry!) }
    if (optionalData1 != nil) { message.appendFormat("\nOptional Data 1: %@", optionalData1!) }
    if (optionalData2 != nil) { message.appendFormat("\nOptional Data 2: %@", optionalData2!) }
    if (lastName != nil) { message.appendFormat("\nLast Name: %@", lastName!) }
    if (firstName != nil) { message.appendFormat("\nFirst Name: %@", firstName!) }
    if (dateOfBirth != nil) { message.appendFormat("\ndob: %@", dateOfBirth! as CVarArg) }
    message.appendFormat("\nGender: %@", genderStr)
    if (originatingCountry != nil) { message.appendFormat("\nOriginating Country: %@", originatingCountry!) }
    if (street != nil) { message.appendFormat("\nStreet: %@", street!) }
    if (city != nil) { message.appendFormat("\nCity: %@", city!) }
    if (state != nil) { message.appendFormat("\nState: %@", state!) }
    if (postalCode != nil) { message.appendFormat("\nPostal Code: %@", postalCode!) }
    if (mrzData != nil) {
      if (mrzData?.line1 != nil) {
        message.appendFormat("\nMRZ Data: %@\n", (mrzData?.line1)!)
      }
      if (mrzData?.line2 != nil) {
        message.appendFormat("%@\n", (mrzData?.line2)!)
      }
      if (mrzData?.line3 != nil) {
        message.appendFormat("%@\n", (mrzData?.line3)!)
      }
    }
    self.dismiss(animated: true, completion: {
      print(message)
      self.showAlert(title: "Netverify Mobile SDK", msg: message as String)
      self.netverifyViewController?.destroy()
      self.netverifyViewController = nil
    })
  }

  func netverifyViewController(_ netverifyViewController: NetverifyViewController, didCancelWithError error: NetverifyError?, scanReference: String?) {
    print("NetverifyViewController cancelled with error: " + "\(error?.message ?? "")" + "scanReference: " + "\(scanReference ?? "")")
    //Dismiss the SDK
    self.dismiss(animated: true) {
      self.netverifyViewController?.destroy()
      self.netverifyViewController = nil
    }
  }
}
