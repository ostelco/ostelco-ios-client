//
//  MessageContainer.swift
//  ostelco-ios-client
//
//  Created by mac on 10/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI
import OstelcoStyles
import ostelco_core

enum MessageType {
    case welcomeNewUser(action: () -> Void)
    case welcomeToCountry(action: () -> Void, country: Country)
    case countryNotSupported(country: Country)
}

struct MessageContainer: View {
    let messageType: MessageType
    let action: (() -> Void)?
    
    init(messageType: MessageType, action: (() -> Void)? = nil) {
        self.messageType = messageType
        self.action = action
    }
    
    var body: some View {
        Group {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                }
            }.background(OstelcoColor.fog.toColor)
            ZStack {
                MessageView(messageType: messageType)
                // Lazy way to hide the bottom rounded corners from the above container, a better solution would be to configure the corners in the container itself.
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(OstelcoColor.foreground.toColor)
                        .frame(maxWidth: .infinity, maxHeight: 25)
                }
            }
        }
    }
}

struct MessageView: View {
    let messageType: MessageType
    let action: (() -> Void)?
    
    init(messageType: MessageType, action: (() -> Void)? = nil) {
        self.messageType = messageType
        self.action = action
    }
    
    func renderTitle() -> OstelcoTitle {
        switch messageType {
        case .welcomeNewUser:
            return OstelcoTitle(label: "Welcome to OYA!")
        case .welcomeToCountry( _, let country), .countryNotSupported(let country):
                return OstelcoTitle(label: "Welcome to \(country.nameOrPlaceholder)!")
        }
    }
    
    func renderDescription() -> Text {
        switch messageType {
        case .welcomeNewUser:
            return Text("Where would you like to start using your first 1GB of OYA data?")
        case .welcomeToCountry:
            return Text("You can continue to use your OYA data here with a few simple steps")
        case .countryNotSupported:
            return Text("Unfortunately you cannot use your OYA data here at this point")
        }
    }
    
    func renderButtonImage() -> AnyView {
        switch messageType {
        case .welcomeNewUser:
            return AnyView(Image(systemName: "globe")
            .font(.system(size: 30, weight: .light))
            .foregroundColor(OstelcoColor.primaryButtonLabel.toColor))
        default:
            return AnyView(EmptyView())
        }
    }
    
    func renderButtonLabel() -> Text {
        switch messageType {
        case .welcomeNewUser:
            return Text("See Available Countries")
        case .welcomeToCountry:
            return Text("Continue to use your OYA data here")
        default:
            return Text("")
        }
    }
    
    func renderButton() -> AnyView {
        
        switch messageType {
        case .welcomeNewUser(let action), .welcomeToCountry(let action, _):
            return AnyView(Button(action: action) {
                ZStack {
                    HStack {
                        renderButtonImage()
                        Spacer()
                    }.padding(.leading, 10)
                    renderButtonLabel()
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(OstelcoColor.primaryButtonLabel.toColor)
                }
            })
        default:
            return AnyView(EmptyView())
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            OstelcoContainer {
                VStack(spacing: 20) {
                    self.renderTitle()
                    self.renderDescription()
                        .font(.system(size: 21))
                        .foregroundColor(OstelcoColor.inputLabel.toColor)
                        .multilineTextAlignment(.center )
                    self.renderButton()
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(OstelcoColor.primaryButtonBackground.toColor)
                    .cornerRadius(27.5)
                }.padding(25)
            }
        }
    }
}
struct MessageContainer_Previews: PreviewProvider {
    static var previews: some View {
        MessageContainer(messageType: .welcomeNewUser(action: {}))
    }
}
