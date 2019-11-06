//
//  TabBarView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import OstelcoStyles
import ostelco_core

enum Tabs {
    case balance
    case coverage
    case account
}

struct TabBarView: View {
    
    private let controller: TabBarViewController
    private let global = GlobalStore()
    @State private var currentTab: Tabs = .balance
    
    init(controller: TabBarViewController) {
        self.controller = controller
        UITabBar.appearance().barTintColor = OstelcoColor.background.toUIColor
        // Remove top border
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().clipsToBounds = true
        
        // Remove bottom border
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    func resetTabs() {
        currentTab = .balance
    }
    
    var body: some View {
        TabView(selection: $currentTab) {
            // TODO: This seems like a hacky way to be able to change current tab from a child view. (this = passing the state variable from the tabbar view to the corresponding views, it feels like we should be able to control this through some other kind of mechanism)
            BalanceView(currentTab: $currentTab).environmentObject(BalanceStore(controller: controller)).environmentObject(global)
                .tabItem {
                    Image(systemName: "house")
                        .font(.system(size: 24))
                    Text("Balance")
                        .font(.system(size: 10))
            }.tag(Tabs.balance)
            CoverageView().environmentObject(CoverageStore(controller: controller)).environmentObject(global)
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
        .accentColor(OstelcoColor.highlighted.toColor)
        .edgesIgnoringSafeArea(.top)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(controller: TabBarViewController())
    }
}
