//
//  CoverageView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import UIKit
import OstelcoStyles

struct CoverageView: View {
    
    init() {
        UINavigationBar.appearance().backgroundColor = OstelcoColor.background.toUIColor
    }
    
    var body: some View {
        NavigationView {
            ScrollView() {
                OstelcoTitle(label: "Location", image: "location.fill")
            }
        }
    }
}

struct CoverageView_Previews: PreviewProvider {
    static var previews: some View {
        CoverageView()
    }
}
