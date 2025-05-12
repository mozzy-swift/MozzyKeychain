//
//  File.swift
//  MozzyKeychain
//
//  Created by Eun Taek Lee on 5/8/25.
//

import Foundation

public protocol KeychainKit {
    func read(itemType account: KeychainItemType, by service: String) throws -> String
    func save(itemType account: KeychainItemType, value: String, by service: String) throws
    func delete(itemType account: KeychainItemType, by service: String) throws
}

public extension KeychainKit {
    
    //MARK: - Convenience methods for accessing with default service
    func read(itemType: KeychainItemType) throws -> String {
        try read(itemType: itemType, by: KeychainContant.baseBundleService)
    }
    
    func save(itemType: KeychainItemType, value: String) throws {
        try save(itemType: itemType, value: value, by: KeychainContant.baseBundleService)
    }
    
    func delete(itemType: KeychainItemType) throws {
        try delete(itemType: itemType, by: KeychainContant.baseBundleService)
    }
    
    //MARK: - Convenience methods for token operations
    func saveToken(_ type: TokenType, value: String) throws {
        try save(itemType: .token(type), value: value, by: KeychainContant.baseBundleService)
    }
    
    func readToken(_ type: TokenType) throws -> String {
        try read(itemType: .token(type), by: KeychainContant.baseBundleService)
    }

    func deleteToken(_ type: TokenType) throws {
        try delete(itemType: .token(type))
    }
}

