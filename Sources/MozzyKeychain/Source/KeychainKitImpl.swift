//
//  KeychainKitImpl.swift
//  Keychain
//
//  Created by Eun Taek Lee on 5/7/25.
//

import Foundation
import Security

struct KeychainKitImpl {
    
    private let core: Keychain
    private let query: [String: Any]
    
    init(core: Keychain = KeychainImpl()) {
        self.core = core
        self.query = [kSecClass as String: kSecClassGenericPassword]
    }
}


extension KeychainKitImpl: KeychainKit {
    func read(itemType account: KeychainItemType, by service: String) throws -> String {
        var fetchQuery = query
        fetchQuery[kSecAttrService as String] = service
        fetchQuery[kSecAttrAccount as String] = account.description
        fetchQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        fetchQuery[kSecReturnData as String] = kCFBooleanTrue
        fetchQuery[kSecReturnAttributes as String] = kCFBooleanTrue
        
        let result = core.fetch(with: fetchQuery)
        
        guard result.status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }
        
        try throwsNotErrSuccess(status: result.status)
      
        let value = result.value
        let data = value?[kSecValueData as String] as? Data
        return String(data: data!, encoding: .utf8)!
    }
    
    func save(itemType account: KeychainItemType, value: String, by service: String) throws {
        let dataFromString = value.data(using: .utf8, allowLossyConversion: false)!
        
        var saveQuery = query
        saveQuery[kSecAttrService as String] = service
        saveQuery[kSecAttrAccount as String] = account.description
        
        do {
            _ = try read(itemType: account, by: service)
            
            let updateQuery = [kSecValueData as String: dataFromString]
            let status = core.update(item: saveQuery, with: updateQuery)
            
            try throwsNotErrSuccess(status: status)
            
        } catch KeychainError.noPassword {
            
            saveQuery[kSecValueData as String] = dataFromString
            
            let status = core.add(item: saveQuery)
            
            try throwsNotErrSuccess(status: status)
        }
    }
    
    func delete(itemType account: KeychainItemType, by service: String) throws {
        var deleteQuery = query
        deleteQuery[kSecAttrService as String] = service
        deleteQuery[kSecAttrAccount as String] = account.description
        deleteQuery[kSecReturnData as String] = kCFBooleanTrue!
        
        let status = core.delete(item: deleteQuery)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }
        
        try throwsNotErrSuccess(status: status)
    }
    

    private func throwsNotErrSuccess(status: OSStatus) throws {
        guard status == errSecSuccess else {
            let errMessage: String = SecCopyErrorMessageString(status, nil)! as String
            throw KeychainError.unhandledError(message: errMessage)
        }
    }
    
}
