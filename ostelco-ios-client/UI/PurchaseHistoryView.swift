//
//  PurchaseHistoryView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI

struct PurchaseHistoryView: View {
    
    @Binding var purchaseRecords: [PurchaseRecord]
    
    var body: some View {
        List(purchaseRecords, id: \.id) { record in
            RecordRow(record: record)
        }
        .navigationBarTitle("Purchase History" )
        .listStyle(PlainListStyle())
        .onAppear {
            OstelcoAnalytics.setScreenName(name: "PurchaseHistoryView")
        }
    }
}

struct RecordRow: View {
    let record: PurchaseRecord
    
    init(record: PurchaseRecord) {
        self.record = record
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(verbatim: record.date)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(OstelcoColor.inputLabel.toColor)
            HStack {
                Text(verbatim: record.name)
                    .font(.system(size: 17))
                    .foregroundColor(OstelcoColor.inputLabel.toColor)
                Spacer()
                Text(verbatim: record.amount)
                    .font(.system(size: 17))
                    .foregroundColor(OstelcoColor.inputLabel.toColor)
            }
        }.padding()
    }
}

struct PurchaseHistoryView_Previews: PreviewProvider {

    static var previews: some View {
        PurchaseHistoryView(purchaseRecords: .constant([
            PurchaseRecord(name: "first", amount: "10x", date: "01/01/01", id: "1"),
            PurchaseRecord(name: "second", amount: "20x", date: "01/01/02", id: "2"),
            PurchaseRecord(name: "third", amount: "30x", date: "01/01/03", id: "3")
        ]))
    }
}
