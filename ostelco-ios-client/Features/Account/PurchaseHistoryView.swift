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
    
    @EnvironmentObject var store: AccountStore
    
    var body: some View {
        VStack {
            List(store.purchaseRecords, id: \.name) { record in
                VStack(alignment: .leading, spacing: 10) {
                    Text(record.date)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(OstelcoColor.inputLabelAny.toColor)
                    HStack {
                        Text(record.name)
                            .font(.system(size: 17))
                            .foregroundColor(OstelcoColor.inputLabelAny.toColor)
                        Spacer()
                        Text(record.amount)
                            .font(.system(size: 17))
                            .foregroundColor(OstelcoColor.inputLabelAny.toColor)
                    }
                }.padding()
            }
        }.navigationBarTitle("Purchase History")
    }
}

struct PurchaseHistoryView_Previews: PreviewProvider {

    static var previews: some View {
        PurchaseHistoryView()
    }
}
