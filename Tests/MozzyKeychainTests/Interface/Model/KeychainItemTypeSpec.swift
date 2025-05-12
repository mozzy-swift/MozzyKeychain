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


final class KeychainItemTypeSpec: QuickSpec {
    override func spec() {
        describe("KeychainItemType") {
            context("description property") {
                it("should return correct description for token items") {
                    let accessTokenItem = KeychainItemType.token(.accessToken)
                    let refreshTokenItem = KeychainItemType.token(.refreshToken)
                    
                    expect(accessTokenItem.description).to(equal("access-token"))
                    expect(refreshTokenItem.description).to(equal("refresh-token"))
                }
                
                it("should return correct description for API key items") {
                    let apiKeyItemGoogle = KeychainItemType.apiKey("google")
                    let apiKeyItemFirebase = KeychainItemType.apiKey("firebase")
                    
                    expect(apiKeyItemGoogle.description).to(equal("ApiKey-google"))
                    expect(apiKeyItemFirebase.description).to(equal("ApiKey-firebase"))
                }
                
                it("should return correct description for user credential items") {
                    let userItemEmail = KeychainItemType.userCredential("user@example.com")
                    let userItemUsername = KeychainItemType.userCredential("johndoe")
                    
                    expect(userItemEmail.description).to(equal("User-user@example.com"))
                    expect(userItemUsername.description).to(equal("User-johndoe"))
                }
                
                it("should return correct description for custom items") {
                    let customItem1 = KeychainItemType.custom("my-special-key")
                    let customItem2 = KeychainItemType.custom("app-settings")
                    
                    expect(customItem1.description).to(equal("my-special-key"))
                    expect(customItem2.description).to(equal("app-settings"))
                }
            }
        }
    }
}
