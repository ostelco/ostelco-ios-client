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
    @Published var unreadMessages: Int = 0
    
    private let controller: TabBarViewController
    
    init(controller: TabBarViewController) {
        self.controller = controller
        
        updateUnreadMessagesCount()
        NotificationCenter.default.addObserver(self, selector: #selector(unreadMessagesCountChanged(_:)), name: Notification.Name(FRESHCHAT_UNREAD_MESSAGE_COUNT_CHANGED), object: nil)
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
    
    @objc private func unreadMessagesCountChanged(_ notification: NSNotification) {
        updateUnreadMessagesCount()
    }
    
    private func updateUnreadMessagesCount() {
        Freshchat.sharedInstance()?.unreadCount {
            self.unreadMessages = $0
        }
    }
    
    func showFreshchat() {
        FreshchatManager.shared.show(controller)
    }
}

struct SettingsView: View {
    
    @EnvironmentObject var store: SettingsStore
    @State private var showLogoutSheet = false
    @State private var showPurchaseHistory = false
    
    init(){
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().barTintColor = .white
    }
    
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
                        self.store.showFreshchat()
                    }) {
                        HStack {
                            OstelcoText(label: "Chat to Support")
                            Spacer()
                            renderUnreadMessagesBadge()
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
