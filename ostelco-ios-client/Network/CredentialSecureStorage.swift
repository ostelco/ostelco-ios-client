//
//  CredentialSecureStorage.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/1/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import Foundation
import Auth0

class CredentialSecureStorage: SecureStorage {
    
    private var creds = [KeychainKey: String]()
    
    init(credentialManger: CredentialsManager) {
        credentialManger.credentials { error, credentials in
            if let error = error {
                debugPrint("- Credentials couldn't be loaded: \(error)")
            }
            
            guard let creds = credentials else {
                return
            }
            
            self.update(with: creds)
        }
    }
    
    func update(with credentials: Credentials) {
        if let accessToken = credentials.accessToken {
            self.creds[.Auth0Token] = accessToken
        }
        
        if let refreshToken = credentials.refreshToken {
            self.creds[.Auth0RefreshToken] = refreshToken
        }
    }
    
    func setString(_ string: String, for key: KeychainKey) {
        self.creds[key] = string
    }
    
    func getString(for key: KeychainKey) -> String? {
        return self.creds[key]
    }
    
    func clearValue(for key: KeychainKey) {
        self.creds.removeValue(forKey: key)
    }
    
    func clearSecureStorage() {
        self.creds.removeAll()
    }
    
}
