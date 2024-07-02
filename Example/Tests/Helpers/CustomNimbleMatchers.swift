//
//  CustomNimbleMatchers.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import Nimble

public func haveBeenCalled<T>(withArgs args: [String: String]? = nil) -> Matcher<T> {
    Matcher { (actualExpression: Nimble.Expression<T>) throws -> MatcherResult in
        if let functionName = (try? actualExpression.evaluate() as? Spy)??.functionName {
            let spyTracker = TestHelper.shared.spyTracker

            var spyResult = spyTracker.hasCalledFunction(functionName)
            let spyWasCalled: Bool = spyResult.success
            var argsAreMatching = true // expect best case for the case no args where expected

            let message: ExpectationMessage!
            if spyWasCalled {
                if let expectedArgs = args {
                    spyResult = spyTracker.hasCalledFunction(functionName, withArgs: expectedArgs)
                    argsAreMatching = spyResult.success

                    let messageString = """
                                        have called <\(functionName)> \
                                        with args<\(expectedArgs.toStringWithStableOrder())> \
                                        got <\(spyResult.trackedArgs)>
                                        """
                    message = ExpectationMessage.expectedTo(messageString)
                } else {
                    // Success message (will never be shown but is needed)
                    message = ExpectationMessage.expectedTo("have called <\(functionName)>")
                }
            } else {
                message = ExpectationMessage.expectedTo("have called <\(functionName)> but was not called")
            }

            return MatcherResult(
                bool: spyWasCalled && argsAreMatching,
                message: message
            )
        }

        let message = ExpectationMessage.fail("Invalid Spy")
        return MatcherResult(bool: false, message: message)
    }
}
