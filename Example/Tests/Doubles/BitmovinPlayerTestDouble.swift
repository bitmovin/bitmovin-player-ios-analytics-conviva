//
//  BitmovinPlayerTestDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by Bitmovin on 08.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation
import BitmovinPlayer

class BitmovinPlayerTestDouble: BitmovinPlayerStub, TestDoubleDataSource {

    var fakeListener: PlayerListener?

    var fakeSource: Source

    override init() {
        let sourceConfig = SourceConfig(url: URL(string: "http://fake.url")!, type: .hls)
        sourceConfig.title = "FakeSource"
        fakeSource = SourceFactory.create(from: sourceConfig)
        super.init()
    }

    func fakeReadyEvent() {
        guard let onReady = fakeListener?.onReady else {
            return
        }
        onReady(ReadyEvent(), player)
    }

    func fakePlayEvent() {
        guard let onPlay = fakeListener?.onPlay else {
            return
        }
        onPlay(PlayEvent(time: 1), player)
    }

    func fakePlayingEvent() {
        guard let onPlaying = fakeListener?.onPlaying else {
            return
        }
        onPlaying(PlayingEvent(time: 1), player)
    }

    func fakePauseEvent() {
        guard let onPaused = fakeListener?.onPaused else {
            return
        }
        onPaused(PausedEvent(time: 1), player)
    }

    func fakeStallStartedEvent() {
        guard let onStallStarted = fakeListener?.onStallStarted else {
            return
        }
        onStallStarted(StallStartedEvent(), player)
    }

    func fakeStallEndedEvent() {
        guard let onStallEnded = fakeListener?.onStallEnded else {
            return
        }
        onStallEnded(StallEndedEvent(), player)
    }

    func fakePlayerErrorEvent() {
        guard let onPlayerError = fakeListener?.onPlayerError else {
            return
        }
        // onPlayerError(PlayerErrorEvent(code: 1000, message: "Test error", data: nil), self.player)
    }

    func fakeSourceErrorEvent() {
        guard let onSourceError = fakeListener?.onSourceError else {
            return
        }
        // onSourceError(SourceErrorEvent(code: 1000, message: "Test Error", data: nil), player)
    }

    func fakeAdStartedEvent(position: String? = "pre") {
        guard let onAdStarted = fakeListener?.onAdStarted else {
            return
        }
        onAdStarted(AdStartedEvent(clickThroughUrl: URL(string: "www.google.com")!,
                                   clientType: .ima,
                                   indexInQueue: 1,
                                   duration: 2,
                                   timeOffset: 3,
                                   skipOffset: 4,
                                   position: position,
                                   ad: (BitmovinPlayerTestAd() as Ad)), player)
    }

    func fakeTimeChangedEvent() {
        guard let onTimeChanged = fakeListener?.onTimeChanged else {
            return
        }
        onTimeChanged(TimeChangedEvent(currentTime: 1), player)
    }

    func fakeSourceUnloadedEvent() {
        guard let onSourceUnloaded = fakeListener?.onSourceUnloaded else {
            return
        }
        onSourceUnloaded(SourceUnloadedEvent(source: fakeSource), player)
    }

    func fakeAdSkippedEvent() {
        guard let onAdSkipped = fakeListener?.onAdSkipped else {
            return
        }
        onAdSkipped(AdSkippedEvent(ad: BitmovinPlayerTestAd() as Ad), player)
    }

    func fakeAdFinishedEvent() {
        guard let onAdFinished = fakeListener?.onAdFinished else {
            return
        }
        onAdFinished(AdFinishedEvent(ad: BitmovinPlayerTestAd() as Ad), player)
    }

    func fakeAdErrorEvent() {
        guard let onAdError = fakeListener?.onAdError else {
            return
        }
        onAdError(AdErrorEvent(adItem: nil, code: 1000, message: "Error Message", adConfig: nil), player)
    }

    func fakeSeekEvent(position: TimeInterval = 0, seekTarget: TimeInterval = 0) {
        guard let onSeek = fakeListener?.onSeek else {
            return
        }
        // seek target returns -DBL_MAX when livestreaming
        let fromSeekPos = SeekPosition(source: fakeSource, time: position)
        let toSeekPos = SeekPosition(source: fakeSource, time: seekTarget)
        onSeek(SeekEvent(from: fromSeekPos, to: toSeekPos), player)
    }

    func fakeTimeShiftEvent(position: TimeInterval = 0, seekTarget: TimeInterval = 0) {
        guard let onTimeShift = fakeListener?.onTimeShift else {
            return
        }
        // seek target returns -DBL_MAX when livestreaming
        onTimeShift(TimeShiftEvent(position: position, target: seekTarget, timeShift: 0), player)
    }

    func fakeSeekedEvent() {
        guard let onSeeked = fakeListener?.onSeeked else {
            return
        }
        onSeeked(SeekedEvent(), player)
    }

    func fakeTimeShiftedEvent() {
        guard let onTimeShifted = fakeListener?.onTimeShifted else {
            return
        }
        onTimeShifted(TimeShiftedEvent(), player)
    }

    func fakePlaybackFinishedEvent() {
        guard let onPlaybackFinished = fakeListener?.onPlaybackFinished else {
            return
        }
        onPlaybackFinished(PlaybackFinishedEvent(), player)
    }

    func fakeDestroyEvent() {
        guard let onDestroyEvent = fakeListener?.onDestroy else {
            return
        }
        onDestroyEvent(DestroyEvent(), player)
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

    override var config: PlayerConfig {
        if let mockedValue = mocks["config"] {
            // swiftlint:disable:next force_cast
            return mockedValue as! PlayerConfig
        }
        return player.config
    }

    override var source: Source {
        if let mockedValue = mocks["source"] {
            // swiftlint:disable:next force_cast
            return mockedValue as! Source
        }
        return player.source ?? fakeSource
    }

    override var isLive: Bool {
        if let mockedValue = mocks["isLive"] {
            // swiftlint:disable:next force_cast
            return mockedValue as! Bool
        }
        return player.isLive
    }

    override var videoQuality: VideoQuality? {
        if let mockedValue = mocks["videoQuality"] {
            return mockedValue as? VideoQuality
        }
        return player.videoQuality
    }

    override var currentTime: TimeInterval {
        if let mockedValue = mocks["currentTime"] {
            // swiftlint:disable:next force_cast
            return mockedValue as! TimeInterval
        }
        return player.currentTime
    }
}

class BitmovinPlayerStub: Player {
    var isDestroyed: Bool {
        player.isDestroyed
    }

    var isMuted: Bool {
        player.isMuted
    }

    var volume: Int {
        get {
            player.volume
        }
        set {
            player.volume = newValue
        }
    }

    var isPaused: Bool {
        player.isPaused
    }

    var isPlaying: Bool {
        player.isPlaying
    }

    var isLive: Bool {
        player.isLive
    }

    var duration: TimeInterval {
        player.duration
    }

    var currentTime: TimeInterval {
            player.currentTime
    }

    var config: PlayerConfig {
        player.config
    }

    var source: Source? {
        player.source
    }

    var maxTimeShift: TimeInterval {
        player.maxTimeShift
    }

    var timeShift: TimeInterval {
        get {
            player.timeShift
        }
        set {
            player.timeShift = newValue
        }
    }

    var availableSubtitles: [SubtitleTrack] {
        player.availableSubtitles
    }

    var subtitle: SubtitleTrack {
        player.subtitle
    }

    var availableAudio: [AudioTrack] {
        player.availableAudio
    }

    var audio: AudioTrack? {
        player.audio
    }

    var isAd: Bool {
        player.isAd
    }

    var isAirPlayActive: Bool {
        player.isAirPlayActive
    }

    var isAirPlayAvailable: Bool {
        player.isAirPlayAvailable
    }

    var availableVideoQualities: [VideoQuality] {
        player.availableVideoQualities
    }

    var videoQuality: VideoQuality? {
        player.videoQuality
    }

    var playbackSpeed: Float {
        get {
            player.playbackSpeed
        }
        set {
            player.playbackSpeed = newValue
        }
    }

    var maxSelectableBitrate: UInt {
        get {
            player.maxSelectableBitrate
        }
        set {
            player.maxSelectableBitrate = newValue
        }
    }

    var currentVideoFrameRate: Float {
            player.currentVideoFrameRate
    }

    var buffer: BufferApi {
            player.buffer
    }

    var playlist: PlaylistApi {
        player.playlist
    }

    var isCasting: Bool {
        player.isCasting
    }

    var isWaitingForDevice: Bool {
        player.isWaitingForDevice
    }

    var isCastAvailable: Bool {
        player.isCastAvailable
    }

    var description: String {
        player.description
    }

    var player: Player

    init() {
        let config = PlayerConfig()
        config.key = "foobar"
        player = PlayerFactory.create(playerConfig: config)
    }

    func load(sourceConfig: SourceConfig) {
        player.load(sourceConfig: sourceConfig)
    }

    func load(source: Source) {
        player.load(source: source)
    }

    func load(playlistConfig: PlaylistConfig) {
        player.load(playlistConfig: playlistConfig)
    }

    func unload() {
        player.unload()
    }

    func destroy() {
        player.destroy()
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func seek(time: TimeInterval) {
        player.seek(time: time)
    }

    func mute() {
        player.mute()
    }

    func unmute() {
        player.unmute()
    }

    func addSubtitle(track subtitleTrack: SubtitleTrack) {
        player.addSubtitle(track: subtitleTrack)
    }

    func removeSubtitle(trackIdentifier subtitleTrackID: String) {
        player.removeSubtitle(trackIdentifier: subtitleTrackID)
    }

    func setSubtitle(trackIdentifier subtitleTrackID: String?) {
        player.setSubtitle(trackIdentifier: subtitleTrackID)
    }

    func setAudio(trackIdentifier audioTrackID: String) {
        player.setAudio(trackIdentifier: audioTrackID)
    }

    func thumbnail(forTime time: TimeInterval) -> Thumbnail? {
        player.thumbnail(forTime: time)
    }

    func skipAd() {
        player.skipAd()
    }

    func scheduleAd(adItem: AdItem) {
        player.scheduleAd(adItem: adItem)
    }

    func showAirPlayTargetPicker() {
        player.showAirPlayTargetPicker()
    }

    func currentTime(_ timeMode: TimeMode) -> TimeInterval {
        return player.currentTime(timeMode)
    }

    func register(_ playerLayer: AVPlayerLayer) {
        player.register(playerLayer)
    }

    func unregisterPlayerLayer(_ playerLayer: AVPlayerLayer) {
        player.unregisterPlayerLayer(playerLayer)
    }

    func register(_ playerViewController: AVPlayerViewController) {
        player.register(playerViewController)
    }

    func unregisterPlayerViewController(_ playerViewController: AVPlayerViewController) {
        player.unregisterPlayerViewController(playerViewController)
    }

    func registerAdContainer(_ adContainer: UIView) {
        player.registerAdContainer(adContainer)
    }

    func setSubtitleStyles(_ subtitleStyles: [AVTextStyleRule]?) {
        player.setSubtitleStyles(subtitleStyles)
    }

    func isEqual(_ object: Any?) -> Bool {
        false
    }

    var hash: Int {
        player.hash

    }

    var superclass: AnyClass?

    func `self`() -> Self {
        // swiftlint:disable:next force_cast
        return player.self as! Self
    }

    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return nil
    }

    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }

    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }

    func isProxy() -> Bool {
        return false
    }

    func isKind(of aClass: AnyClass) -> Bool {
        return false
    }

    func isMember(of aClass: AnyClass) -> Bool {
        return false
    }

    func conforms(to aProtocol: Protocol) -> Bool {
        return false
    }

    func responds(to aSelector: Selector!) -> Bool {
        return false
    }

    func add(listener: PlayerListener) {
        player.add(listener: listener)
    }

    func remove(listener: PlayerListener) {
        player.remove(listener: listener)
    }

    func castStop() {
        //
    }

    func castVideo() {
        //
    }
}

class BitmovinPlayerTestAd: NSObject, Ad {

    var isLinear: Bool = false

    var width: Int = 0

    var height: Int = 0

    var identifier: String?

    var mediaFileUrl: URL?

    var clickThroughUrl: URL?

    var data: AdData?

    // swiftlint:disable:next identifier_name
    func _toJsonString() throws -> String {
        return ""
    }

    // swiftlint:disable:next identifier_name
    func _toJsonData() -> [AnyHashable: Any] {
        return [:]
    }

    // swiftlint:disable:next identifier_name
    static func _fromJsonData(_ jsonData: [AnyHashable: Any]) throws -> Self {
        // swiftlint:disable:next force_cast
        return BitmovinPlayerTestAd() as! Self
    }
}
