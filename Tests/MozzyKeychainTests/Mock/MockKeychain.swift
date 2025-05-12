//
//  File.swift
//  MozzyKeychain
//
//  Created by Eun Taek Lee on 5/8/25.
//

import Quick
import Nimble
import XCTest
@testable import MozzyKeychain

final class MockKeychain: Keychain {
    var savedItems: [String: [String: String]] = [:]
    var updateCalled = false
    var shouldFailFetching = false
    var shouldFailAdding = false
    var shouldFailUpdating = false
    var shouldFailDeleting = false
    
    func fetch(with query: [String: Any]) -> KeychainResult {
        if shouldFailFetching {
            return KeychainResult(status: errSecInternalError, value: nil)
        }
        
        guard let service = query[kSecAttrService as String] as? String,
              let account = query[kSecAttrAccount as String] as? String else {
            return KeychainResult(status: errSecItemNotFound, value: nil)
        }
        
        if let serviceDict = savedItems[service], let value = serviceDict[account] {
            let data = value.data(using: .utf8)!
            let result: [String: Any] = [kSecValueData as String: data]
            return KeychainResult(status: errSecSuccess, value: result as CFTypeRef)
        }
        
        return KeychainResult(status: errSecItemNotFound, value: nil)
    }
    
    func add(item query: [String: Any]) -> OSStatus {
        if shouldFailAdding {
            return errSecInternalError
        }
        
        guard let service = query[kSecAttrService as String] as? String,
              let account = query[kSecAttrAccount as String] as? String,
              let data = query[kSecValueData as String] as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return errSecInvalidData
        }
        
        if savedItems[service] == nil {
            savedItems[service] = [:]
        }
        
        savedItems[service]![account] = value
        return errSecSuccess
    }
    
    func update(item query: [String: Any], with attributes: [String: Any]) -> OSStatus {
        if shouldFailUpdating {
            return errSecInternalError
        }
        
        updateCalled = true
        
        guard let service = query[kSecAttrService as String] as? String,
              let account = query[kSecAttrAccount as String] as? String,
              let data = attributes[kSecValueData as String] as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return errSecInvalidData
        }
        
        if savedItems[service] == nil || savedItems[service]![account] == nil {
            return errSecItemNotFound
        }
        
        savedItems[service]![account] = value
        return errSecSuccess
    }
    
    func delete(item query: [String: Any]) -> OSStatus {
        if shouldFailDeleting {
            return errSecInternalError
        }
        
        guard let service = query[kSecAttrService as String] as? String,
              let account = query[kSecAttrAccount as String] as? String else {
            return errSecInvalidData
        }
        
        if savedItems[service] == nil || savedItems[service]![account] == nil {
            return errSecItemNotFound
        }
        
        savedItems[service]!.removeValue(forKey: account)
        return errSecSuccess
    }
}
