//
//  File.swift
//  MozzyKeychain
//
//  Created by Eun Taek Lee on 5/8/25.
//

import Foundation

public enum KeychainItemType {
    case token(TokenType)
    case apiKey(String)
    case userCredential(String)
    case custom(String)
    
    var description: String {
        switch self {
        case .token(let tokenType):
            tokenType.description
        case .apiKey(let name):
            "ApiKey-\(name)"
        case .userCredential(let identifier):
            "User-\(identifier)"
        case .custom(let name):
            name
        }
    }
}
