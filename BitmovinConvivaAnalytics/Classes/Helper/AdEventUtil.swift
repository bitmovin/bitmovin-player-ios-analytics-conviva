//
//  AdEventUtil.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 04.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import BitmovinPlayer
import ConvivaSDK

final class AdEventUtil {
    static let positionRegexPattern = "pre|post|[0-9]+%|([0-9]+:)?([0-9]+:)?[0-9]+(\\.[0-9]+)?"

    static func parseAdPosition(event: AdStartedEvent, contentDuration: TimeInterval) -> ConvivaSDK.AdPosition {
        guard let position = event.position else {
            return .ADPOSITION_PREROLL
        }

        if position.range(of: positionRegexPattern, options: .regularExpression, range: nil, locale: nil) == nil {
            return .ADPOSITION_PREROLL // return PreRoll if position is invalid
        }

        if position.contains("%") {
            return parsePercentage(position: position)
        }

        if position.contains(":") {
            return parseTime(position: position, contentDuration)
        }

        return parseStringPosition(position: position)
    }

    private static func parsePercentage(position: String) -> ConvivaSDK.AdPosition {
        let position = position.replacingOccurrences(of: "%", with: "")
        let percentageValue = Double(position)
        if percentageValue == 0 {
            return .ADPOSITION_PREROLL
        } else if percentageValue == 100 {
            return .ADPOSITION_POSTROLL
        } else {
            return .ADPOSITION_MIDROLL
        }
    }

    private static func parseTime(position: String, _ contentDuration: TimeInterval) -> ConvivaSDK.AdPosition {
        let stringParts = position.split(separator: ":")
        var seconds = 0.0
        let secondFactors: [Double] = [1, 60, 60 * 60, 60 * 60 * 24]
        for (index, part) in stringParts.reversed().enumerated() {
            seconds += (Double(part) ?? 0) * secondFactors[index]
        }

        if seconds == 0 {
            return .ADPOSITION_PREROLL
        } else if seconds == Double(contentDuration) {
            return .ADPOSITION_POSTROLL
        } else {
            return .ADPOSITION_MIDROLL
        }
    }

    private static func parseStringPosition(position: String) -> ConvivaSDK.AdPosition {
        switch position {
        case "pre":
            return .ADPOSITION_PREROLL
        case "post":
            return .ADPOSITION_POSTROLL
        default:
            return .ADPOSITION_MIDROLL
        }
    }
}
