//
//  CountryDataSourceTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import Oya_Development_app
import ostelco_core
import XCTest

class CountryDataSourceTests: XCTestCase {
    
    private lazy var tableView = UITableView()
    private lazy var countries: [Country] = {
        var countries = Country.defaultCountries
        countries.append(Country("Totally invalid data"))
        return countries
    }()
    
    private lazy var dataSource = CountryDataSource(tableView: self.tableView,
                                                    countries: self.countries,
                                                    delegate: self)
    private var selectedCountry: Country?
    
    override func tearDown() {
        self.selectedCountry = nil
        super.tearDown()
    }
    
    private func cellAt(indexPath: IndexPath,
                        file: StaticString = #file,
                        line: UInt = #line) -> CountryCell? {
        guard let cell = self.dataSource.tableView(self.tableView, cellForRowAt: indexPath) as? CountryCell else {
            XCTFail("Incorrect cell type at index path \(indexPath)",
                    file: file,
                    line: line)
            return nil
        }

        return cell
    }
    
    func testCellConfiguration() {
        for (index, country) in self.countries.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            guard let cell = self.cellAt(indexPath: indexPath) else {
                return
            }
            
            if country == self.countries.last {
                XCTAssertNil(country.name)
                XCTAssertEqual(country.nameOrPlaceholder, cell.countryLabel.text)
            } else {
                XCTAssertNotNil(country.name)
                XCTAssertEqual(country.name, cell.countryLabel.text)
            }
           
            XCTAssertEqual(cell.accessoryType, .none)
        }
    }
    
    func testSettingASelectedCountry() {
        let indexPathForSelection = IndexPath(row: 1, section: 0)
        let country = Country.defaultCountries[1]
        guard let cell = self.cellAt(indexPath: indexPathForSelection) else {
            return
        }
        
        XCTAssertEqual(cell.countryLabel.text, country.nameOrPlaceholder)
        XCTAssertEqual(cell.accessoryType, .none)
        
        self.dataSource.selectedCountry = country
        
        // The delegate should not fire when setting directly:
        XCTAssertNil(self.selectedCountry)
        
        guard let afterSelectionCell = self.cellAt(indexPath: indexPathForSelection) else {
            return
        }
        
        // Is the cell now checked?
        XCTAssertEqual(afterSelectionCell.countryLabel.text, country.name)
        XCTAssertEqual(afterSelectionCell.accessoryType, .checkmark)
    }
    
    func testSelectingACountryInTheTableView() {
        let indexPathForSelection = IndexPath(row: 0, section: 0)
        let country = Country.defaultCountries[0]
        guard let cell = self.cellAt(indexPath: indexPathForSelection) else {
            return
        }
        
        XCTAssertEqual(cell.countryLabel.text, country.name)
        XCTAssertEqual(cell.accessoryType, .none)
        
        self.dataSource.tableView(self.tableView, didSelectRowAt: indexPathForSelection)
        
        // Did the delegate fire and get the proper country?
        XCTAssertNotNil(self.selectedCountry)
        XCTAssertEqual(self.selectedCountry, country)
        
        // Did the data source get the proper country?
        XCTAssertNotNil(self.dataSource.selectedCountry)
        XCTAssertEqual(self.dataSource.selectedCountry, country)
        
        guard let afterSelectionCell = self.cellAt(indexPath: indexPathForSelection) else {
            return
        }
        
        // Is the cell now checked?
        XCTAssertEqual(afterSelectionCell.countryLabel.text, country.name)
        XCTAssertEqual(afterSelectionCell.accessoryType, .checkmark)
    }
    
    func testAttemptingToSelectARowWhichNoLongerExistsNoOps() {
        let tooFarIndexPath = IndexPath(row: self.countries.count, section: 0)
        
        self.dataSource.tableView(self.tableView, didSelectRowAt: tooFarIndexPath)
        
        // There should be no delegate call
        XCTAssertNil(self.selectedCountry)
        
        // And there should not be a selected country on the data source
        XCTAssertNil(self.dataSource.selectedCountry)
    }
}

extension CountryDataSourceTests: CountrySelectionDelegate {
    
    func selected(country: Country) {
        self.selectedCountry = country
    }
}
