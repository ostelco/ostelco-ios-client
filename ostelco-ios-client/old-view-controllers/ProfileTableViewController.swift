//
//  ProfileTableViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 10/20/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import UIKit
import Siesta
import os

class ProfileTableViewController: UITableViewController, ResourceObserver {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var postCodeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var referralIDLabel: UILabel!
    
    let statusOverlay = ResourceStatusOverlay()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ostelcoAPI.profile.loadIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        statusOverlay.positionToCoverParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusOverlay.embed(in: self)
        
        ostelcoAPI.profile
            .addObserver(self)
            .addObserver(statusOverlay)
        
        // Hide separator line for empty cells ref: https://useyourloaf.com/blog/hiding-empty-table-view-rows/
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        // TODO: Handle below errors in a better way
        guard let profile = resource.latestData?.content as? ProfileModel else {
            os_log("Resource changed but returned data was empty for ProfileModel.")
            return
        }
        
        nameLabel.text = profile.name
        emailLabel.text = profile.email
        addressLabel.text = profile.address
        cityLabel.text = profile.city
        postCodeLabel.text = profile.postCode
        countryLabel.text = profile.country
        referralIDLabel.text = profile.referralId
 
        self.tableView.reloadData()
    }
}
