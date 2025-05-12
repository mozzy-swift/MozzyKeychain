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

final class KeychainKitFactorySpec: QuickSpec {
    override func spec() {
        describe("KeychainKitFactory") {
            it("should create a valid KeychainKit instance") {
                let keychainKit = KeychainKitFactory.make()
                
                expect(keychainKit).to(beAnInstanceOf(KeychainKitImpl.self))
                expect(keychainKit).to(beAKindOf(KeychainKit.self))
            }
        }
    }
}
