//
//  CustomNimbleMatchers.swift
//  BitmovinConvivaAnalytics_Tests
//
//  Created by David Steinacher on 11.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Nimble

public func haveBeenCalled<T>() -> Predicate<T> {
    return Predicate { (actualExpression: Expression<T>) throws -> PredicateResult in

        if let functionName = (try? actualExpression.evaluate() as? Spy)??.functionName {
            let message = ExpectationMessage.expectedTo("have called <\(functionName)>")
            return PredicateResult(bool: TestHelper.shared.spyTracker.hasCalledFunction(functionName),
                                   message: message)
        }

        let message = ExpectationMessage.fail("Invalid Spy")
        return PredicateResult(bool: false, message: message)
    }
}

public func haveBeenCalled<T>(withArgs: [String: String]) -> Predicate<T> {
    return Predicate { (actualExpression: Expression<T>) throws -> PredicateResult in

        if let functionName = (try? actualExpression.evaluate() as? Spy)??.functionName {
            let message = ExpectationMessage.expectedTo("have called <\(functionName)> with args<\(withArgs)> got <\(TestHelper.shared.spyTracker.spies[functionName])>")
            return PredicateResult(bool: TestHelper.shared.spyTracker.hasCalledFunction(functionName, withArgs: withArgs),
                                   message: message)
        }

        let message = ExpectationMessage.fail("Invalid Spy")
        return PredicateResult(bool: false, message: message)
    }
}
