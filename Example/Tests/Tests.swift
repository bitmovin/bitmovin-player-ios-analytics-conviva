// https://github.com/Quick/Quick

import Quick
import Nimble
import BitmovinPlayer
import BitmovinConvivaAnalytics
import ConvivaSDK

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        beforeSuite {
            TestHelper.double.mockConviva()
        }
        describe("these will fail") {

            it("or maybe not / will success") {
                let playerMock = BitmovinPlayerDouble()
                do {
                    _ = try ConvivaAnalytics(player: playerMock, customerKey: "")
                    playerMock.fakeEvent()

                    let spy = Spy(aClass: PlayerStateManagerDouble.self, functionName: "setPlayerState")
                    expect(spy).to(haveBeenCalled())

                } catch {
                    expect(1).to(equal(2)) // TODO: let the test fail
                }
            }
        }
    }
}
