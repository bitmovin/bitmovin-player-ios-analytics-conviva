//
//  CustomEventTests.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by David Steinacher on 11.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import BitmovinPlayer
import BitmovinConvivaAnalytics
import ConvivaSDK

class CustomEventsSpec: QuickSpec {
    override func spec() {
        var playerDouble: BitmovinPlayerTestDouble!

        beforeEach {
            playerDouble = BitmovinPlayerTestDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        context("custom events") {
            var convivaAnalytics: ConvivaAnalytics!
            beforeEach {
                do {
                    convivaAnalytics = try ConvivaAnalytics(player: playerDouble, customerKey: "")
                } catch {
                    fail("ConvivaAnalytics failed with error: \(error)")
                }
            }

            it("send custom playback event") {
                let spy = Spy(aClass: CISClientTestDouble.self, functionName: "sendCustomEvent")
                convivaAnalytics.sendCustomPlaybackEvent(name: "Playback Event",
                                                         attributes: ["Test Case": "Playback"])
                expect(spy).to(
                    haveBeenCalled(withArgs: ["eventName": "Playback Event", "Test Case": "Playback"])
                )
            }

            it("send custom application event") {
                let spy = Spy(aClass: CISClientTestDouble.self, functionName: "sendCustomEvent")
                convivaAnalytics.sendCustomApplicationEvent(name: "Application Event",
                                                            attributes: ["Test Case": "Application"])
                expect(spy).to(
                    haveBeenCalled(withArgs: ["sessionKey": "\(NO_SESSION_KEY)",
                        "eventName": "Application Event",
                        "Test Case": "Application"])
                )
            }
        }
    }

}
