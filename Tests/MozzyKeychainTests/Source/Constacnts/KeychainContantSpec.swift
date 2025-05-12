//
//  File.swift
//  MozzyKeychain
//
//  Created by Eun Taek Lee on 5/8/25.
//

import Foundation
import Quick
import Nimble
@testable import MozzyKeychain

final class KeychainContantSpec: QuickSpec {
    override func spec() {
        describe("KeychainContant") {
            context("baseBundleService property") {
                it("should use the main bundle identifier when available") {
                    expect(KeychainContant.baseBundleService).notTo(beEmpty())
                    let bundleID = Bundle.main.bundleIdentifier
                    if let bundleID = bundleID {
                        expect(KeychainContant.baseBundleService).to(equal(bundleID))
                    } else {
                        expect(KeychainContant.baseBundleService).to(equal("com.yourcompany.app"))
                    }
                }
            }
        }
    }
}
