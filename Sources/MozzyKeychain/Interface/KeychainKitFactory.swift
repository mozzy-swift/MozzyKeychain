//
//  File.swift
//  MozzyKeychain
//
//  Created by Eun Taek Lee on 5/8/25.
//

import Foundation

public enum KeychainKitFactory {
    public static func make() -> KeychainKit {
        KeychainKitImpl()
    }
}
