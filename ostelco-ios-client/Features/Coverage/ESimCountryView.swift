//
//  ESimCountryView.swift
//  ostelco-ios-client
//
//  Created by mac on 10/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import ostelco_core
import OstelcoStyles

extension Country {
    var image: UIImage {
        switch self.countryCode {
        case "SE":
            return UIImage.ostelco_flagsSe
        case "HK":
            return UIImage.ostelco_flagsHk
        case "IN":
            return UIImage.ostelco_flagsIn
        case "MY":
            return UIImage.ostelco_flagsMy
        case "NO":
            return UIImage.ostelco_flagsNo
        case "PH":
            return UIImage.ostelco_flagsPh
        case "SG":
            return UIImage.ostelco_flagsSg
        case "TH":
            return UIImage.ostelco_flagsTh
        case "US":
            return UIImage.ostelco_flagsUs
        default:
            return UIImage.ostelco_flagsUs
        }
    }
}

struct ContextualButton: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label.uppercased())
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(OstelcoColor.primaryButtonLabel.toColor)
        }
        .frame(width: 82, height: 32)
        .background(OstelcoColor.primaryButtonBackground.toColor)
        .cornerRadius(16)
    }
}

struct ESimCountryViewModel: Identifiable {
    let id = UUID()
    let country: Country
    let heading: String
}

struct ESimCountryView: View {
    let image: UIImage
    let country: String
    let heading: String?
    let icon: String?
    let action: (() -> Void)?
    
    init(image: UIImage, country: String, heading: String? = nil, icon: String? = nil, action: (() -> Void)? = nil) {
        self.image = image
        self.country = country
        self.heading = heading
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 20) {
            Image(uiImage: image)
            VStack(alignment: .leading) {
                heading.map {
                    Text($0.uppercased())
                        .font(.system(size: 13))
                        .frame(height: 27)
                        .foregroundColor(OstelcoColor.countryTextSecondary.toColor)
                }
                Text(country)
                    .font(.system(size: 18))
                    .frame(height: 27)
                    .foregroundColor(OstelcoColor.countryText.toColor)
            }.fixedSize()
            Spacer()
            icon.map {
                Image(systemName: $0)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(OstelcoColor.highlighted.toColor)
                
            }
            action.map { ContextualButton(label: "GET", action: $0) }
        }.padding(.horizontal, 20)
    }
}

#if DEBUG

struct ESimCountryView_Previews: PreviewProvider {
    static let country = Country("NO")
    
    static var previews: some View {
        ESimCountryView(image: country.image, country: country.nameOrPlaceholder)
    }
}
#endif
