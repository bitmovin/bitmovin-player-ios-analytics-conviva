// swiftlint:disable file_length
//
//  BitmovinPlayerTestDouble.swift
//  BitmovinConvivaAnalytics_Example
//
//  Created by Bitmovin on 08.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import BitmovinPlayer
import Foundation

class BitmovinPlayerTestDouble: BitmovinPlayerStub, TestDoubleDataSource {
    var fakeListener: PlayerListener?
    var fakeSource: Source

    override init() {
        let sourceConfig = SourceConfig(url: URL(string: "http://fake.url")!, type: .hls)
        sourceConfig.title = "FakeSource"
        fakeSource = SourceFactory.createSource(from: sourceConfig)
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
        onPlayerError(
            PlayerErrorEvent(
                code: PlayerError.Code.networkGeneral,
                message: "Test player error",
                data: nil
            ),
            player
        )
    }

    func fakeSourceErrorEvent() {
        guard let onSourceError = fakeListener?.onSourceError else {
            return
        }
        onSourceError(SourceErrorEvent(code: SourceError.Code.general, message: "Test source error", data: nil), player)
    }

    func fakeAdStartedEvent(position: String? = "pre") {
        guard let onAdStarted = fakeListener?.onAdStarted else {
            return
        }
        onAdStarted(
            AdStartedEvent(
                clickThroughUrl: URL(string: "www.google.com")!,
                clientType: .ima,
                indexInQueue: 1,
                duration: 2,
                timeOffset: 3,
                skipOffset: 4,
                position: position,
                ad: BitmovinPlayerTestAd()
            ),
            player
        )
    }

    func fakeAdBreakStartedEvent(position: Double = 0.0) {
        guard let onAdBreakStarted = fakeListener?.onAdBreakStarted else {
            return
        }
        onAdBreakStarted(
            AdBreakStartedEvent(
                adBreak: TestAdBreak(position: position)
            ),
            player
        )
    }

    func fakeAdBreakFinishedEvent(position: Double = 0.0) {
        guard let onAdBreakFinished = fakeListener?.onAdBreakFinished else {
            return
        }
        onAdBreakFinished(
            AdBreakFinishedEvent(
                adBreak: TestAdBreak(position: position)
            ),
            player
        )
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
        onAdSkipped(AdSkippedEvent(ad: BitmovinPlayerTestAd()), player)
    }

    func fakeAdFinishedEvent() {
        guard let onAdFinished = fakeListener?.onAdFinished else {
            return
        }
        onAdFinished(AdFinishedEvent(ad: BitmovinPlayerTestAd()), player)
    }

    func fakeAdErrorEvent() {
        guard let onAdError = fakeListener?.onAdError else {
            return
        }
        onAdError(AdErrorEvent(adItem: nil, code: 1_000, message: "Error Message", adConfig: nil), player)
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

    func fakePlaylistTransitionEvent() {
        guard let onPlaylistTransition = fakeListener?.onPlaylistTransition else {
            return
        }
        onPlaylistTransition(PlaylistTransitionEvent(from: fakeSource, to: fakeSource), player)
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

    override var currentVideoFrameRate: Float {
        25
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

class TestAdBreak: NSObject, AdBreak {
    var identifier: String
    var scheduleTime: TimeInterval
    var ads: [Ad]
    var totalNumberOfAds: UInt
    var replaceContentDuration: TimeInterval

    convenience init(position: Double) {
        self.init(scheduleTime: TimeInterval(floatLiteral: position))
    }

    init(
        identifier: String = "testAdbreak",
        scheduleTime: TimeInterval = TimeInterval(floatLiteral: 0.0),
        ads: [Ad] = [Ad](),
        totalNumberOfAds: UInt = 0,
        replaceContentDuration: TimeInterval = TimeInterval(floatLiteral: 0.0)
    ) {
        self.identifier = identifier
        self.scheduleTime = scheduleTime
        self.ads = ads
        self.totalNumberOfAds = totalNumberOfAds
        self.replaceContentDuration = replaceContentDuration
    }

    func register(_ adItem: Ad) {
        ads.append(adItem)
        totalNumberOfAds = UInt(ads.count)
    }

    // swiftlint:disable:next identifier_name unavailable_function
    func _toJsonString() throws -> String {
        fatalError("Not Implemented")
    }

    // swiftlint:disable:next identifier_name unavailable_function
    func _toJsonData() -> [AnyHashable: Any] {
        fatalError("Not Implemented")
    }
}

class BitmovinPlayerStub: NSObject, Player {
    var latency: BitmovinPlayerCore.LatencyApi {
        player.latency
    }

    var player: Player

    override init() {
        let config = PlayerConfig()
        config.key = "foobar"
        player = PlayerFactory.createPlayer(playerConfig: config)
    }

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

    @available(iOS 15.0, *)
    var sharePlay: SharePlayApi {
        player.sharePlay
    }

    var isOutputObscured: Bool {
        player.isOutputObscured
    }

    // swiftlint:disable:next identifier_name
    var _modules: BitmovinPlayerCore._PlayerModulesApi {
        player._modules
    }

    var events: BitmovinPlayerCore.PlayerEventsApi {
        player.events
    }

    func canPlay(atPlaybackSpeed playbackSpeed: Float) -> Bool {
        player.canPlay(atPlaybackSpeed: playbackSpeed)
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

    override var description: String {
        player.description
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
        player.currentTime(timeMode)
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
    var clickThroughUrlOpened: (() -> Void)?

    var isLinear = false

    var width: Int = 0

    var height: Int = 0

    var identifier: String?

    var mediaFileUrl: URL?

    var clickThroughUrl: URL?

    var data: AdData?

    // swiftlint:disable:next identifier_name
    func _toJsonString() throws -> String {
        ""
    }

    // swiftlint:disable:next identifier_name
    func _toJsonData() -> [AnyHashable: Any] {
        [:]
    }

    // swiftlint:disable:next identifier_name
    static func _fromJsonData(_ jsonData: [AnyHashable: Any]) throws -> Self {
        // swiftlint:disable:next force_cast
        BitmovinPlayerTestAd() as! Self
    }
}
