//
//  ExternallyManagedSessionTests.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import BitmovinPlayer
import BitmovinConvivaAnalytics
import ConvivaSDK

class ExternallyManagedSessionSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        var playerDouble: BitmovinPlayerTestDouble!

        beforeEach {
            playerDouble = BitmovinPlayerTestDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        context("Externally Managed Session") {
            var convivaAnalytics: ConvivaAnalytics!
            beforeEach {
                do {
                    convivaAnalytics = try ConvivaAnalytics(player: playerDouble, customerKey: "")
                } catch {
                    fail("ConvivaAnalytics failed with error: \(error)")
                }
            }

            context("end session") {
                it("no-opt if no session running") {
                    let spy = Spy(aClass: CISClientTestDouble.self, functionName: "cleanupSession")
                    convivaAnalytics.endSession()
                    expect(spy).toNot(haveBeenCalled())
                }

                it("cleanup running session") {
                    playerDouble.fakePlayEvent()
                    let spy = Spy(aClass: CISClientTestDouble.self, functionName: "cleanupSession")
                    convivaAnalytics.endSession()
                    expect(spy).to(haveBeenCalled())
                }
            }
        }
    }
}
