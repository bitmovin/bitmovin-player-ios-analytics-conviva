//
//  BitmovinPlayerTestDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by Bitmovin on 08.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import BitmovinPlayer

class BitmovinPlayerTestDouble: BitmovinPlayer, TestDoubleDataSource {
    var fakeListener: PlayerListener?

    init() {
        super.init(configuration: PlayerConfiguration())
    }

    func fakeReadyEvent() {
        guard let onReady = fakeListener?.onReady else {
            return
        }
        onReady(ReadyEvent())
    }

    func fakePlayEvent() {
        guard let onPlay = fakeListener?.onPlay else {
            return
        }
        onPlay(PlayEvent(time: 1))
    }

    func fakePlayingEvent() {
        guard let onPlaying = fakeListener?.onPlaying else {
            return
        }
        onPlaying(PlayingEvent(time: 1))
    }

    func fakePauseEvent() {
        guard let onPaused = fakeListener?.onPaused else {
            return
        }
        onPaused(PausedEvent(time: 1))
    }

    func fakeStallStartedEvent() {
        guard let onStallStarted = fakeListener?.onStallStarted else {
            return
        }
        onStallStarted(StallStartedEvent())
    }

    func fakeStallEndedEvent() {
        guard let onStallEnded = fakeListener?.onStallEnded else {
            return
        }
        onStallEnded(StallEndedEvent())
    }

    func fakeErrorEvent() {
        guard let onError = fakeListener?.onError else {
            return
        }
        onError(ErrorEvent(code: 1000, message: "Test Error"))
    }

    func fakeAdStartedEvent(position: String? = "pre") {
        guard let onAdStarted = fakeListener?.onAdStarted else {
            return
        }
        onAdStarted(AdStartedEvent(clickThroughUrl: URL(string: "www.google.com")!,
                                   clientType: .IMA,
                                   indexInQueue: 1,
                                   duration: 2,
                                   timeOffset: 3,
                                   skipOffset: 4,
                                   position: position))
    }

    func fakeTimeChangedEvent() {
        guard let onTimeChanged = fakeListener?.onTimeChanged else {
            return
        }
        onTimeChanged(TimeChangedEvent(currentTime: 1))
    }

    func fakeSourceUnloadedEvent() {
        guard let onSourceUnloaded = fakeListener?.onSourceUnloaded else {
            return
        }
        onSourceUnloaded(SourceUnloadedEvent())
    }

    func fakeAdSkippedEvent() {
        guard let onAdSkipped = fakeListener?.onAdSkipped else {
            return
        }
        onAdSkipped(AdSkippedEvent())
    }

    func fakeAdFinishedEvent() {
        guard let onAdFinished = fakeListener?.onAdFinished else {
            return
        }
        onAdFinished(AdFinishedEvent())
    }

    func fakeAdErrorEvent() {
        guard let onAdError = fakeListener?.onAdError else {
            return
        }
        onAdError(AdErrorEvent(adItem: nil, code: 1000, message: "Error Message"))
    }

    func fakeSeekEvent(position: TimeInterval = 0, seekTarget: TimeInterval = 0) {
        guard let onSeek = fakeListener?.onSeek else {
            return
        }
        // seek target returns -DBL_MAX when livestreaming
        onSeek(SeekEvent(position: position, seekTarget: seekTarget))
    }

    func fakeTimeShiftEvent(position: TimeInterval = 0, seekTarget: TimeInterval = 0) {
        guard let onTimeShift = fakeListener?.onTimeShift else {
            return
        }
        // seek target returns -DBL_MAX when livestreaming
        onTimeShift(TimeShiftEvent(position: position, target: seekTarget, timeShift: 0))
    }

    func fakeSeekedEvent() {
        guard let onSeeked = fakeListener?.onSeeked else {
            return
        }
        onSeeked(SeekedEvent())
    }

    func fakeTimeShiftedEvent() {
        guard let onTimeShifted = fakeListener?.onTimeShifted else {
            return
        }
        onTimeShifted(TimeShiftedEvent())
    }

    func fakePlaybackFinishedEvent() {
        guard let onPlaybackFinished = fakeListener?.onPlaybackFinished else {
            return
        }
        onPlaybackFinished(PlaybackFinishedEvent())
    }

    override func add(listener: PlayerListener) {
        self.fakeListener = listener
    }

    override var isPlaying: Bool {
        if let mockedValue = mocks["isPlaying"] {
            // swiftlint:disable:next force_cast
            return mockedValue as! Bool
        }
        return true
    }

    override var duration: TimeInterval {
        if let mockedValue = mocks["duration"] {
            // swiftlint:disable:next force_cast
            return mockedValue as! TimeInterval
        }
        return 60
    }

    override var config: PlayerConfiguration {
        if let mockedValue = mocks["config"] {
            // swiftlint:disable:next force_cast
            return mockedValue as! PlayerConfiguration
        }
        return super.config
    }

    override var isLive: Bool {
        if let mockedValue = mocks["isLive"] {
            // swiftlint:disable:next force_cast
            return mockedValue as! Bool
        }
        return super.isLive
    }

    override var streamType: BMPMediaSourceType {
        if let mockedValue = mocks["streamType"] {
            // swiftlint:disable:next force_cast
            return mockedValue as! BMPMediaSourceType
        }
        return super.streamType
    }

    override var videoQuality: VideoQuality? {
        if let mockedValue = mocks["videoQuality"] {
            return mockedValue as? VideoQuality
        }
        return super.videoQuality
    }

    override var currentTime: TimeInterval {
        if let mockedValue = mocks["currentTime"] {
            // swiftlint:disable:next force_cast
            return mockedValue as! TimeInterval
        }
        return super.currentTime
    }
}
