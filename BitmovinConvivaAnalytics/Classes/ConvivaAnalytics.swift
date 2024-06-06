// swiftlint:disable file_length
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

private let notAvailable = "NA"

// swiftlint:disable:next type_body_length
public final class ConvivaAnalytics: NSObject {
    // MARK: - Bitmovin Player attributes
    let player: Player

    // MARK: - Conviva related attributes
    let customerKey: String
    let config: ConvivaConfiguration
    let analytics: CISAnalytics
    let videoAnalytics: CISVideoAnalytics
    let adAnalytics: CISAdAnalytics
    let contentMetadataBuilder: ContentMetadataBuilder
    var isSessionActive = false
    var isBumper = false

    var listener: BitmovinPlayerListener?

    // MARK: - Helper
    let logger: Logger
    let playerHelper: BitmovinPlayerHelper
    // Workaround for player issue when onPlay is sent while player is stalled
    var isStalled = false
    var playbackStarted = false

    // MARK: - Public Attributes
    /**
     Set the PlayerView to enable view triggered events like fullscreen state changes
     */
    public var playerView: PlayerView? {
        didSet {
            oldValue?.remove(listener: self)
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
     Initialize a new Bitmovin Conviva Analytics object to track metrics from Bitmovin Player

     - Parameters:
        - player: Bitmovin Player instance to track
        - customerKey: Conviva customerKey
        - config: ConvivaConfiguration object (see ConvivaConfiguration for more information)
     */
    public init?(
        player: Player,
        customerKey: String,
        config: ConvivaConfiguration = ConvivaConfiguration()
    ) throws {
        self.player = player
        self.playerHelper = BitmovinPlayerHelper(player: player)
        self.customerKey = customerKey
        self.config = config

        if let gatewayUrl = config.gatewayUrl {
            var settings = [String: Any]()
            settings[CIS_SSDK_SETTINGS_GATEWAY_URL] = gatewayUrl.absoluteString
            settings[CIS_SSDK_SETTINGS_LOG_LEVEL] = config.convivaLogLevel.rawValue
            analytics = CISAnalyticsCreator.create(withCustomerKey: customerKey, settings: settings)
        } else {
            analytics = CISAnalyticsCreator.create(withCustomerKey: customerKey)
        }
        logger = Logger(loggingEnabled: config.debugLoggingEnabled)
        self.contentMetadataBuilder = ContentMetadataBuilder(logger: logger)

        videoAnalytics = analytics.createVideoAnalytics()
        adAnalytics = analytics.createAdAnalytics()
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
        analytics.reportAppEvent(name, details: attributes)
    }

    /**
     Sends a custom playback-level event to Conviva's Player Insight. A playback-level event can only be sent
     during an active video session.

     - Parameters:
        - name: The name of the event
        - attributes: A dictionary with custom event attributes
     */
    public func sendCustomPlaybackEvent(name: String, attributes: [String: String] = [:]) {
        analytics.reportAppEvent(name, details: attributes)
    }

    // MARK: - external session handling

    /**
     Will update the contentMetadata that are tracked with conviva.

     If there is an active session only permitted values will be updated and propagated immediately.
     If there is no active session the values will be set on session creation.

     Attributes set via this method will override automatically tracked attributes.
     - Parameters:
        - metadataOverrides: Metadata attributes which will be used to track for Conviva.
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
     rely on the player's source we can't ensure that all metadata attributes are present at session creation.
     Therefore it is possible that we receive a 'ContentMetadata created late' issue after conviva validation.

     If no source was loaded (or the itemTitle is missing) and no assetName was set via updateContentMetadata
     this method will throw an error.
     */
    public func initializeSession() throws {
        if isSessionActive {
            logger.debugLog(message: "There is already a session running. Returning …")
            return
        }

        if player.source?.sourceConfig.title == nil && contentMetadataBuilder.assetName == nil {
            throw ConvivaAnalyticsError(
                "AssetName is missing. Load player source (with title) first or set assetName via updateContentMetadata"
            )
        }

        internalInitializeSession()
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

    public func release() {
        videoAnalytics.cleanup()
        adAnalytics.cleanup()
        analytics.cleanup()
    }
    /**
     Sends a custom deficiency event during playback to Conviva's Player Insight. If no session is active it will NOT
     create one.

     - Parameters:
        - message: Message which will be send to conviva
        - severity: One of FATAL or WARNING
        - endSession: Boolean flag if session should be closed after reporting the deficiency (Default: true)
     */
    public func reportPlaybackDeficiency(
        message: String,
        severity: ErrorSeverity,
        endSession: Bool = true
    ) {
        if !isSessionActive {
            return
        }

        videoAnalytics.reportPlaybackError(message, errorSeverity: severity)
        if endSession {
            internalEndSession()
        }
    }

    /**
     Puts the session in a notMonitored state.
     */
    public func pauseTracking(isBumper: Bool) {
        self.isBumper = isBumper
        let event: String = self.isBumper ?
        CISConstants.getEventsStringValue(Events.BUMPER_VIDEO_STARTED) :
        CISConstants.getEventsStringValue(Events.USER_WAIT_STARTED)
        videoAnalytics.reportPlaybackEvent(event)
        logger.debugLog(message: "Tracking paused.")
    }

    /**
     Changes the session state from notMonitored state into the previous state.
     */
    public func resumeTracking() {
        let event: String = self.isBumper ?
        CISConstants.getEventsStringValue(Events.BUMPER_VIDEO_ENDED) :
        CISConstants.getEventsStringValue(Events.USER_WAIT_ENDED)
        videoAnalytics.reportPlaybackEvent(event)
        self.isBumper = false
        logger.debugLog(message: "Tracking resumed.")
    }

    // MARK: - session handling
    private func setupPlayerStateManager() {
        videoAnalytics.reportPlaybackMetric(
            CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
            value: PlayerState.CONVIVA_STOPPED.rawValue
        )
        var playerInfo = [String: Any]()
        playerInfo[CIS_SSDK_PLAYER_FRAMEWORK_NAME] = "Bitmovin Player iOS"
        playerInfo[CIS_SSDK_PLAYER_FRAMEWORK_VERSION] = playerHelper.version
        videoAnalytics.setPlayerInfo(playerInfo)
        adAnalytics.setAdPlayerInfo(playerInfo)
    }

    private func internalInitializeSession() {
        buildContentMetadata()

        if isSessionActive {
            logger.debugLog(message: "Returning, session already up")
            return
        }

        setupPlayerStateManager()
        updateSession()

        videoAnalytics.reportPlaybackRequested(contentMetadataBuilder.build())
        logger.debugLog(message: "Creating session with metadata: \(contentMetadataBuilder)")
        logger.debugLog(message: "Session started")
        isSessionActive = true
    }

    private func updateSession() {
        // Update metadata
        if !isSessionActive {
            return
        }
        buildDynamicContentMetadata()

        if let videoQuality = player.videoQuality {
            let bitrate = Int(videoQuality.bitrate) / 1_000 // in kbps
            let value = NSValue(
                cgSize: CGSize(
                    width: CGFloat(videoQuality.width),
                    height: CGFloat(videoQuality.height)
                )
            )
            videoAnalytics.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_BITRATE, value: bitrate)
            videoAnalytics.reportPlaybackMetric(
                CIS_SSDK_PLAYBACK_METRIC_RESOLUTION,
                value: value.cgSizeValue
            )
            videoAnalytics.reportPlaybackMetric(
                CIS_SSDK_PLAYBACK_METRIC_RENDERED_FRAMERATE,
                value: player.currentVideoFrameRate
            )
        }

        videoAnalytics.setContentInfo(contentMetadataBuilder.build())
        logger.debugLog(message: "Updating session with metadata: \(contentMetadataBuilder)")
    }

    private func internalEndSession() {
        contentMetadataBuilder.reset()
        if !isSessionActive {
            return
        }

        videoAnalytics.reportPlaybackEnded()

        isSessionActive = false
        logger.debugLog(message: "Ending session")

        playbackStarted = false
        logger.debugLog(message: "Session ended")
    }

    // MARK: - meta data handling
    private func buildContentMetadata() {
        let sourceConfig = player.source?.sourceConfig
        contentMetadataBuilder.assetName = sourceConfig?.title

        let customInternTags: [String: Any] = [
            "streamType": playerHelper.streamType,
            "integrationVersion": version
        ]

        contentMetadataBuilder.custom = customInternTags
        buildDynamicContentMetadata()
    }

    private func buildDynamicContentMetadata() {
        if !player.isLive && player.duration.isFinite {
            contentMetadataBuilder.duration = Int(player.duration)
        }
        contentMetadataBuilder.streamType = player.isLive ? .CONVIVA_STREAM_LIVE : .CONVIVA_STREAM_VOD
        contentMetadataBuilder.streamUrl = player.source?.sourceConfig.url.absoluteString
    }

    private func customEvent(event: PlayerViewEvent, args: [String: String] = [:]) {
        if !isSessionActive {
            return
        }

        sendCustomPlaybackEvent(name: event.name, attributes: args)
    }

    private func customEvent(event: PlayerEvent, args: [String: String] = [:]) {
        if !isSessionActive {
            return
        }

        sendCustomPlaybackEvent(name: event.name, attributes: args)
    }

    private func onPlaybackStateChanged(playerState: ConvivaSDK.PlayerState) {
        // do not report any playback state changes while player isStalled except buffering
        if isStalled && playerState != .CONVIVA_BUFFERING {
            return
        }
        // do not report any stalling when isStalled false (StallEnded triggered immediatelly after StallStarted)
        else if !isStalled && playerState == .CONVIVA_BUFFERING {
            self.logger.debugLog(
                message: "[ ConvivaAnalytics ] false stalling, not registering to Conviva"
            )
            return
        }

        videoAnalytics.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: playerState.rawValue)
        logger.debugLog(message: "Player state changed: \(playerState.rawValue)")
    }

    private func reportPlayHeadTime() {
        guard isSessionActive else { return }

        videoAnalytics.reportPlaybackMetric(
            CIS_SSDK_PLAYBACK_METRIC_PLAY_HEAD_TIME,
            value: Int64(player.currentTime(.relativeTime) * 1_000)
        )
    }

    private func buildAdInfo(adStartedEvent: AdStartedEvent) -> [String: Any] {
        var adInfo = [String: Any]()

        adInfo["c3.ad.id"] = notAvailable
        adInfo["c3.ad.system"] = notAvailable
        adInfo["c3.ad.mediaFileApiFramework"] = notAvailable
        adInfo["c3.ad.firstAdSystem"] = notAvailable
        adInfo["c3.ad.firstAdId"] = notAvailable
        adInfo["c3.ad.firstCreativeId"] = notAvailable

        adInfo["c3.ad.technology"] = "Client Side"
        if adStartedEvent.clientType == AdSourceType.ima {
            adInfo[CIS_SSDK_PLAYER_FRAMEWORK_NAME] = "Google IMA SDK"
            adInfo[CIS_SSDK_PLAYER_FRAMEWORK_VERSION] = contentMetadataBuilder
                .metadataOverrides
                .imaSdkVerison ?? notAvailable
        } else {
            adInfo[CIS_SSDK_PLAYER_FRAMEWORK_NAME] = "Bitmovin"
            adInfo[CIS_SSDK_PLAYER_FRAMEWORK_VERSION] = playerHelper.version
        }

        adInfo["c3.ad.position"] = AdEventUtil.parseAdPosition(
            event: adStartedEvent,
            contentDuration: player.duration
        ).rawValue
        adInfo[CIS_SSDK_METADATA_DURATION] = adStartedEvent.duration
        adInfo[CIS_SSDK_METADATA_IS_LIVE] = videoAnalytics.getMetadataInfo()[CIS_SSDK_METADATA_IS_LIVE]

        let ad = adStartedEvent.ad
        if ad.mediaFileUrl != nil {
            adInfo[CIS_SSDK_METADATA_STREAM_URL] = ad.mediaFileUrl
        }
        if ad.identifier != nil {
            adInfo["c3.ad.id"] = ad.identifier
        }
        if let vastAdData = ad.data as? VastAdData {
            setVastAdMetadata(adInfo: &adInfo, vastAdData: vastAdData)
        }
        return adInfo
    }

    private func setVastAdMetadata(adInfo: inout [String: Any], vastAdData: VastAdData) {
        adInfo["c3.ad.description"] = vastAdData.description

        if let adTitle = vastAdData.adTitle {
            adInfo[CIS_SSDK_METADATA_ASSET_NAME] = adTitle
        }
        if let adId = vastAdData.creative?.adId {
            adInfo["c3.ad.creativeId"] = adId
        }
        if let adSystem = vastAdData.adSystem {
            adInfo["c3.ad.system"] = adSystem
        }
        if !vastAdData.wrapperAdIds.isEmpty {
            adInfo["c3.ad.firstAdId"] = vastAdData.wrapperAdIds.last
        }
    }
}

// MARK: - PlayerListener
extension ConvivaAnalytics: BitmovinPlayerListenerDelegate {
    func onEvent(_ event: Event) {
        logger.debugLog(message: "[ Player Event ] \(event.name)")
    }

    func onSourceUnloaded() {
        internalEndSession()
    }

    func onTimeChanged() {
        reportPlayHeadTime()
        updateSession()
    }

    func onPlayerError(_ event: PlayerErrorEvent) {
        trackError(errorCode: event.code.rawValue, errorMessage: event.message)
    }

    func onSourceError(_ event: SourceErrorEvent) {
        trackError(errorCode: event.code.rawValue, errorMessage: event.message)
    }

    func trackError(errorCode: Int, errorMessage: String) {
         if !isSessionActive {
             internalInitializeSession()
         }

        let message = "\(errorCode) \(errorMessage)"
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
            internalInitializeSession()
        }
    }

    func onPlaying() {
        playbackStarted = true
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            self.logger.debugLog(
                message: "[ ConvivaAnalytics ] calling StallStarted after 0.10 seconds"
            )
            self.onPlaybackStateChanged(playerState: .CONVIVA_BUFFERING)
        }
    }

    func onStallEnded() {
        isStalled = false

        guard playbackStarted else { return }
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

        videoAnalytics.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_SEEK_STARTED, value: Int64(event.to.time * 1_000))
    }

    func onSeeked() {
        if !isSessionActive {
            // See comment in onSeek
            return
        }

        videoAnalytics.reportPlaybackMetric(
            CIS_SSDK_PLAYBACK_METRIC_SEEK_ENDED,
            value: Int64(player.currentTime * 1_000)
        )
    }

    func onTimeShift(_ event: TimeShiftEvent) {
        if !isSessionActive {
            // See comment in onSeek
            return
        }

        // According to conviva it is valid to pass -1 for seeking in live streams
        videoAnalytics.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_SEEK_STARTED, value: Int64(-1))
    }

    func onTimeShifted() {
        if !isSessionActive {
            // See comment in onSeek
            return
        }
        videoAnalytics.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_SEEK_ENDED, value: Int64(-1))
    }

    // MARK: - Ad events
    func onAdStarted(_ event: AdStartedEvent) {
        let adInfo = buildAdInfo(adStartedEvent: event)
        adAnalytics.reportAdLoaded(adInfo)
        adAnalytics.reportAdStarted(adInfo)
        adAnalytics.reportAdMetric(
            CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
            value: PlayerState.CONVIVA_PLAYING.rawValue
        )
    }

    func onAdFinished() {
        adAnalytics.reportAdEnded()
    }

    func onAdSkipped(_ event: AdSkippedEvent) {
        adAnalytics.reportAdSkipped()
        customEvent(event: event)
    }

    func onAdError(_ event: AdErrorEvent) {
        adAnalytics.reportAdFailed(event.message, adInfo: nil)
        customEvent(event: event)
    }

    func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        videoAnalytics.reportAdBreakStarted(
            AdPlayer.ADPLAYER_CONTENT,
            adType: AdTechnology.CLIENT_SIDE,
            adBreakInfo: [AnyHashable: Any]()
        )
        customEvent(event: event)
    }

    func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        videoAnalytics.reportAdBreakEnded()
        customEvent(event: event)
    }

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
