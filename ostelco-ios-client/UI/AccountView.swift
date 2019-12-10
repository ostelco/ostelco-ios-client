//
//  SettingsView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI

protocol AccountViewDelegate: class {
    func showFreshchat()
}

struct AccountView: View {
    
    @ObservedObject var account: AccountStore
    
    weak var delegate: AccountViewDelegate!
    
    @State private var showLogoutSheet = false
    @State private var showPurchaseHistory = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: PurchaseHistoryView(purchaseRecords: $account.purchaseRecords)) {
                        HStack {
                            OstelcoText(label: "Purchase History")
                        }
                    }
                    Button(action: {
                        self.delegate?.showFreshchat()
                    }) {
                        HStack {
                            OstelcoText(label: "Chat with Support")
                            Spacer()
                            if account.unreadMessages > 0 {
                                Image(systemName: "\($account.unreadMessages).circle.fill")
                            }
                        }
                    }
                    Button(action: {
                        self.showLogoutSheet.toggle()
                    }) {
                        OstelcoText(label: "Log Out")
                    }
                }
                ExternalLinksSection()
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Account")
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
        }
        .onAppear {
            OstelcoAnalytics.setScreenName(name: "AccountView")
        }
    }
}

struct ExternalLinksSection: View {
    var body: some View {
        Section(header: Text("Knowledge Base").font(.system(size: 28, weight: .bold)).foregroundColor(OstelcoColor.text.toColor)) {
            Button(action: {
                UIApplication.shared.open(ExternalLink.oyaWebpage.url)
            }) {
                HStack {
                    OstelcoText(label: "Turn OYA Data ON/OFF")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                }
            }
            Button(action: {
                UIApplication.shared.open(ExternalLink.termsAndConditions.url)
            }) {
                HStack {
                    OstelcoText(label: "Terms & Conditions")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                }
            }
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
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountView(
//            unreadMessagesCount: .constant(3),
//            purchaseRecords: .constant([
//                PurchaseRecord(name: "An Important Purchase", amount: "S$ 35", date: "June 1, 2020", id: "01010101")
//            ])
//        )
//    }
//}
