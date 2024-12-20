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

public final class ConvivaAnalytics: NSObject {
    // MARK: - Bitmovin Player attributes
    private var player: Player?

    // MARK: - Conviva related attributes
    private let customerKey: String
    private let config: ConvivaConfiguration
    private let analytics: CISAnalytics
    private let videoAnalytics: CISVideoAnalytics
    private let adAnalytics: CISAdAnalytics
    private let contentMetadataBuilder: ContentMetadataBuilder
    private var isSessionActive = false
    private var isBumper = false

    private var listener: BitmovinPlayerListener?

    // MARK: - Helper
    private let logger: Logger
    private var playerHelper: BitmovinPlayerHelper?
    // Workaround for player issue when onPlay is sent while player is stalled
    private var isStalled = false
    private var playbackStarted = false
    private var isSsaiAdBreakActive = false
    private var playbackFinishedDispatchWorkItem: DispatchWorkItem?

    // MARK: - Public Attributes
    /**
     Set the PlayerView to enable view triggered events like fullscreen state changes
     */
    public var playerView: PlayerView? {
        didSet {
            Task { @MainActor in
                oldValue?.remove(listener: self)
                playerView?.add(listener: self)
            }
        }
    }

    /// Namespace for reporting server-side ad breaks and ads.
    public let ssai = SsaiApi()

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
    /// Initialize a new Bitmovin Conviva Analytics object to track metrics from Bitmovin Player
    ///  
    /// - Parameters:
    ///    - player: Bitmovin Player instance to track
    ///    - customerKey: Conviva customerKey
    ///    - config: ConvivaConfiguration object (see ConvivaConfiguration for more information)
    public convenience init(
        player: Player,
        customerKey: String,
        config: ConvivaConfiguration = ConvivaConfiguration()
    ) throws {
        try self.init(
            player,
            customerKey: customerKey,
            config: config
        )
    }

    /// Initialize a new Bitmovin Conviva Analytics object to track metrics from Bitmovin Player.
    ///
    /// Use this initializer if you plan to manually start VST tracking **before** a `Player` instance is created.
    /// Once the `Player` instance is created, attach it using the `attach(player:)` method.
    ///
    /// - Parameters:
    ///   - customerKey: Conviva customerKey
    ///   - config: ConvivaConfiguration object (see ConvivaConfiguration for more information)
    public convenience init(
        customerKey: String,
        config: ConvivaConfiguration = ConvivaConfiguration()
    ) throws {
        try self.init(
            nil,
            customerKey: customerKey,
            config: config
        )
    }

    private init(
        _ player: Player?,
        customerKey: String,
        config: ConvivaConfiguration
    ) throws {
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
        adAnalytics = analytics.createAdAnalytics(withVideoAnalytics: videoAnalytics)
        super.init()

        if let player {
            attach(player: player)
        }

        ssai.delegate = self
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
                message: "No active session; Don\'t propagate content metadata to conviva."
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

        if player?.source?.sourceConfig.title == nil, contentMetadataBuilder.assetName == nil {
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
        if isSsaiAdBreakActive {
            adAnalytics.reportAdError(message, severity: severity)
        }
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

    /// Attaches a `Player` instance to the Conviva Analytics object.
    /// This method should be called as soon as the `Player` instance is initialized to not miss any tracking.
    ///
    /// Has no effect if there is already a `Player` instance set. Use the `ConvivaAnalytics.init` without `player`
    /// if you plan to attach a `Player` instance later in the life-cycle.
    public func attach(player: Player) {
        if self.player != nil {
            logger.debugLog(
                message: "[ Warning ] There is already a Player instance attached! Ignoring new Player instance."
            )
            return
        }

        if player.source != nil {
            logger.debugLog(
                message: """
                         [ Warning ] There is already a Source loaded into the Player instance! \
                         This method should be called before loading a Source.
                         """
            )
        }

        self.player = player
        updateSession()

        playerHelper = BitmovinPlayerHelper(player: player)
        listener = BitmovinPlayerListener(player: player)
        listener?.delegate = self
    }
}

private extension ConvivaAnalytics {
    private var isAd: Bool {
        guard let player else { return false }

        return player.isAd || isSsaiAdBreakActive
    }

    private var currentPlayerState: ConvivaSDK.PlayerState {
        guard let player else {
            return .CONVIVA_STOPPED
        }

        if player.isPaused {
            return .CONVIVA_PAUSED
        }
        if isStalled {
            return .CONVIVA_BUFFERING
        }

        return .CONVIVA_PLAYING
    }

    // MARK: - session handling
    private func setupPlayerStateManager() {
        videoAnalytics.reportPlaybackMetric(
            CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
            value: PlayerState.CONVIVA_STOPPED.rawValue
        )
        var playerInfo = [String: Any]()
        playerInfo[CIS_SSDK_PLAYER_FRAMEWORK_NAME] = "Bitmovin Player iOS"
        playerInfo[CIS_SSDK_PLAYER_FRAMEWORK_VERSION] = BitmovinPlayerHelper.version
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

        videoAnalytics.reportPlaybackRequested(contentMetadataBuilder.build())
        logger.debugLog(message: "Creating session with metadata: \(contentMetadataBuilder)")
        logger.debugLog(message: "Session started")
        isSessionActive = true

        updateSession()
    }

    private func updateSession() {
        // Update metadata
        if !isSessionActive {
            return
        }
        buildDynamicContentMetadata()

        if let player, let videoQuality = player.videoQuality {
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

            if isSsaiAdBreakActive {
                adAnalytics.reportAdMetric(CIS_SSDK_PLAYBACK_METRIC_BITRATE, value: bitrate)
                adAnalytics.reportAdMetric(
                    CIS_SSDK_PLAYBACK_METRIC_RESOLUTION,
                    value: value.cgSizeValue
                )
                adAnalytics.reportAdMetric(
                    CIS_SSDK_PLAYBACK_METRIC_RENDERED_FRAMERATE,
                    value: player.currentVideoFrameRate
                )
            }
        }

        videoAnalytics.setContentInfo(contentMetadataBuilder.build())
        logger.debugLog(message: "Updating session with metadata: \(contentMetadataBuilder)")
    }

    private func internalEndSession() {
        contentMetadataBuilder.reset()
        if !isSessionActive {
            return
        }

        playbackFinishedDispatchWorkItem?.cancel()
        playbackFinishedDispatchWorkItem = nil

        if isSsaiAdBreakActive {
            adAnalytics.reportAdEnded()
            videoAnalytics.reportAdBreakEnded()
        }
        videoAnalytics.reportPlaybackEnded()

        isSessionActive = false
        logger.debugLog(message: "Ending session")
        isStalled = false
        playbackStarted = false
        isSsaiAdBreakActive = false
        logger.debugLog(message: "Session ended")
    }

    // MARK: - meta data handling
    private func buildContentMetadata() {
        let sourceConfig = player?.source?.sourceConfig
        contentMetadataBuilder.assetName = sourceConfig?.title

        var customInternTags: [String: Any] = [
            "integrationVersion": version
        ]

        if let playerHelper {
            customInternTags["streamType"] = playerHelper.streamType
        }

        contentMetadataBuilder.custom = customInternTags
        buildDynamicContentMetadata()
    }

    private func buildSsaiAdMetadata() -> [String: Any] {
        let includedTags: Set<String> = [
            CIS_SSDK_METADATA_ASSET_NAME,
            CIS_SSDK_METADATA_STREAM_URL,
            CIS_SSDK_METADATA_IS_LIVE,
            CIS_SSDK_METADATA_DEFAULT_RESOURCE,
            CIS_SSDK_METADATA_ENCODED_FRAMERATE,
            "streamType",
            "integrationVersion",
        ]
        return contentMetadataBuilder.build()
            .filter { key, _ in
                includedTags.contains(key)
            }
    }

    private func buildDynamicContentMetadata() {
        guard let player, let source = player.source else { return }

        contentMetadataBuilder.duration = player.isLive ? -1 : Int(source.duration)
        contentMetadataBuilder.streamType = player.isLive ? .CONVIVA_STREAM_LIVE : .CONVIVA_STREAM_VOD
        contentMetadataBuilder.streamUrl = source.sourceConfig.url.absoluteString
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
        if isStalled, playerState != .CONVIVA_BUFFERING {
            return
        }
        // do not report any stalling when isStalled false (StallEnded triggered immediatelly after StallStarted)
        else if !isStalled, playerState == .CONVIVA_BUFFERING {
            self.logger.debugLog(
                message: "False stalling, not registering to Conviva"
            )
            return
        }

        videoAnalytics.reportPlaybackMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: playerState.rawValue)
        if isAd {
            adAnalytics.reportAdMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: playerState.rawValue)
        }
        logger.debugLog(message: "Player state changed: \(playerState.rawValue)")
    }

    private func reportPlayHeadTime() {
        guard let player, isSessionActive else { return }

        let reportPlayHeadTime: (_ analytics: CISStreamAnalyticsProtocol) -> Void = { analytics in
            let currentTime = Int64(player.currentTime(.relativeTime) * 1_000)
            analytics.reportPlaybackMetric(
                CIS_SSDK_PLAYBACK_METRIC_PLAY_HEAD_TIME,
                value: currentTime
            )
        }

        reportPlayHeadTime(isAd ? adAnalytics : videoAnalytics)
    }

    private func buildAdInfo(adStartedEvent: AdStartedEvent, player: Player) -> [String: Any] {
        var adInfo = [String: Any]()

        adInfo["c3.ad.id"] = notAvailable
        adInfo["c3.ad.system"] = notAvailable
        adInfo["c3.ad.mediaFileApiFramework"] = notAvailable
        adInfo["c3.ad.firstAdSystem"] = notAvailable
        adInfo["c3.ad.firstAdId"] = notAvailable
        adInfo["c3.ad.firstCreativeId"] = notAvailable

        adInfo["c3.ad.technology"] = "Client Side"
        if adStartedEvent.clientType == .ima {
            adInfo[CIS_SSDK_PLAYER_FRAMEWORK_NAME] = "Google IMA SDK"
            adInfo[CIS_SSDK_PLAYER_FRAMEWORK_VERSION] = contentMetadataBuilder
                .metadataOverrides
                .imaSdkVersion ?? notAvailable
        } else {
            adInfo[CIS_SSDK_PLAYER_FRAMEWORK_NAME] = "Bitmovin"
            adInfo[CIS_SSDK_PLAYER_FRAMEWORK_VERSION] = BitmovinPlayerHelper.version
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
        adInfo["c3.ad.description"] = vastAdData.adDescription

        if let adTitle = vastAdData.adTitle {
            adInfo[CIS_SSDK_METADATA_ASSET_NAME] = adTitle
        }
        if let adId = vastAdData.creative?.adId {
            adInfo["c3.ad.creativeId"] = adId
        }
        if let adSystem = vastAdData.adSystem {
            adInfo["c3.ad.system"] = adSystem
        }
        if let firstAdId = vastAdData.wrapperAdIds.last {
            adInfo["c3.ad.firstAdId"] = firstAdId
        }
        if let firstCreativeId = vastAdData.wrapperCreativeIds.last {
            adInfo["c3.ad.firstCreativeId"] = firstCreativeId
        }
        if let firstAdSystem = vastAdData.wrapperAdSystems.last {
            adInfo["c3.ad.firstAdSystem"] = firstAdSystem
        }
    }

    private func maybeCancelEndSessionBeforePostRoll() {
        playbackFinishedDispatchWorkItem?.cancel()
    }

    private func maybeEndSessionAfterPostRoll() {
        guard playbackFinishedDispatchWorkItem != nil else { return }
        playbackFinishedDispatchWorkItem = nil
        internalEndSession()
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

    func onSourceLoaded() {
        updateSession()
    }

    func onTimeChanged(player: Player) {
        reportPlayHeadTime()

        guard !player.isAd else {
            return
        }

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
        let playbackFinishedDispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let self,
                  let currentWorkItem = self.playbackFinishedDispatchWorkItem,
                  !currentWorkItem.isCancelled else { return }
            self.internalEndSession()
        }
        self.playbackFinishedDispatchWorkItem = playbackFinishedDispatchWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: playbackFinishedDispatchWorkItem)
    }

    func onStallStarted() {
        isStalled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
            guard let self else { return }
            self.logger.debugLog(
                message: "Calling StallStarted after 0.10 seconds"
            )
            self.onPlaybackStateChanged(playerState: .CONVIVA_BUFFERING)
        }
    }

    func onStallEnded(player: Player) {
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

    func onSeeked(player: Player) {
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
    func onAdStarted(_ event: AdStartedEvent, player: Player) {
        let adInfo = buildAdInfo(adStartedEvent: event, player: player)
        adAnalytics.reportAdLoaded(adInfo)
        adAnalytics.reportAdStarted(adInfo)
        adAnalytics.reportAdMetric(
            CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE,
            value: PlayerState.CONVIVA_PLAYING.rawValue
        )
        let ad = event.ad
        if ad.width > 0, ad.height > 0 {
            adAnalytics.reportAdMetric(
                CIS_SSDK_PLAYBACK_METRIC_RESOLUTION,
                value: NSValue(cgSize: CGSize(width: ad.width, height: ad.height))
            )
        }
        if let bitrate = ad.data?.bitrate {
            adAnalytics.reportAdMetric(CIS_SSDK_PLAYBACK_METRIC_BITRATE, value: bitrate)
        }
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
        maybeCancelEndSessionBeforePostRoll()
        videoAnalytics.reportAdBreakStarted(
            AdPlayer.ADPLAYER_CONTENT,
            adType: AdTechnology.CLIENT_SIDE,
            adBreakInfo: [:]
        )
        customEvent(event: event)
    }

    func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        videoAnalytics.reportAdBreakEnded()
        customEvent(event: event)
        maybeEndSessionAfterPostRoll()
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

extension ConvivaAnalytics: SsaiApiDelegate {
    // swiftlint:disable:next identifier_name
    var ssaiApi_isAdBreakActive: Bool {
        isSsaiAdBreakActive
    }

    func ssaiApi_reportAdBreakStarted() {
        ssaiApi_reportAdBreakStarted(adBreakInfo: [:])
    }

    func ssaiApi_reportAdBreakStarted(adBreakInfo: [String: Any]?) {
        guard !isSsaiAdBreakActive else { return }
        isSsaiAdBreakActive = true

        maybeCancelEndSessionBeforePostRoll()

        videoAnalytics.reportAdBreakStarted(
            .ADPLAYER_CONTENT,
            adType: .SERVER_SIDE,
            adBreakInfo: adBreakInfo ?? [:]
        )
    }

    func ssaiApi_reportAdBreakFinished() {
        guard isSsaiAdBreakActive else { return }

        isSsaiAdBreakActive = false
        videoAnalytics.reportAdBreakEnded()

        maybeEndSessionAfterPostRoll()
    }

    func ssaiApi_reportAdStarted(adInfo: SsaiAdInfo) {
        guard isSsaiAdBreakActive else { return }

        adAnalytics.reportAdStarted(adInfo.convivaAdInfo(baseSsaiAdMetadata: buildSsaiAdMetadata()))
        adAnalytics.reportAdMetric(CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE, value: currentPlayerState.rawValue)
        updateSession()
    }

    func ssaiApi_reportAdFinished() {
        guard isSsaiAdBreakActive else { return }

        adAnalytics.reportAdEnded()
    }

    func ssaiApi_reportAdSkipped() {
        guard isSsaiAdBreakActive else { return }

        adAnalytics.reportAdSkipped()
    }

    func ssaiApi_update(adInfo: SsaiAdInfo) {
        guard isSsaiAdBreakActive else { return }

        adAnalytics.setAdInfo(adInfo.convivaAdInfo(baseSsaiAdMetadata: buildSsaiAdMetadata()))
    }
}

private extension SsaiAdInfo {
    func convivaAdInfo(baseSsaiAdMetadata: [String: Any]) -> [String: Any] {
        var adInfo = [String: Any]()
        adInfo["c3.ad.id"] = notAvailable
        adInfo["c3.ad.system"] = notAvailable
        adInfo["c3.ad.mediaFileApiFramework"] = notAvailable
        adInfo["c3.ad.firstAdSystem"] = notAvailable
        adInfo["c3.ad.firstAdId"] = notAvailable
        adInfo["c3.ad.firstCreativeId"] = notAvailable
        adInfo["c3.ad.technology"] = "Server Side"

        adInfo["c3.ad.isSlate"] = isSlate ? "true" : "false"

        if let title {
            adInfo[CIS_SSDK_METADATA_ASSET_NAME] = title
        }
        if let duration {
            adInfo[CIS_SSDK_METADATA_DURATION] = duration
        }
        if let id {
            adInfo["c3.ad.id"] = id
        }
        if let adSystem {
            adInfo["c3.ad.system"] = adSystem
        }
        if let position {
            adInfo["c3.ad.position"] = position.convivaAdPosition.rawValue
        }
        if let adStitcher {
            adInfo["c3.ad.stitcher"] = adStitcher
        }

        additionalMetadata?.forEach { key, value in
            adInfo[key] = value
        }

        let mergedAdInfo = baseSsaiAdMetadata.merging(adInfo) { $1 }
        return mergedAdInfo
    }
}

private extension SsaiAdPosition {
    var convivaAdPosition: ConvivaSDK.AdPosition {
        switch self {
        case .preroll:
            return .ADPOSITION_PREROLL
        case .midroll:
            return .ADPOSITION_MIDROLL
        case .postroll:
            return .ADPOSITION_POSTROLL
        }
    }
}
