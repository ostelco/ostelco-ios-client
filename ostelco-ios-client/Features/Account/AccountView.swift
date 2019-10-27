//
//  SettingsView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/14/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import OstelcoStyles

struct AccountView: View {
    
    @EnvironmentObject var store: AccountStore
    @State private var showLogoutSheet = false
    @State private var showPurchaseHistory = false
    
    private func renderUnreadMessagesBadge() -> AnyView {
        if store.unreadMessages > 0 {
            return AnyView(
                Image(systemName: "\(store.unreadMessages).circle.fill")
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: PurchaseHistoryView()) {
                        HStack {
                            OstelcoText(label: "Purchase History")
                        }
                    }
                    Button(action: {
                        self.store.showFreshchat()
                    }) {
                        HStack {
                            OstelcoText(label: "Chat to Support")
                            Spacer()
                            renderUnreadMessagesBadge()
                            Image(systemName: "chevron.right")
                        }
                    }
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
                Section(header: Text("Knowledge Base").font(.system(size: 28, weight: .bold)).foregroundColor(.black)) {
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
            }.listStyle(GroupedListStyle())
            
            // .padding(15)
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
        }.onAppear {
            OstelcoAnalytics.setScreenName(name: "AccountView")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
