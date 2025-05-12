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

final class TokenTypeSpec: QuickSpec {
    override func spec() {
        describe("TokenType") {
            context("description property") {
                it("should return correct description for accessToken") {
                    let tokenType = TokenType.accessToken
                    expect(tokenType.description).to(equal("access-token"))
                }
                
                it("should return correct description for refreshToken") {
                    let tokenType = TokenType.refreshToken
                    expect(tokenType.description).to(equal("refresh-token"))
                }
            }
        }
    }
}
