//// Created for ostelco-ios-client in 2019

import UIKit

protocol CautionDelegate: class {
    func userChoseContinue()
    func userChoseCancel()
}

class CautionViewController: UIViewController {
    weak var delegate: CautionDelegate?
    
    @IBOutlet private var explanationLabel: UILabel!
    
    private var target: Country!
    private var current: Country?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let current = current {
            let format = NSLocalizedString("Okay, so here’s the deal:\n\nIt looks like you're trying to activate OYA in %@, while you're (still) in %@.\n\nThat's cool, but be aware that after activation, you will not have any reception on your phone (neither through OYA or otherwise) unless you actually enter %@.\n\ntldr; If you’re on your way to %@, feel free to ignore this warning.", comment: "Explanation text when a user is in a different country")
            
            explanationLabel.text = String(format: format, target.nameOrPlaceholder, current.nameOrPlaceholder, target.nameOrPlaceholder, target.nameOrPlaceholder)
        } else {
            let format = NSLocalizedString("Okay, so here’s the deal:\n\nIt looks like you're trying to activate OYA in %@.\n\nThat's cool, but be aware that after activation, you will not have any reception on your phone (neither through OYA or otherwise) unless you actually enter %@.\n\ntldr; If you’re on your way to %@, feel free to ignore this warning.", comment: "Explanation text when a user is in a different country")
            
            explanationLabel.text = String(format: format, target.nameOrPlaceholder, target.nameOrPlaceholder, target.nameOrPlaceholder)
        }
    }
    
    @IBAction private func abort() {
        delegate?.userChoseCancel()
    }
    
    @IBAction private func next() {
        delegate?.userChoseContinue()
    }
}

extension CautionViewController: StoryboardLoadable {
    
    static func fromStoryboard(delegate: CautionDelegate, current: Country?, target: Country) -> CautionViewController {
        let controller = fromStoryboard()
        controller.delegate = delegate
        controller.target = target
        controller.current = current
        return controller
    }
    
    static var storyboard: Storyboard {
        return .ekyc
    }
    
    static var isInitialViewController: Bool {
        return false
    }
}
