//
//  UIViewController+SwiftUI.swift
//  ostelco-ios-client
//
//  Created by mac on 10/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import SwiftUI

extension UIViewController {
    func embedSwiftUI<T: View>(_ swiftUIView: T) {
        let childView = UIHostingController(rootView: swiftUIView)
        addChild(childView)
        childView.view.frame = self.view.frame
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
}

