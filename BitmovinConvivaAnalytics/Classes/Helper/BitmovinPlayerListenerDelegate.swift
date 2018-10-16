//
//  BitmovinPlayerListenerDelegate.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 10.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import BitmovinPlayer

protocol BitmovinPlayerListenerDelegate: AnyObject {
    func onEvent(_ event: PlayerEvent)
    func onReady()
    func onSourceLoaded()
    func onSourceUnloaded()
    func onTimeChanged()
    func onError(_ event: ErrorEvent)

    func onMuted(_ event: MutedEvent)
    func onUnmuted(_ event: UnmutedEvent)

    // MARK: - Playback state events
    func onPlay()
    func onPaused()
    func onPlaybackFinished()
    func onStallStarted()
    func onStallEnded()

    // MARK: - Seek / Timeshift events
    func onSeek(_ event: SeekEvent)
    func onSeeked()
    func onTimeShift(_ event: TimeShiftEvent)
    func onTimeShifted()

    #if !os(tvOS)
    // MARK: - Ad events
    func onAdStarted(_ event: AdStartedEvent)
    func onAdFinished()
    func onAdSkipped(_ event: AdSkippedEvent)
    func onAdError(_ event: AdErrorEvent)
    #endif
}
