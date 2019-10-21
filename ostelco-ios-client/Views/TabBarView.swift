//
//  TabBarView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import OstelcoStyles

enum Tabs {
    case balance
    case coverage
    case account
}

struct TabBarView: View {
    
    private let controller: TabBarViewController
    @State private var currentTab: Tabs = .balance
    
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
        TabView(selection: $currentTab) {
            BalanceView().environmentObject(BalanceStore(controller: controller, tab: $currentTab))
                .tabItem {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                    Text("Balance")
                        .font(.system(size: 10))
            }.tag(Tabs.balance)
            CoverageView().environmentObject(CoverageStore(controller: controller))
                .tabItem {
                    Image(systemName: "globe")
                        .font(.system(size: 24))
                    Text("Coverage")
                        .font(.system(size: 10))
                }.tag(Tabs.coverage)
            AccountView().environmentObject(AccountStore(controller: controller))
                .tabItem {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 24))
                    Text("Account")
                        .font(.system(size: 10))
                }.tag(Tabs.account)
        }
        .accentColor(OstelcoColor.azul.toColor)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(controller: TabBarViewController())
    }
}
