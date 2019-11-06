//
//  UIViewController+SwiftUI.swift
//  ostelco-ios-client
//
//  Created by mac on 10/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import SwiftUI

extension UIViewController {
    func embedSwiftUI<T: View>(_ swiftUIView: T) {
        let childView = UIHostingController(rootView: swiftUIView)
        embedFullViewChild(childView)
    }
}
