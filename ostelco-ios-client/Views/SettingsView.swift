//
//  SettingsView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import OstelcoStyles

final class SettingsStore: ObservableObject {
    @Published var purchaseRecords: [PurchaseRecord] = []
    
    init() {
        APIManager.shared.primeAPI
        .loadPurchases()
        .map { purchaseModels -> [PurchaseRecord] in
            let sortedPurchases = purchaseModels.sorted { $0.timestamp > $1.timestamp }
            return sortedPurchases.map { PurchaseRecord(from: $0) }
        }
        .done { self.purchaseRecords = $0 }
        .catch { error in
            ApplicationErrors.log(error)
            // TODO: Notify user about this error.
        }
    }
}


struct SettingsView: View {
    
    let controller: SettingsViewController
    @EnvironmentObject var store: SettingsStore
    @State private var showLogoutSheet = false
    @State private var showPurchaseHistory = false
    
    init(controller: SettingsViewController){
        self.controller = controller
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().barTintColor = .white
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    OstelcoTitle(label: "Account")
                    Button(action: {
                        self.showPurchaseHistory.toggle()
                    }) {
                        HStack {
                            OstelcoText(label: "Purchase History")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    Divider()
                    Button(action: {
                        FreshchatManager.shared.show(self.controller)
                    }) {
                        HStack {
                            OstelcoText(label: "Chat to Support")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    Divider()
                    Button(action: {
                        self.showLogoutSheet.toggle()
                    }) {
                        HStack {
                            OstelcoText(label: "Log Out")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                VStack {
                    OstelcoTitle(label: "Knowledge Base")
                    Button(action: {
                        UIApplication.shared.open(ExternalLink.oyaWebpage.url)
                    }) {
                        HStack {
                            OstelcoText(label: "Turn OYA Data ON/OFF")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                    Divider()
                    Button(action: {
                        UIApplication.shared.open(ExternalLink.termsAndConditions.url)
                    }) {
                        HStack {
                            OstelcoText(label: "Terms & Conditions")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                    Divider()
                    Button(action: {
                        UIApplication.shared.open(ExternalLink.privacyPolicy.url)
                    }) {
                        HStack {
                            OstelcoText(label: "Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                }
                Spacer()
            }
            .padding(15)
            .actionSheet(isPresented: $showLogoutSheet) {
                ActionSheet(
                    title: Text(""),
                    message: Text("Are you sure you want to log out from your account?"),
                    buttons: [
                        .destructive(Text("Log Out"), action: {
                            UserManager.shared.logOut()
                        }),
                        .default(Text("Cancel"))
                    ]
                )
            }
            .sheet(isPresented: $showPurchaseHistory) {
                PurchaseHistoryView().environmentObject(self.store)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(controller: SettingsViewController())
    }
}
