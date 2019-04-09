//
//  TopUpButton.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class TopUpButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 22.5
        self.addShadow(offset: CGSize(width: 0.0, height: 15.0), color: ThemeManager.currentTheme().mainColor.withAlphaComponent(0.35), radius: 18.0, opacity: 1)
        self.backgroundColor = ThemeManager.currentTheme().mainColor
    }
}
