//
//  ExternallyManagedSessionTests.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 30.01.19.
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

            afterEach {
                if convivaAnalytics != nil {
                    convivaAnalytics = nil
                }
            }

            context("report playback deficiency") {
                var spy: Spy!

                beforeEach {
                    spy = Spy(aClass: CISClientTestDouble.self, functionName: "reportError")
                }

                it("no-opt if no session is running") {
                    convivaAnalytics.reportPlaybackDeficiency(message: "Test", severity: .ERROR_FATAL)
                    expect(spy).toNot(haveBeenCalled())
                }

                context("reports a deficiency") {
                    beforeEach {
                        playerDouble.fakePlayEvent()
                    }

                    it("reports a warning") {
                        let severity = ErrorSeverity.ERROR_WARNING
                        convivaAnalytics.reportPlaybackDeficiency(message: "Test", severity: .ERROR_WARNING)
                        expect(spy).to(haveBeenCalled(withArgs: ["severity": "\(severity.rawValue)"]))
                    }

                    it("reports an error") {
                        let severity = ErrorSeverity.ERROR_FATAL
                        convivaAnalytics.reportPlaybackDeficiency(message: "Test", severity: .ERROR_FATAL)
                        expect(spy).to(haveBeenCalled(withArgs: ["severity": "\(severity.rawValue)"]))
                    }

                    context("session closing handling") {
                        beforeEach {
                            spy = Spy(aClass: CISClientTestDouble.self, functionName: "cleanupSession")
                        }
                        it("closes session by default") {
                            convivaAnalytics.reportPlaybackDeficiency(message: "Test", severity: .ERROR_FATAL)
                            expect(spy).to(haveBeenCalled())
                        }

                        it("closes session if set to true") {
                            convivaAnalytics.reportPlaybackDeficiency(message: "Test", severity: .ERROR_FATAL)
                            expect(spy).to(haveBeenCalled())
                        }

                        it("not closes session if set to false") {
                            convivaAnalytics.reportPlaybackDeficiency(message: "Test",
                                                                      severity: .ERROR_FATAL,
                                                                      endSession: false)
                            expect(spy).toNot(haveBeenCalled())
                        }
                    }
                }
            }
        }
    }
}
