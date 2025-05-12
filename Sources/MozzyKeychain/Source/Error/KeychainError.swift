//
//  KeychainError.swift
//  Keychain
//
//  Created by Eun Taek Lee on 5/7/25.
//

import Foundation

public enum KeychainError: Error, Equatable {
    case noPassword
    case encodingError
    case unhandledError(message: String)
    case updateValueMissing
    case unexpectedPasswordData
}

