//
//  MyInfoSummaryViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 27/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyInfoSummaryViewController: UIViewController {
    public var myInfoQueryItems: [URLQueryItem]?
    var spinnerView: UIView?
    var myInfoDetails: MyInfoDetails?

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var sex: UILabel!
    @IBOutlet weak var dob: UILabel!
    @IBOutlet weak var nationality: UILabel!
    @IBOutlet weak var residentialStatus: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var mobileNumber: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("Query Items: \(String(describing: myInfoQueryItems))")
        spinnerView = self.showSpinner(onView: self.view)
        if let code = getMyInfoCode() {
            print("Code = \(code)")
            APIManager.sharedInstance.regions.child("/sg/kyc/myInfo").child(code).load()
                .onSuccess { entity in
                    DispatchQueue.main.async {
                        if let myInfoDetails: MyInfoDetails = entity.typedContent(ifNone: nil) {
                            self.myInfoDetails = myInfoDetails
                            self.updateUI(myInfoDetails)
                        }
                        self.removeSpinner(self.spinnerView)
                    }
                }
                .onFailure { error in
                    DispatchQueue.main.async {
                        self.removeSpinner(self.spinnerView)
                        self.showAPIError(error: error)
                    }
            }
        }
        //TODO: Pass the code we retrieved to PRIME
        //TODO: Get the address & phone number form PRIME
        updateUI(getTempData()) // TODO: Remove this when API is stable.
    }

    private func getMyInfoCode() -> String? {
        if let queryItems = myInfoQueryItems {
            if let codeItem = queryItems.first(where: { $0.name == "code" }) {
                return codeItem.value
            }
        }
        return nil
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "editAddress", let destination: MyInfoAddressTableViewController = segue.destination as? MyInfoAddressTableViewController {
            destination.myInfoDetails = self.myInfoDetails
            destination.updateDelegate = self
        }
    }

    @IBAction func `continue`(_ sender: Any) {
        spinnerView = self.showSpinner(onView: self.view)
        APIManager.sharedInstance.regions.child("/sg/kyc/profile")
            .withParam("address", address.text!)
            .withParam("phoneNumber", myInfoDetails!.mobileNumber!).request(.put)
            .onSuccess { _ in
                DispatchQueue.main.async {
                    self.removeSpinner(self.spinnerView)
                    self.performSegue(withIdentifier: "ESim", sender: self)
                }
            }
            .onFailure { error in
                DispatchQueue.main.async {
                    self.removeSpinner(self.spinnerView)
                    self.showAPIError(error: error)
                }
        }
    }

    func updateUI(_ myInfoDetails: MyInfoDetails?) {
        guard let myInfoDetails = myInfoDetails else {
            return
        }
        name.text = myInfoDetails.name
        dob.text = myInfoDetails.dob
        address.text = "\(myInfoDetails.address.getAddressLine1())\n\(myInfoDetails.address.getAddressLine2())"
        if let nationality = myInfoDetails.nationality {
            self.nationality.text = nationality
        }
        if let residentialStatus = myInfoDetails.residentialStatus {
            self.residentialStatus.text = residentialStatus
        }
        if let mobileNumber = myInfoDetails.mobileNumber {
            self.mobileNumber.text = mobileNumber
        }
        if let sex = myInfoDetails.sex {
            self.sex.text = sex
        }
    }
}

extension MyInfoSummaryViewController: MyInfoDetailsUpdate {
    func handleUpdate(myInfoDetails: MyInfoDetails) {
        self.myInfoDetails = myInfoDetails
    }
}

// TODO: Remove this when API is stable.
func getTempData() -> MyInfoDetails? {
    let testData = """
{
    "name": {
        "lastupdated": "2018-03-20",
        "source": "1",
        "classification": "C",
        "value": "TAN XIAO HUI"
    },
    "sex": {
        "lastupdated": "2018-03-20",
        "source": "1",
        "classification": "C",
        "value": "F"
    },
    "dob": {
        "lastupdated": "2018-03-20",
        "source": "1",
        "classification": "C",
        "value": "1970-05-17"
    },
    "residentialstatus": {
        "lastupdated": "2018-03-23",
        "source": "1",
        "classification": "C",
        "value": "C"
    },
    "nationality": {
        "lastupdated": "2018-03-20",
        "source": "1",
        "classification": "C",
        "value": "SG"
    },
    "mobileno": {
        "lastupdated": "2018-08-23",
        "code": "65",
        "source": "4",
        "classification": "C",
        "prefix": "+",
        "nbr": "97399245"
    },
    "email": {
        "lastupdated": "2018-08-23",
        "source": "4",
        "classification": "C",
        "value": "myinfotesting@gmail.com"
    },
    "regadd": {
        "country": "SG",
        "unit": "128",
        "street": "BEDOK NORTH AVENUE 4",
        "lastupdated": "2018-03-20",
        "block": "102",
        "postal": "460102",
        "source": "1",
        "classification": "C",
        "floor": "09",
        "building": "PEARL GARDEN"
    }
}
"""
    do {
        let json = try JSON(data: testData.data(using: .utf8)!)
        if let myInfo = MyInfoDetails.fromJSON(json) {
            print("MyInfo \(myInfo)")
            print("Address 1 \(myInfo.address.getAddressLine1())")
            print("Address 2 \(myInfo.address.getAddressLine2())")
            return myInfo
        }
    } catch {
        print("Error \(error)")
    }
    return nil
}
