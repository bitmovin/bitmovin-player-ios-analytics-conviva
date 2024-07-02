//
// Bitmovin Player iOS SDK
// Copyright (C) 2024, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import Foundation

public class SsaiApi {
    internal weak var delegate: SsaiApiDelegate?

    /// Checks if a server-side ad break is currently active.
    ///
    /// - Returns: `true` if a server-side ad break is active, `false` otherwise.
    public var isAdBreakActive: Bool {
        delegate?.ssaiApi_isAdBreakActive ?? false
    }

    /// Reports the start of a server-side ad break. Must be called before the first ad starts.
    /// Has no effect if a server-side ad break is already playing.
    public func reportAdBreakStarted() {
        delegate?.ssaiApi_reportAdBreakStarted()
    }

    /// Reports the start of a server-side ad break. Must be called before the first ad starts.
    /// Has no effect if a server-side ad break is already playing.
    ///
    /// - Parameter adBreakInfo: Dictionary containing metadata about the server-side ad break. Can be `nil`.
    public func reportAdBreakStarted(adBreakInfo: [String: Any]?) {
        delegate?.ssaiApi_reportAdBreakStarted(adBreakInfo: adBreakInfo)
    }

    /// Reports the end of a server-side ad break. Must be called after the last ad has finished.
    /// Has no effect if no server-side ad break is currently playing.
    public func reportAdBreakFinished() {
        delegate?.ssaiApi_reportAdBreakFinished()
    }

    /// Reports the start of a server-side ad.
    ///
    /// - Parameter adInfo: Object containing metadata about the server-side ad.
    public func reportAdStarted(adInfo: SsaiAdInfo) {
        delegate?.ssaiApi_reportAdStarted(adInfo: adInfo)
    }

    /// Reports the end of a server-side ad.
    /// Has no effect if no server-side ad is currently playing.
    public func reportAdFinished() {
        delegate?.ssaiApi_reportAdFinished()
    }

    /// Reports that the current ad was skipped.
    /// Has no effect if no server-side ad is playing.
    public func reportAdSkipped() {
        delegate?.ssaiApi_reportAdSkipped()
    }

    /// Updates the ad metadata during an active client-side or server-side ad.
    /// Has no effect if no server-side ad is playing.
    ///
    /// - Parameter adInfo: Object containing metadata about the ad.
    public func update(adInfo: SsaiAdInfo) {
        delegate?.ssaiApi_update(adInfo: adInfo)
    }
}
