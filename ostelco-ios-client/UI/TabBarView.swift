//
//  TabBarView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/18/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI

enum Tabs {
    case balance
    case coverage
    case account
}

struct TabBarView: View {
    
    private let controller: TabBarViewController
    private let global = GlobalStore()
    private let account: AccountStore
    
    @State private var currentTab: Tabs = .balance
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    
    init(controller: TabBarViewController) {
        self.controller = controller
        self.account = AccountStore(controller: controller)
    }
    
    func resetTabs() {
        currentTab = .balance
    }
    
    var body: some View {
       TabView(selection: $currentTab) {
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
            AccountView(account: account, delegate: self.controller)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 24))
                    Text("Account")
                        .font(.system(size: 10))
            }.tag(Tabs.account)
        }
        .accentColor(OstelcoColor.highlighted.toColor)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(controller: TabBarViewController())
    }
}
