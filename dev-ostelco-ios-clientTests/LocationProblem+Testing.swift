//
//  LocationProblem+Testing.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 5/24/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core

extension LocationProblem: CaseIterable {
    
    public static var allCases: [LocationProblem] {
        return [
            .authorizedButWrongCountry(expected: "Correct", actual: "Wrong"),
            .deniedByUser,
            .disabledInSettings,
            .notDetermined,
            .restrictedByParentalControls
        ]
    }
}
