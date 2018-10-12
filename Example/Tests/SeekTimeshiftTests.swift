// https://github.com/Quick/Quick

import Quick
import Nimble
import BitmovinPlayer
import BitmovinConvivaAnalytics
import ConvivaSDK

class SeekTimeshiftSpec: QuickSpec {
    override func spec() {
        var playerDouble: BitmovinPlayerDouble!

        beforeEach {
            playerDouble = BitmovinPlayerDouble()
            TestHelper.shared.spyTracker.reset()
            TestHelper.shared.mockTracker.reset()
        }

        describe("seek / timeshift") {
            var spy: Spy!
            context("seek start") {
                beforeEach {
                    do {
                        _ = try ConvivaAnalytics(player: playerDouble, customerKey: "")
                    } catch {
                        fail("ConvivaAnalytics failed with error: \(error)")
                    }
                    spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setSeekStart")
                }

                xit("tracked on seek") {
                    // will fail until updates in branch conviva-validation-updates
                    playerDouble.fakeSeekEvent(position: 100)
                    expect(spy).to(haveBeenCalled(withArgs: ["seekToPosition": "100"]))
                }

                xit("tracked on timeshift") {
                    // will fail until updates in branch conviva-validation-updates
                    playerDouble.fakeTimeShiftEvent(position: 100)
                    expect(spy).to(haveBeenCalled(withArgs: ["seekToPosition": "100"]))
                }
            }
            context("seek finished") {
                beforeEach {
                    spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setSeekEnd")

                    do {
                        _ = try ConvivaAnalytics(player: playerDouble, customerKey: "")
                    } catch {
                        fail("ConvivaAnalytics failed with error: \(error)")
                    }

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
