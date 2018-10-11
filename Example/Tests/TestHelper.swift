//
//  TestHelper.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by David Steinacher on 08.10.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ConvivaSDK
import Quick
import Nimble

class TestHelper: NSObject {
    static var shared = TestHelper()
    let tracker: TestTracker
    let double: TestDoubleFactory
    let mocking: TestMocker

    private override init() {
        self.tracker = TestTracker()
        self.double = TestDoubleFactory()
        self.mocking = TestMocker()
    }
}

class TestTracker {
    var functionTracking: [String: [String: String]?] = [:]

    func track(functionName: String, args: [String: String]? = nil) {
        functionTracking[functionName] = args
    }

    func hasCalledFunction(_ name: String, withArgs: [String: String]? = nil) -> Bool {
        let called = functionTracking.keys.contains(name)
        if !called {
            return false
        }

        if let expectedArgs = withArgs {
            if let calledArgs = functionTracking[name] {
                var containsExpectedArgs = true
                for key in expectedArgs.keys {
                    containsExpectedArgs = containsExpectedArgs && (calledArgs?[key] == expectedArgs[key])
                }
                return containsExpectedArgs
            }

            return false
        }

        return called
    }

    func reset() {
        functionTracking = [:]
    }
}

class TestMocker {
    var mocking: [String: Any] = [:]

    func addMock(_ name: String, returnValue: Any) {
        mocking[name] = returnValue
    }
}

struct Spy {
    let aClass: Any
    let functionName: String

    init(aClass: Any, functionName: String) {
        self.aClass = aClass
        self.functionName = functionName
    }
}

protocol DoubleDataSource {
    var mocking: [String: Any] { get }
}

extension DoubleDataSource {
    var mocking: [String: Any] {
        return TestHelper.shared.mocking.mocking
    }
}

class Double {
    // can be used for methods and properties
    init(aClass: Any, name: String, return value: Any) {
        TestHelper.shared.mocking.addMock(name, returnValue: value)
    }
}

class TestDoubleFactory {
    func mockConviva() {
        // method swizzling
        let createMethod = class_getClassMethod(CISClientSettingCreator.self,
                                                #selector(CISClientSettingCreator.create(withCustomerKey: )))
        let myCreateMethod = class_getClassMethod(CISClientSettingCreatorDouble.self,
                                                  #selector(CISClientSettingCreatorDouble.myCreate(withCustomerKey:)))
        method_exchangeImplementations(createMethod!, myCreateMethod!)

        let clientCreateMethod = class_getClassMethod(CISClientCreator.self,
                                                      #selector(CISClientCreator.create(withClientSettings:factory:)))
        let myClientCreateMethod = class_getClassMethod(CISClientCreatorDouble.self,
                                                        #selector(CISClientCreatorDouble.create(withClientSettings:factory:)))

        method_exchangeImplementations(clientCreateMethod!, myClientCreateMethod!)
    }
}

public func haveBeenCalled<T>() -> Predicate<T> {
    return Predicate { (actualExpression: Expression<T>) throws -> PredicateResult in

        if let functionName = (try? actualExpression.evaluate() as? Spy)??.functionName {
            let message = ExpectationMessage.expectedTo("have called <\(functionName)>")
            return PredicateResult(bool: TestHelper.shared.tracker.hasCalledFunction(functionName),
                                   message: message)
        }

        let message = ExpectationMessage.fail("Invalid Spy")
        return PredicateResult(bool: false, message: message)
    }
}

public func haveBeenCalled<T>(withArgs: [String: String]) -> Predicate<T> {
    return Predicate { (actualExpression: Expression<T>) throws -> PredicateResult in

        if let functionName = (try? actualExpression.evaluate() as? Spy)??.functionName {
            let message = ExpectationMessage.expectedTo("have called <\(functionName)> with args<\(withArgs)> got <\(TestHelper.shared.tracker.functionTracking[functionName])>")
            return PredicateResult(bool: TestHelper.shared.tracker.hasCalledFunction(functionName, withArgs: withArgs),
                                   message: message)
        }

        let message = ExpectationMessage.fail("Invalid Spy")
        return PredicateResult(bool: false, message: message)
    }
}
