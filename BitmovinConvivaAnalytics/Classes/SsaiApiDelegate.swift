//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

internal protocol SsaiApiDelegate: AnyObject {
    // swiftlint:disable:next identifier_name
    var ssaiApi_isAdBreakActive: Bool { get }
    func ssaiApi_reportAdBreakStarted()
    func ssaiApi_reportAdBreakStarted(adBreakInfo: [String: Any]?)
    func ssaiApi_reportAdBreakFinished()
    func ssaiApi_reportAdStarted(adInfo: SsaiAdInfo)
    func ssaiApi_reportAdFinished()
    func ssaiApi_reportAdSkipped()
    func ssaiApi_update(adInfo: SsaiAdInfo)
}
