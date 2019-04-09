//
//  File+Reset.swift
//  Core
//
//  Created by Ellen Shapiro on 4/8/19.
//

import Foundation
import Files
import ShellOut

extension File {
    
    func resetToGitHEAD() throws {
        let cmd = ShellOutCommand(string: "git checkout HEAD -- \"\(self.path)\"")
        try shellOut(to: cmd, at: self.parent!.path)
    }
}
