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
    static var tracker = TestTracker()
    static var double = TestDoubleFactory()
}

class TestTracker {
    var functionTracking: [String: Any] = [:]
    var functionExpectation: String?

    func track(functionName: String, args: [String: String]) {
        functionTracking[functionName] = args
    }

    func hasCalledFunction(_ name: String) -> Bool {
        return functionTracking[name] != nil
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
            return PredicateResult(bool: TestHelper.tracker.hasCalledFunction(functionName),
                                   message: message)
        }

        let message = ExpectationMessage.fail("Invalid Spy")
        return PredicateResult(bool: false, message: message)
    }
}
