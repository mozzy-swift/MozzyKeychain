//
//  File.swift
//  MozzyKeychain
//
//  Created by Eun Taek Lee on 5/8/25.
//

import Foundation

public enum TokenType : CustomStringConvertible {
    case accessToken
    case refreshToken
    
    public var description: String {
        switch self {
        case .accessToken: "access-token"
        case .refreshToken: "refresh-token"
        }
    }
}
