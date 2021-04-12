//
//  BitmovinPlayerListener.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 10.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import BitmovinPlayer

class BitmovinPlayerListener: NSObject {
    let player: BitmovinPlayer
    weak var delegate: BitmovinPlayerListenerDelegate?

    init(player: BitmovinPlayer) {
        self.player = player
        super.init()
        self.player.add(listener: self)
    }

    deinit {
        player.remove(listener: self)
    }
}

extension BitmovinPlayerListener: PlayerListener {
    func onEvent(_ event: PlayerEvent) {
        delegate?.onEvent(event)
    }

    func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        // The default SDK error handling is that it triggers the onSourceUnloaded before the onError event.
        // To track errors to conviva we need to delay the onSourceUnloaded to ensure the onError event is
        // called first.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.delegate?.onSourceUnloaded()
        }
    }

    func onTimeChanged(_ event: TimeChangedEvent) {
        delegate?.onTimeChanged()
    }

    func onError(_ event: ErrorEvent) {
        delegate?.onError(event)
    }

    func onMuted(_ event: MutedEvent) {
        delegate?.onMuted(event)
    }

    func onUnmuted(_ event: UnmutedEvent) {
        delegate?.onUnmuted(event)
    }

    // MARK: - Playback state events
    func onPlay(_ event: PlayEvent) {
        delegate?.onPlay()
    }

    func onPlaying(_ event: PlayingEvent) {
        delegate?.onPlaying()
    }

    func onPaused(_ event: PausedEvent) {
        delegate?.onPaused()
    }

    func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        delegate?.onPlaybackFinished()
    }

    func onStallStarted(_ event: StallStartedEvent) {
        delegate?.onStallStarted()
    }

    func onStallEnded(_ event: StallEndedEvent) {
        delegate?.onStallEnded()
    }

    // MARK: - Seek / Timeshift events
    func onSeek(_ event: SeekEvent) {
        delegate?.onSeek(event)
    }

    func onSeeked(_ event: SeekedEvent) {
        delegate?.onSeeked()
    }

    func onTimeShift(_ event: TimeShiftEvent) {
        delegate?.onTimeShift(event)
    }

    func onTimeShifted(_ event: TimeShiftedEvent) {
        delegate?.onTimeShifted()
    }

    #if !os(tvOS)
    // MARK: - Ad events
    func onAdStarted(_ event: AdStartedEvent) {
        delegate?.onAdStarted(event)
    }

    func onAdFinished(_ event: AdFinishedEvent) {
        delegate?.onAdFinished()
    }

    func onAdSkipped(_ event: AdSkippedEvent) {
        delegate?.onAdSkipped(event)
    }

    func onAdError(_ event: AdErrorEvent) {
        delegate?.onAdError(event)
    }
    
    func onAdBreakStarted(_ event : AdBreakStartedEvent) {
        delegate?.onAdBreakStarted(event)
    }
    
    func onAdBreakFinished(_ event : AdBreakFinishedEvent) {
        delegate?.onAdBreakFinished(event)
    }
    #endif

    func onDestroy(_ event: DestroyEvent) {
        delegate?.onDestroy()
    }
}
