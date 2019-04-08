//
//  MyInfoSummaryViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 27/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class MyInfoSummaryViewController: UIViewController {
    public var myInfoQueryItems: [URLQueryItem]?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Query Items", myInfoQueryItems)
        self.showSpinner(onView: self.view)
        if let code = getMyInfoCode() {
            print("Code = \(code)")
            //            APIManager.sharedInstance.regions.child("/sg/kyc/myInfo").child(code).load()
            //                .onSuccess { entity in
            //                    print("------------_")
            //                    do {
            //                        let json = try JSONSerialization.jsonObject(with: entity.content as! Data, options: []) as? [String : Any]
            //                        print(json)
            //                    } catch {
            //                    }
            //                    print("------------_")
            //                    DispatchQueue.main.async {
            //                        self.removeSpinner()
            //                    }
            //                }
            //                .onFailure { error in
            //                    DispatchQueue.main.async {
            //                        self.removeSpinner()
            //                        self.showAPIError(error: error)
            //                    }
            //            }
        }
        //TODO: Pass the code we retrieved to PRIME
        //TODO: Get the address & phone number form PRIME

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
    }

    @IBAction func `continue`(_ sender: Any) {
        performSegue(withIdentifier: "ESim", sender: self)
    }
}
