//
//  TabBarView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import OstelcoStyles

struct TabBarView: View {
    
    private let controller: TabBarViewController
    
    init(controller: TabBarViewController) {
        self.controller = controller
        UITabBar.appearance().barTintColor = OstelcoColor.backgroundAny.toUIColor
        // Remove top border
        UITabBar.appearance().shadowImage = nil
        UITabBar.appearance().clipsToBounds = true
        
        // Remove bottom border
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    var body: some View {
        TabView {
            BalanceView().environmentObject(BalanceStore(controller: controller))
                .tabItem {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                    Text("Balance")
                        .font(.system(size: 10))
                }
            CoverageView().environmentObject(CoverageStore(controller: controller))
                .tabItem {
                    Image(systemName: "globe")
                        .font(.system(size: 24))
                    Text("Coverage")
                        .font(.system(size: 10))
                }
            AccountView().environmentObject(AccountStore(controller: controller))
                .tabItem {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 24))
                    Text("Account")
                        .font(.system(size: 10))
                }
        }
        .accentColor(OstelcoColor.azul.toColor)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(controller: TabBarViewController())
    }
}
