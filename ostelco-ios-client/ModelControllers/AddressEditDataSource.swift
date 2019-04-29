//
//  AddressEditDataSource.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/29/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import UIKit

enum AddressEditSection: CaseIterable {
    case street
    case unit
    case city
    case postcode
    case country
    
    var localizedTitle: String {
        // TODO: Actually localize
        switch self {
        case .street:
            return "STREET"
        case .unit:
            return "UNIT NUMBER"
        case .city:
            return "CITY"
        case .postcode:
            return "POSTCODE"
        case .country:
            return "COUNTRY"
        }
    }
}

protocol AddressEditDataSourceDelegate: class {
    
    func validityChanged(to valid: Bool)
}

class AddressEditDataSource: NSObject {
    
    private weak var tableView: UITableView?

    private lazy var values: [AddressEditSection: String] = {
        var values = [AddressEditSection: String]()
        self.sections.forEach { values[$0] = "" }
        return values
    }()
    
    private lazy var validationStates: [AddressEditSection: ValidationState] = {
        var states = [AddressEditSection: ValidationState]()
        self.sections.forEach { states[$0] = .notChecked }
        return states
    }()
    
    private let sections: [AddressEditSection]
    
    private weak var delegate: AddressEditDataSourceDelegate?
    
    /// Designated initializer
    ///
    /// - Parameters:
    ///   - tableView: The table view to use to edit various pieces of address information.
    ///   - sections: Which `AddressEditSection`s are included in this data source? Defaults to `allCases`.
    ///   - delegate: The delegate to notify of any changes
    init(tableView: UITableView,
         sections: [AddressEditSection] = AddressEditSection.allCases,
         delegate: AddressEditDataSourceDelegate) {
        self.tableView = tableView
        self.sections = sections
        self.delegate = delegate
        super.init()
        
        TextEditCell.registerIfNeeded(with: tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    /// Sets a value for the given section.
    /// NOTE: Does not automatically reload data - if you want to reload, do so after setting all values.
    ///
    /// - Parameters:
    ///   - value: The string value for the section
    ///   - section: The section to set the value for, or nil to set an empty value.
    func setValue(_ value: String?, forSection section: AddressEditSection) {
        self.values[section] = value ?? ""
    }
    
    /// Gets the value for a given section
    ///
    /// - Parameter section: The section you wish to grab the value for
    /// - Returns: The value, or nil if one does not exist.
    func value(for section: AddressEditSection) -> String? {
        return self.values[section]
    }
    
    /// Reloads the data in the table view.
    func reloadData() {
        self.tableView?.reloadData()
    }
    
    func reloadSection(_ section: Int) {
        self.tableView?.reloadSections([section], with: .automatic)
    }
    
    private func areAllStatesValid() -> Bool {
        let states = self.validationStates.values
        let containsInvalid = states.contains(where: { $0 != .valid })
        return !containsInvalid
    }
    
    private func validateContents(of textField: UITextField) {
        let index = textField.tag
        let section = self.sections[index]
        self.values[section] = textField.text ?? ""
        
        defer {
            self.reloadSection(index)
        }
        
        guard
            let text = textField.text,
            text.isNotEmpty else {
                self.validationStates[section] = .error(description: "Please enter a value.")
                return
        }
        
        self.validationStates[section] = .valid
        self.delegate?.validityChanged(to: self.areAllStatesValid())
    }
    
    private func isLastSection(_ section: Int) -> Bool {
        return section == (self.sections.count - 1)
    }
}

// MARK: - UITableViewDataSource

extension AddressEditDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].localizedTitle
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextEditCell = tableView.dequeue(at: indexPath)
        let section = self.sections[indexPath.section]
        
        cell.textField.tag = indexPath.section
        cell.textField.delegate = self
        cell.textField.text = self.values[section]
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AddressEditDataSource: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionType = self.sections[section]
        
        guard let validationState = self.validationStates[sectionType] else {
            // No state, no footer!
            return nil
        }
    
        switch validationState {
        case .notChecked,
             .valid:
            return nil
        case .error(let description):
            let label = ErrorTextLabel()
            label.textAlignment = .center
            label.text = description
            
            return label
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let label = self.tableView(tableView, viewForFooterInSection: section) as? UILabel else {
            return 0
        }
        
        label.backgroundColor = .red
        return label.font.pointSize * 2
    }
}

// MARK: - UITextFieldDelegate

extension AddressEditDataSource: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.isLastSection(textField.tag) {
            // This is the last text field, hide the keyboard.
            textField.resignFirstResponder()
        } else {
            // Go to the next text field
            let nextSection = textField.tag + 1
            let indexPath = IndexPath(row: 0, section: nextSection)
            guard let cell = self.tableView?.cellForRow(at: indexPath) as? TextEditCell else {
                assertionFailure("Couldn't get cell for section \(nextSection)")
                return false
            }

            cell.textField.becomeFirstResponder()
        }
        
        // Don't actually allow returns in the text.
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.validateContents(of: textField)
    }
}
