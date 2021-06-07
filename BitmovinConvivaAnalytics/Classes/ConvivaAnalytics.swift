//
//  ConvivaAnalytics.swift
//  BitmovinConvivaAnalytics
//
//  Created by Bitmovin on 02.10.18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import BitmovinPlayer
import ConvivaSDK
import Foundation

public final class ConvivaAnalytics: NSObject {
    // MARK: - Bitmovin Player attributes

    let player: BitmovinPlayer

    // MARK: - Conviva related attributes

    let customerKey: String
    let config: ConvivaConfiguration
    var analytics: CISAnalytics?
    var videoAnalytics: CISVideoAnalytics?
    var adAnalytics: CISAdAnalytics?
    let contentMetadataBuilder: ContentMetadataBuilder
    var isSessionActive: Bool {
        return analytics != nil
    }

    // The BitmovinPlayerListener is used to prevent listener methods to be public and therefore
    // preventing calling from outside.
    var listener: BitmovinPlayerListener?

    // MARK: - Helper

    let logger: Logger
    let playerHelper: BitmovinPlayerHelper
    // Workaround for player issue when onPlay is sent while player is stalled
    var isStalled: Bool = false

    // MARK: - Public Attributes

    /**
     Set the BMPBitmovinPlayerView to enable view triggered events like fullscreen state changes
     */
    public var playerView: BMPBitmovinPlayerView? {
        didSet {
            playerView?.remove(listener: self)
            playerView?.add(listener: self)
        }
    }

    public var version: String {
        var options: NSDictionary?
        if let path = Bundle(for: ConvivaAnalytics.self).path(forResource: "BitmovinConviva-Info", ofType: "plist") {
            options = NSDictionary(contentsOfFile: path)

            if let version = options?["CFBundleShortVersionString"] as? String {
                return version
            }
        }
        // Should not happen but keep it failsafe
        return ""
    }

    // MARK: - initializer

    /**
     Initialize a new Bitmovin Conviva Analytics object to track metrics from BitmovinPlayer

     **!! ConvivaAnalytics must be instantiated before calling player.setup() !!**

     - Parameters:
        - player: BitmovinPlayer instance to track
        - customerKey: Conviva customerKey
        - config: ConvivaConfiguration object (see ConvivaConfiguration for more information)

     - Throws: Convivas `CISClientProtocol` and `CISClientSettingsProtocol` if an error occurs
     */
    public init?(player: BitmovinPlayer,
                 customerKey: String,
                 config: ConvivaConfiguration = ConvivaConfiguration()) throws {
        self.player = player
        playerHelper = BitmovinPlayerHelper(player: player)
        self.customerKey = customerKey
        self.config = config

        logger = Logger(loggingEnabled: config.debugLoggingEnabled)
        contentMetadataBuilder = ContentMetadataBuilder(logger: logger)

        super.init()

        listener = BitmovinPlayerListener(player: player)
        listener?.delegate = self
    }

    deinit {
        internalEndSession()
    }

    // MARK: - event handling

    /**
     Sends a custom application-level event to Conviva's Player Insight. An application-level event can always
     be sent and is not tied to a specific video.

     - Parameters:
        - name: The name of the event
        - attributes: A dictionary with custom event attributes
     */
    public func sendCustomApplicationEvent(name: String, attributes: [String: String] = [:]) {
        analytics?.reportAppEvent(name, details: attributes)
    }

    /**
     Sends a custom playback-level event to Conviva's Player Insight. A playback-level event can only be sent
     during an active video session.

     - Parameters:
        - name: The name of the event
        - attributes: A dictionary with custom event attributes
     */
    public func sendCustomPlaybackEvent(name: String, attributes: [String: String] = [:]) {
        if !isSessionActive {
            logger.debugLog(message: "Cannot send playback event, no active monitoring session")
            return
        }
        analytics?.reportAppEvent(name, details: attributes)
    }

    // MARK: - external session handling

    /**
     Will update the contentMetadata which are tracked with conviva.

     If there is an active session only permitted values will be updated and propagated immediately.
     If there is no active session the values will be set on session creation.

     Attributes set via this method will override automatic tracked once.
     - Parameters:
        - metadataOverrides: Metadata attributes which will be used to track to conviva.
                             @see ContentMetadataBuilder for more information about permitted attributes
     */
    public func updateContentMetadata(metadataOverrides: MetadataOverrides) {
        contentMetadataBuilder.setOverrides(metadataOverrides)

        if !isSessionActive {
            logger.debugLog(
                message: "[ ConvivaAnalytics ] no active session; Don\'t propagate content metadata to conviva."
            )
            return
        }

        buildContentMetadata()
        updateSession()
    }

    /**
     Initializes a new conviva tracking session.

     Warning: The integration can only be validated without external session managing. So when using this method we can
     no longer ensure that the session is managed at the correct time. Additional: Since some metadata attributes
     relies on the players source we can't ensure that all metadata attributes are present at session creation.
     Therefore it could be that there will be a 'ContentMetadata created late' issue after conviva validation.

     If no source was loaded (or the itemTitle is missing) and no assetName was set via updateContentMetadata
     this method will throw an error.
     */
    public func initializeSession() throws {
        if isSessionActive {
            logger.debugLog(message: "There is already a session running. Returning …")
            return
        }

        if player.config.sourceItem?.itemTitle == nil, contentMetadataBuilder.assetName == nil {
            throw ConvivaAnalyticsError(
                // swiftlint:disable:next line_length
                "AssetName is missing. Load player source (with itemTitle) first or set assetName via updateContentMetadata"
            )
        }

        internalInitializeSession(fromPlay: true)
    }

    /**
     Ends the current conviva tracking session.
     Results in a no-opt if there is no active session.

     Warning: The integration can only be validated without external session managing.
     So when using this method we can no longer ensure that the session is managed at the correct time.
     */
    public func endSession() {
        if !isSessionActive {
            logger.debugLog(message: "No session running. Returning …")
            return
        }

        internalEndSession()
    }

    /**
     Sends a custom deficiency event during playback to Conviva's Player Insight. If no session is active it will NOT
     create one.

     - Parameters:
        - message: Message which will be send to conviva
        - severity: One of FATAL or WARNING
        - endSession: Boolean flag if session should be closed after reporting the deficiency (Default: true)
     */
    public func reportPlaybackDeficiency(message: String,
                                         severity: ErrorSeverity,
                                         endSession: Bool = true) {
        if !isSessionActive {
            return
        }

        videoAnalytics?.reportPlaybackError(message, errorSeverity: severity)
        if endSession {
            internalEndSession()
        }
    }

    /**
     Puts the session state in a notMonitored state.
     */
    public func pauseTracking() {
        // AdStart is the preferred way to pause tracking according to conviva.
        videoAnalytics?.reportAdBreakStarted(AdPlayer.ADPLAYER_SEPARATE,
                                             adType: AdTechnology.CLIENT_SIDE,
                                             adBreakInfo: [:])
        logger.debugLog(message: "Tracking paused.")
    }

    /**
     Puts the session state from a notMonitored state into the last one tracked.
     */
    public func resumeTracking() {
        // AdEnd is the preferred way to resume tracking according to conviva.
        videoAnalytics?.reportAdBreakEnded()
        logger.debugLog(message: "Tracking resumed.")
    }

    // MARK: - session handling

    private func setupPlayerInfo() {
        videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
                                             value: PlayerState.CONVIVA_STOPPED.rawValue)

        var playerInfo = [String: Any]()
        playerInfo[CIS_SSDK_PLAYER_FRAMEWORK_NAME] = "Bitmovin Player iOS"

        if let bitmovinPlayerVersion = playerHelper.version {
            playerInfo[CIS_SSDK_PLAYER_FRAMEWORK_VERSION] = bitmovinPlayerVersion
        }
        videoAnalytics?.setPlayerInfo(playerInfo)
    }

    private func internalInitializeSession(fromPlay: Bool) {
        buildContentMetadata()

        if fromPlay {
            var settings: [String: Any] = [:]
            if config.debugLoggingEnabled {
                settings[CIS_SSDK_SETTINGS_LOG_LEVEL] = LogLevel.LOGLEVEL_WARNING.rawValue
            }
            if let gatewayUrl = config.gatewayUrl {
                settings[CIS_SSDK_SETTINGS_GATEWAY_URL] = gatewayUrl.absoluteString
            }

            guard let analytics = CISAnalyticsCreator.create(withCustomerKey: customerKey, settings: settings) else {
                logger.debugLog(message: "Unable to create Conviva Analytics")
                return
            }
            self.analytics = analytics
            videoAnalytics = analytics.createVideoAnalytics()
            adAnalytics = analytics.createAdAnalytics()
        }

        if !isSessionActive {
            logger.debugLog(message: "Something went wrong, could not obtain session key")
            return
        }

        setupPlayerInfo()
        videoAnalytics?.reportPlaybackRequested(contentMetadataBuilder.build())
        updateSession()

        logger.debugLog(message: "Session started")
    }

    private func updateSession() {
        // Update metadata
        if !isSessionActive {
            return
        }
        buildDynamicContentMetadata()

        if let videoQuality = player.videoQuality {
            let bitrate = Int(videoQuality.bitrate) / 1000 // in kbps
            videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_BITRATE,
                                                 value: bitrate)
            let videoSize = CGSize(width: Int(videoQuality.width), height: Int(videoQuality.height))
            videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_RESOLUTION,
                                                 value: NSValue(cgSize: videoSize))
        }

        videoAnalytics?.setContentInfo(contentMetadataBuilder.build())
    }

    private func internalEndSession() {
        if !isSessionActive {
            return
        }

        videoAnalytics?.reportPlaybackEnded()
        adAnalytics?.cleanup()
        videoAnalytics?.cleanup()
        analytics?.cleanup()
        adAnalytics = nil
        videoAnalytics = nil
        analytics = nil
        contentMetadataBuilder.reset()
        logger.debugLog(message: "Session ended")
    }

    // MARK: - meta data handling

    private func buildContentMetadata() {
        let sourceItem = player.config.sourceItem
        contentMetadataBuilder.assetName = sourceItem?.itemTitle

        let customInternTags: [String: Any] = [
            "streamType": playerHelper.streamType,
            "integrationVersion": version
        ]

        contentMetadataBuilder.custom = customInternTags
        buildDynamicContentMetadata()
    }

    private func buildDynamicContentMetadata() {
        if !player.isLive, player.duration.isFinite {
            contentMetadataBuilder.duration = Int(player.duration)
        }
        contentMetadataBuilder.streamType = player.isLive ? .CONVIVA_STREAM_LIVE : .CONVIVA_STREAM_VOD
        contentMetadataBuilder.streamUrl = player.config.sourceItem?.url(forType: player.streamType)?.absoluteString
    }

    private func customEvent(event: PlayerEvent, args: [String: String] = [:]) {
        if !isSessionActive {
            return
        }

        sendCustomPlaybackEvent(name: event.name, attributes: args)
    }

    private func onPlaybackStateChanged(playerState: PlayerState) {
        // do not report any playback state changes while player isStalled except buffering
        if isStalled, playerState != .CONVIVA_BUFFERING {
            return
        }

        videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: playerState.rawValue)
        logger.debugLog(message: "Player state changed: \(playerState.rawValue)")
    }
}

// MARK: - PlayerListener

extension ConvivaAnalytics: BitmovinPlayerListenerDelegate {
    func onEvent(_ event: PlayerEvent) {
        logger.debugLog(message: "[ Player Event ] \(event.name)")
    }

    func onSourceUnloaded() {
        internalEndSession()
    }

    func onTimeChanged() {
        updateSession()
    }

    func onError(_ event: ErrorEvent) {
        if !isSessionActive {
            internalInitializeSession(fromPlay: false)
        }

        let message = "\(event.code) \(event.message)"
        reportPlaybackDeficiency(message: message, severity: .ERROR_FATAL)
    }

    func onMuted(_ event: MutedEvent) {
        customEvent(event: event)
    }

    func onUnmuted(_ event: UnmutedEvent) {
        customEvent(event: event)
    }

    // MARK: - Playback state events

    func onPlay() {
        if !isSessionActive {
            internalInitializeSession(fromPlay: true)
        }
    }

    func onPlaying() {
        contentMetadataBuilder.setPlaybackStarted(true)
        updateSession()
        onPlaybackStateChanged(playerState: .CONVIVA_PLAYING)
    }

    func onPaused() {
        onPlaybackStateChanged(playerState: .CONVIVA_PAUSED)
    }

    func onPlaybackFinished() {
        onPlaybackStateChanged(playerState: .CONVIVA_STOPPED)
        internalEndSession()
    }

    func onStallStarted() {
        isStalled = true
        onPlaybackStateChanged(playerState: .CONVIVA_BUFFERING)
    }

    func onStallEnded() {
        isStalled = false
        if player.isPlaying {
            onPlaybackStateChanged(playerState: .CONVIVA_PLAYING)
        } else if player.isPaused {
            onPlaybackStateChanged(playerState: .CONVIVA_PAUSED)
        }
    }

    // MARK: - Seek / Timeshift events

    func onSeek(_ event: SeekEvent) {
        if !isSessionActive {
            // Handle the case that the User seeks on the UI before play was triggered.
            // This also handles startTime feature. The same applies for onTimeShift.
            return
        }

        let time = Int64(event.seekTarget * 1000)
        videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_SEEK_STARTED, value: time)
    }

    func onSeeked() {
        if !isSessionActive {
            // See comment in onSeek
            return
        }

        let time = Int64(player.currentTime * 1000)
        videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_SEEK_ENDED, value: time)
    }

    func onTimeShift(_ event: TimeShiftEvent) {
        if !isSessionActive {
            // See comment in onSeek
            return
        }

        // According to conviva it is valid to pass -1 for seeking in live streams
        videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_SEEK_STARTED, value: -1)
    }

    func onTimeShifted() {
        if !isSessionActive {
            // See comment in onSeek
            return
        }

        videoAnalytics?.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_SEEK_ENDED, value: -1)
    }

    #if !os(tvOS)

    // MARK: - Ad events

    func onAdStarted(_ event: AdStartedEvent) {
        let adPosition: AdPosition = AdEventUtil.parseAdPosition(event: event, contentDuration: player.duration)

        var adInfo = [String: Any]()
        adInfo["c3.ad.position"] = adPosition

        adAnalytics?.reportAdStarted(adInfo)
    }

    func onAdFinished() {
        adAnalytics?.reportAdEnded()
    }

    func onAdSkipped(_ event: AdSkippedEvent) {
        customEvent(event: event)
        adAnalytics?.reportAdSkipped()
    }

    func onAdError(_ event: AdErrorEvent) {
        customEvent(event: event)
        adAnalytics?.reportAdError(event.message, severity: .ERROR_WARNING)
    }

    func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        videoAnalytics?.reportAdBreakStarted(AdPlayer.ADPLAYER_SEPARATE,
                                             adType: AdTechnology.CLIENT_SIDE,
                                             adBreakInfo: [:])
    }

    func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        videoAnalytics?.reportAdBreakEnded()
    }

    #endif

    func onDestroy() {
        internalEndSession()
    }
}

// MARK: - UserInterfaceListener

extension ConvivaAnalytics: UserInterfaceListener {
    public func onFullscreenEnter(_ event: FullscreenEnterEvent) {
        customEvent(event: event)
    }

    public func onFullscreenExit(_ event: FullscreenExitEvent) {
        customEvent(event: event)
    }
}
