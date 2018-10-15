// https://github.com/Quick/Quick

import Quick
import Nimble
import BitmovinPlayer
import BitmovinConvivaAnalytics
import ConvivaSDK

class SeekTimeshiftSpec: QuickSpec {
    override func spec() {
        var playerDouble: BitmovinPlayerTestDouble!

        beforeEach {
            playerDouble = BitmovinPlayerTestDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        describe("seek / timeshift") {
            var spy: Spy!
            var convivaAnalytics: ConvivaAnalytics!
            beforeEach {
                do {
                    convivaAnalytics = try ConvivaAnalytics(player: playerDouble, customerKey: "")
                } catch {
                    fail("ConvivaAnalytics failed with error: \(error)")
                }
                spy = Spy(aClass: PlayerStateManagerTestDouble.self, functionName: "setSeekStart")
            }

            afterEach {
                if convivaAnalytics != nil {
                    convivaAnalytics = nil
                }
            }

            context("seek start") {
                it("tracked on seek") {
                    playerDouble.fakeSeekEvent(position: 100)
                    expect(spy).to(haveBeenCalled(withArgs: ["seekToPosition": "100"]))
                }

                it("tracked on timeshift") {
                    playerDouble.fakeTimeShiftEvent(position: 100)
                    expect(spy).to(haveBeenCalled(withArgs: ["seekToPosition": "100"]))
                }
            }
            context("seek finished") {
                beforeEach {
                    spy = Spy(aClass: PlayerStateManagerTestDouble.self, functionName: "setSeekEnd")
                    _ = TestDouble(aClass: playerDouble, name: "currentTime", return: TimeInterval(100))
                }

                it("tracked on seeked") {
                    playerDouble.fakeSeekedEvent()
                    expect(spy).to(haveBeenCalled(withArgs: ["seekPosition": "100"]))
                }

                it("tracked on timeshifted") {
                    playerDouble.fakeTimeShiftedEvent()
                    expect(spy).to(haveBeenCalled(withArgs: ["seekPosition": "100"]))
                }
            }
        }

    }
}
