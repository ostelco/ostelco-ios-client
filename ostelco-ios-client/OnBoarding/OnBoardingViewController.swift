//
//  OnBoardingViewController.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 15/02/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
//  @IBAction func unwindToMainMenu(sender: UIStoryboardSegue)
//  {
//    let sourceViewController = sender.source
//    // Pull any data from the view controller which initiated the unwind segue.
//    print("OnBoardingViewController unwindToMainMenu")
//  }

  @IBAction func logout(_ sender: Any) {
    sharedAuth.logout()
  }
}
