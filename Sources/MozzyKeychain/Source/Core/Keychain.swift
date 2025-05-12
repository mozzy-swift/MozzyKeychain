//
//  Keychain.swift
//  Keychain
//
//  Created by Eun Taek Lee on 5/7/25.
//

import Foundation

protocol Keychain {
    func fetch(with query: [String: Any]) -> KeychainResult
    func add(item query: [String: Any]) -> OSStatus
    func update(item query: [String: Any], with attributes: [String: Any]) -> OSStatus
    func delete(item query: [String: Any]) -> OSStatus
}
