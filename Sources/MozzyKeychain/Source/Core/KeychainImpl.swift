//
//  KeychainImpl.swift
//  Keychain
//
//  Created by Eun Taek Lee on 5/7/25.
//

import Foundation

struct KeychainImpl: Keychain {
    
    func fetch(with query: [String: Any]) -> KeychainResult {
        var item:CFTypeRef?
        let status:OSStatus = SecItemCopyMatching(query as CFDictionary, &item)
        return KeychainResult(status: status, value: item)
    }
    
    func add(item query: [String: Any]) -> OSStatus {
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    func update(item query: [String : Any], with attributes: [String : Any]) -> OSStatus {
        return SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    }

    func delete(item query: [String : Any]) -> OSStatus {
        return SecItemDelete(query as CFDictionary)
    }
    
}
