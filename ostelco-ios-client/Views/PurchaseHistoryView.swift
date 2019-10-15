//
//  PurchaseHistoryView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import OstelcoStyles

struct PurchaseHistoryView: View {
    
    @EnvironmentObject var store: SettingsStore
    
    init() {
        
    }
    var body: some View {
        VStack {
            OstelcoTitle(label: "Purchase History")
            List(store.purchaseRecords, id: \.name) { record in
                VStack(alignment: .leading) {
                    Text(record.date)
                    HStack {
                        Text(record.name)
                        Spacer()
                        Text(record.amount)
                    }
                }.padding()
            }.listStyle(GroupedListStyle())
        }
    }
}

struct PurchaseHistoryView_Previews: PreviewProvider {

    static var previews: some View {
        PurchaseHistoryView()
    }
}
