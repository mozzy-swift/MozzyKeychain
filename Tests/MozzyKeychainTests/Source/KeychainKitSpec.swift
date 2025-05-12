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


final class KeychainKitSpec: QuickSpec {
    override func spec() {
        describe("KeychainKit") {
            var mockKeychain: MockKeychain!
            var keychainKit: KeychainKit!
            
            let testAccessToken = "test-access-token-12345"
            let testRefreshToken = "test-refresh-token-67890"
            let testApiKeyName = "google-maps"
            let testApiKeyValue = "api-key-abcdef"
            let testUserCredential = "user@example.com"
            let testUserCredentialValue = "password123"
            let testCustomKey = "custom-settings"
            let testCustomValue = "custom-value-xyz"
            let testCustomService = "com.test.customservice"
            
            beforeEach {
                mockKeychain = MockKeychain()
                keychainKit = KeychainKitImpl(core: mockKeychain)
            }
            
            context("when saving items") {
                it("should save access token") {
                    expect {
                        try keychainKit.saveToken(.accessToken, value: testAccessToken)
                    }.notTo(throwError())
                    
                    let itemType = KeychainItemType.token(.accessToken)
                    let service = KeychainContant.baseBundleService
                    
                    expect(mockKeychain.savedItems[service]?[itemType.description]).to(equal(testAccessToken))
                }
                
                it("should save refresh token") {
                    expect {
                        try keychainKit.saveToken(.refreshToken, value: testRefreshToken)
                    }.notTo(throwError())
                    
                    let itemType = KeychainItemType.token(.refreshToken)
                    let service = KeychainContant.baseBundleService
                    
                    expect(mockKeychain.savedItems[service]?[itemType.description]).to(equal(testRefreshToken))
                }
                
                it("should save API key") {
                    let itemType = KeychainItemType.apiKey(testApiKeyName)
                    
                    expect {
                        try keychainKit.save(itemType: itemType, value: testApiKeyValue)
                    }.notTo(throwError())
                    
                    let service = KeychainContant.baseBundleService
                    expect(mockKeychain.savedItems[service]?[itemType.description]).to(equal(testApiKeyValue))
                }
                
                it("should save user credential") {
                    let itemType = KeychainItemType.userCredential(testUserCredential)
                    
                    expect {
                        try keychainKit.save(itemType: itemType, value: testUserCredentialValue)
                    }.notTo(throwError())
                    
                    let service = KeychainContant.baseBundleService
                    expect(mockKeychain.savedItems[service]?[itemType.description]).to(equal(testUserCredentialValue))
                }
                
                it("should save item with custom service") {
                    let itemType = KeychainItemType.custom(testCustomKey)
                    
                    expect {
                        try keychainKit.save(itemType: itemType, value: testCustomValue, by: testCustomService)
                    }.notTo(throwError())
                    
                    expect(mockKeychain.savedItems[testCustomService]?[itemType.description]).to(equal(testCustomValue))
                }
                
                it("should update existing item") {
                    let itemType = KeychainItemType.token(.accessToken)
                    try! keychainKit.save(itemType: itemType, value: testAccessToken)
                    
                    let updatedValue = "updated-access-token"
                    
                    expect {
                        try keychainKit.save(itemType: itemType, value: updatedValue)
                    }.notTo(throwError())
                    
                    let service = KeychainContant.baseBundleService
                    expect(mockKeychain.savedItems[service]?[itemType.description]).to(equal(updatedValue))
                    
                    expect(mockKeychain.updateCalled).to(beTrue())
                }
                
                it("should throw error when saving fails") {
                    mockKeychain.shouldFailAdding = true
                    
                    let itemType = KeychainItemType.token(.accessToken)
                    
                    expect {
                        try keychainKit.save(itemType: itemType, value: testAccessToken)
                    }.to(throwError())
                }
            }
            
            context("when reading items") {
                beforeEach {
                    try! keychainKit.saveToken(.accessToken, value: testAccessToken)
                    try! keychainKit.saveToken(.refreshToken, value: testRefreshToken)
                    
                    let apiKeyType = KeychainItemType.apiKey(testApiKeyName)
                    try! keychainKit.save(itemType: apiKeyType, value: testApiKeyValue)
                    
                    let customType = KeychainItemType.custom(testCustomKey)
                    try! keychainKit.save(itemType: customType, value: testCustomValue, by: testCustomService)
                }
                
                it("should read access token") {
                    expect {
                        try keychainKit.readToken(.accessToken)
                    }.to(equal(testAccessToken))
                }
                
                it("should read refresh token") {
                    expect {
                        try keychainKit.readToken(.refreshToken)
                    }.to(equal(testRefreshToken))
                }
                
                it("should read API key") {
                    let itemType = KeychainItemType.apiKey(testApiKeyName)
                    
                    expect {
                        try keychainKit.read(itemType: itemType)
                    }.to(equal(testApiKeyValue))
                }
                
                it("should read item with custom service") {
                    let itemType = KeychainItemType.custom(testCustomKey)
                    
                    expect {
                        try keychainKit.read(itemType: itemType, by: testCustomService)
                    }.to(equal(testCustomValue))
                }
                
                it("should throw error when item doesn't exist") {
                    let nonExistentType = KeychainItemType.custom("non-existent")
                    
                    expect {
                        try keychainKit.read(itemType: nonExistentType)
                    }.to(throwError(KeychainError.noPassword))
                }
                
                it("should throw error when fetch fails") {
                    mockKeychain.shouldFailFetching = true
                    
                    expect {
                        try keychainKit.readToken(.accessToken)
                    }.to(throwError())
                }
            }
            
            context("when deleting items") {
                beforeEach {
                    try! keychainKit.saveToken(.accessToken, value: testAccessToken)
                    
                    let customType = KeychainItemType.custom(testCustomKey)
                    try! keychainKit.save(itemType: customType, value: testCustomValue, by: testCustomService)
                }
                
                it("should delete token") {
                    expect {
                        try keychainKit.deleteToken(.accessToken)
                    }.notTo(throwError())
                    
                    expect {
                        try keychainKit.readToken(.accessToken)
                    }.to(throwError(KeychainError.noPassword))
                }
                
                it("should delete item with custom service") {
                    let itemType = KeychainItemType.custom(testCustomKey)
                    
                    expect {
                        try keychainKit.delete(itemType: itemType, by: testCustomService)
                    }.notTo(throwError())
                    
                    expect {
                        try keychainKit.read(itemType: itemType, by: testCustomService)
                    }.to(throwError(KeychainError.noPassword))
                }
                
                it("should throw error when deleting non-existent item") {
                    let nonExistentType = KeychainItemType.custom("non-existent")
                    
                    expect {
                        try keychainKit.delete(itemType: nonExistentType)
                    }.to(throwError(KeychainError.noPassword))
                }
                
                it("should throw error when delete fails") {
                    mockKeychain.shouldFailDeleting = true
                    
                    expect {
                        try keychainKit.deleteToken(.accessToken)
                    }.to(throwError())
                }
            }
            
            context("KeychainItemType") {
                it("should generate correct description for token types") {
                    let accessTokenType = KeychainItemType.token(.accessToken)
                    let refreshTokenType = KeychainItemType.token(.refreshToken)
                    
                    expect(accessTokenType.description).to(equal("access-token"))
                    expect(refreshTokenType.description).to(equal("refresh-token"))
                }
                
                it("should generate correct description for API key") {
                    let apiKeyType = KeychainItemType.apiKey("firebase")
                    expect(apiKeyType.description).to(equal("ApiKey-firebase"))
                }
                
                it("should generate correct description for user credential") {
                    let userCredType = KeychainItemType.userCredential("john@example.com")
                    expect(userCredType.description).to(equal("User-john@example.com"))
                }
                
                it("should generate correct description for custom type") {
                    let customType = KeychainItemType.custom("special-key")
                    expect(customType.description).to(equal("special-key"))
                }
            }
        }
    }
}

