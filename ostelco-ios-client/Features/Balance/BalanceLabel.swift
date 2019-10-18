//
//  BalanceLabel.swift
//  ostelco-ios-client
//
//  Created by mac on 10/16/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import OstelcoStyles

struct BalanceLabel: View {
    let label: String
    
    var body: some View {
        renderBalance()
    }
    
    private func renderBalance() -> Text {
        let textArray = label.components(separatedBy: " ")
        if textArray.count < 2 {
            return Text(label)
                .font(.system(size: 84, weight: .bold))
                .foregroundColor(OstelcoColor.primaryButtonBackground.toColor)
        }
        
        let textUnits = textArray[1]
        
        let decimalSeparator = Locale.current.decimalSeparator!
        let numberBit = textArray[0]
        let numberArray = numberBit.components(separatedBy: decimalSeparator)
        
        if numberArray.count < 2 {
            return Text(label)
                .font(.system(size: 84, weight: .bold))
                .foregroundColor(OstelcoColor.primaryButtonBackground.toColor)
        }
        
        let wholeNumber = numberArray[0]
        let decimalPart = numberArray[1]
        
        return Text(wholeNumber)
            .font(.system(size: 84, weight: .bold))
            .foregroundColor(OstelcoColor.primaryButtonBackground.toColor)
            + Text("\(decimalSeparator)\(decimalPart)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(OstelcoColor.primaryButtonBackground.toColor)
            + Text("\(textUnits)")
                .font(.system(size: 84, weight: .bold))
                .foregroundColor(OstelcoColor.primaryButtonBackground.toColor)
    }
}

struct BalanceLabel_Previews: PreviewProvider {
    static var previews: some View {
        BalanceLabel(label: "52.4 GB")
    }
}
