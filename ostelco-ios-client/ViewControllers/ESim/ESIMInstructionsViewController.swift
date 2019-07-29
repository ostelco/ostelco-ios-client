//
//  ESIMInstructionsViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 5/22/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import UIKit

protocol ESIMInstructionsDelegate: class {
    func completedInstructions()
}

class ESIMInstructionsViewController: UIViewController {

    private var pageController: UIPageViewController!
    
    @IBOutlet private var primaryButton: PrimaryButton!
    @IBOutlet private var lastPageLabel: BodyTextLabel!
    
    weak var delegate: ESIMInstructionsDelegate?
    
    private lazy var dataSource: PageControllerDataSource = {
        let pages = ESIMPage.allCases.map { $0.viewController }
        return PageControllerDataSource(pageController: self.pageController,
                                        viewControllers: pages,
                                        pageIndicatorTintColor: OstelcoColor.paleGrey.toUIColor,
                                        currentPageIndicatorTintColor: OstelcoColor.oyaBlue.toUIColor,
                                        delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let index = self.dataSource.currentIndex
        self.updateUI(for: index)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageController = segue.destination as? UIPageViewController {
            self.pageController = pageController
        }
    }
    
    private func updateUI(for index: Int) {
        if index == (ESIMPage.allCases.count - 1) {
            primaryButton.setTitle(NSLocalizedString("Send me the QR code", comment: "Last action button in eSim Carousel"), for: .normal)
            lastPageLabel.isHidden = false
        } else {
            primaryButton.setTitle(NSLocalizedString("Next", comment: "Action button in Carousel"), for: .normal)
            lastPageLabel.isHidden = true
        }
    }
    
    @IBAction private func primaryButtonTapped(_ sender: UIButton) {
        let index = dataSource.currentIndex
        if index == (ESIMPage.allCases.count - 1) {
            self.delegate?.completedInstructions()
        } else {
            self.dataSource.goToNextPage()
        }
    }
}

extension ESIMInstructionsViewController: PageControllerDataSourceDelegate {
    func pageChanged(to index: Int) {
        self.updateUI(for: index)
    }
}

extension ESIMInstructionsViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .esim
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
