//
//  CustomNimbleMatchers.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by Bitmovin on 11.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import Nimble

public func haveBeenCalled<T>(withArgs: [String: String]? = nil) -> Nimble.Predicate<T> {
    Predicate { (actualExpression: Expression<T>) throws -> PredicateResult in
        if let functionName = (try? actualExpression.evaluate() as? Spy)??.functionName {
            let spyTracker = TestHelper.shared.spyTracker

            var spyResult = spyTracker.hasCalledFunction(functionName)
            let spyWasCalled: Bool = spyResult.success
            var argsAreMatching = true // expect best case for the case no args where expected

            let message: ExpectationMessage!
            if spyWasCalled {
                if let expectedArgs = withArgs {
                    spyResult = spyTracker.hasCalledFunction(functionName, withArgs: expectedArgs)
                    argsAreMatching = spyResult.success

                    let messageString: String!
                    if let trackedArgs = spyResult.trackedArgs {
                        messageString = "have called <\(functionName)> with args<\(expectedArgs)> got <\(trackedArgs)>"
                    } else {
                        messageString = "have called <\(functionName)> with args<\(expectedArgs)> got <nil>"
                    }
                    message = ExpectationMessage.expectedTo(messageString)
                } else {
                    // Success message (will never be shown but is needed)
                    message = ExpectationMessage.expectedTo("have called <\(functionName)>")
                }
            } else {
                message = ExpectationMessage.expectedTo("have called <\(functionName)> but was not called")
            }

            return PredicateResult(
                bool: spyWasCalled && argsAreMatching,
                message: message
            )
        }

        let message = ExpectationMessage.fail("Invalid Spy")
        return PredicateResult(bool: false, message: message)
    }
}
