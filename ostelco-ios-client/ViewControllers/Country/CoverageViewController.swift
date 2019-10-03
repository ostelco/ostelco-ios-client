//
//  CoverageViewController.swift
//  ostelco-ios-client
//
//  Created by Samuel Goodwin on 10/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import ostelco_core

class CoverageViewController: UIViewController {
    
    @IBOutlet private var singaporeButton: UIButton!
    @IBOutlet private var norwayButton: UIButton!
    
    var currentCoordinator: RegionOnboardingCoordinator?
    
    let primeAPI = APIManager.shared.primeAPI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.singaporeButton.setTitle("Singapore - Ready", for: .normal)
        self.singaporeButton.setTitle("Singapore - Approved", for: .disabled)
        self.norwayButton.setTitle("Norway - Ready", for: .normal)
        self.norwayButton.setTitle("Norway - Approved", for: .disabled)
        
        updateButtons()
    }
    
    func updateButtons() {
        primeAPI.loadContext()
        .done { (context) in
            let singapore = context.toLegacyModel().regions.first(where: { $0.region.id == "sg" })
            self.singaporeButton.isEnabled = singapore?.status != .approved
            
            let norway = context.toLegacyModel().regions.first(where: { $0.region.id == "no" })
            self.norwayButton.isEnabled = norway?.status != .approved
        }.cauterize()
    }
    
    @IBAction private func startOnboardingForSingapore() {
        let country = Country("sg")
        let navigationController = UINavigationController()
        let coordinator = RegionOnboardingCoordinator(country: country, localContext: LocalContext(), navigationController: navigationController, primeAPI: primeAPI)
        coordinator.delegate = self
        currentCoordinator = coordinator
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction private func startOnboardingForNorway() {
        let country = Country("no")
        let navigationController = UINavigationController()
        let coordinator = RegionOnboardingCoordinator(country: country, localContext: LocalContext(), navigationController: navigationController, primeAPI: primeAPI)
        coordinator.delegate = self
        currentCoordinator = coordinator
        present(navigationController, animated: true, completion: nil)
    }
}

extension CoverageViewController: RegionOnboardingDelegate {
    func onboardingCompleteForCountry(_ country: Country) {
        dismiss(animated: true) {
            self.updateButtons()
        }
    }
    
    func onboardingCancelled() {
        dismiss(animated: true, completion: nil)
    }
}
