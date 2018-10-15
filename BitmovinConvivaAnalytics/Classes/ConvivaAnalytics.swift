//
//  ConvivaAnalytics.swift
//  BitmovinConvivaAnalytics
//
//  Created by David Steinacher on 02.10.18.
//

import Foundation
import BitmovinPlayer
import ConvivaSDK

public final class ConvivaAnalytics: NSObject {
    // MARK: - Bitmovin Player attributes
    let player: BitmovinPlayer

    // MARK: - Conviva related attributes
    let customerKey: String
    let config: ConvivaConfiguration
    var client: CISClientProtocol
    var playerStateManager: CISPlayerStateManagerProtocol
    var sessionKey: Int32 = NO_SESSION_KEY
    var contentMetadata: CISContentMetadata = CISContentMetadata()
    var isValidSession: Bool {
        return sessionKey != NO_SESSION_KEY
    }

    // The BitmovinPlayerListener is used to prevent listener methods to be public and therefore
    // preventing calling from outside.
    var listener: BitmovinPlayerListener?

    // MARK: - Helper
    let logger: Logger
    let playerHelper: BitmovinPlayerHelper

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
        self.playerHelper = BitmovinPlayerHelper(player: player)
        self.customerKey = customerKey
        self.config = config

        // TODO: check if we can check if the player is already setup !!!!

        let systemInterFactory: CISSystemInterfaceProtocol = IOSSystemInterfaceFactory.initializeWithSystemInterface()
        let setting: CISSystemSettings = CISSystemSettings()

        logger = Logger(loggingEnabled: config.debugLoggingEnabled)
        if config.debugLoggingEnabled {
            setting.logLevel = LogLevel.LOGLEVEL_DEBUG
        }

        let systemFactory = CISSystemFactoryCreator.create(withCISSystemInterface: systemInterFactory, setting: setting)
        let clientSetting: CISClientSettingProtocol = try CISClientSettingCreator.create(withCustomerKey: customerKey)
        if let gatewayUrl = config.gatewayUrl {
            clientSetting.setGatewayUrl(gatewayUrl.absoluteString)
        }

        self.client = try CISClientCreator.create(withClientSettings: clientSetting, factory: systemFactory)
        self.playerStateManager = client.getPlayerStateManager()

        super.init()

        setupPlayerStateManager()

        listener = BitmovinPlayerListener(player: player)
        listener?.delegate = self
    }

    deinit {
        endSession()
        client.releasePlayerStateManager(playerStateManager)
    }

    // MARK: - session handling
    private func setupPlayerStateManager() {
        self.playerStateManager.setPlayerType!("Bitmovin Player iOS")

        if let bitmovinPlayerVersion = playerHelper.version {
            self.playerStateManager.setPlayerVersion!(bitmovinPlayerVersion)
        }
    }

    private func initSession() {
        buildContentMetadata()
        sessionKey = client.createSession(with: contentMetadata)

        if !isValidSession {
            logger.debugLog(message: "Something went wrong, could not obtain session key")
        }

        playerStateManager.setPlayerState!(PlayerState.CONVIVA_STOPPED)
        client.attachPlayer(sessionKey, playerStateManager: playerStateManager)
        logger.debugLog(message: "Session started")
    }

    private func updateSession() {
        // Update metadata
        if !isValidSession {
            return
        }
        if !player.isLive {
            contentMetadata.duration = Int(player.duration)
        }
        contentMetadata.streamType = player.isLive ? .CONVIVA_STREAM_LIVE : .CONVIVA_STREAM_VOD
        contentMetadata.streamUrl = player.config.sourceItem?.url(forType: player.streamType)?.absoluteString

        if let videoQuality = player.videoQuality {
            let bitrate = Int(videoQuality.bitrate) / 1000 // in kbps
            playerStateManager.setBitrateKbps!(bitrate)
            playerStateManager.setVideoResolutionWidth!(videoQuality.width)
            playerStateManager.setVideoResolutionHeight!(videoQuality.height)
        }

        client.updateContentMetadata(sessionKey, metadata: contentMetadata)
    }

    private func endSession() {
        client.detachPlayer(sessionKey)
        client.cleanupSession(sessionKey)
        sessionKey = NO_SESSION_KEY
        logger.debugLog(message: "Session ended")
    }

    // MARK: - meta data handling
    private func buildContentMetadata() {
        let sourceItem = player.config.sourceItem

        contentMetadata.applicationName = config.applicationName
        contentMetadata.assetName = sourceItem?.itemTitle
        contentMetadata.viewerId = config.viewerId

        var customInternTags: [String: Any] = [
            "streamType": playerHelper.streamType
        ]
        if let customTags = config.customTags {
            customInternTags.merge(customTags) { (_, new) in new }
        }
        contentMetadata.custom = NSMutableDictionary(dictionary: customInternTags)
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
        client.sendCustomEvent(NO_SESSION_KEY, eventname: name, withAttributes: attributes)
    }

    /**
     Sends a custom playback-level event to Conviva's Player Insight. A playback-level event can only be sent
     during an active video session.

     - Parameters:
        - name: The name of the event
        - attributes: A dictionary with custom event attributes
     */
    public func sendCustomPlaybackEvent(name: String, attributes: [String: String] = [:]) {
        if !isValidSession {
            logger.debugLog(message: "Cannot send playback event, no active monitoring session")
        }
        client.sendCustomEvent(sessionKey, eventname: name, withAttributes: attributes)
    }

    private func customEvent(event: PlayerEvent, args: [String: String] = [:]) {
        if !isValidSession {
            return
        }

        sendCustomPlaybackEvent(name: event.name, attributes: args)
    }

    private func onPlaybackStateChanged(playerState: PlayerState) {
        if !isValidSession {
            self.initSession()
        }

        playerStateManager.setPlayerState!(playerState)
        logger.debugLog(message: "Player state changed: \(playerState.rawValue)")
    }
}

// MARK: - PlayerListener
extension ConvivaAnalytics: BitmovinPlayerListenerDelegate {
    func onEvent(_ event: PlayerEvent) {
        logger.debugLog(message: "[ Player Event ] \(event.name)")
    }

    func onReady() {
        if !isValidSession {
            self.initSession()
        }
    }

    func onSourceLoaded() {
        if player.isAd {
            return
        }

        if !isValidSession {
            initSession()
        }
    }

    func onSourceUnloaded() {
        endSession()
    }

    func onTimeChanged() {
        updateSession()
    }

    func onError(_ event: ErrorEvent) {
        let message = "\(event.code) \(event.message)"
        client.reportError(sessionKey, errorMessage: message, errorSeverity: .ERROR_FATAL)
        endSession()
    }

    func onMuted(_ event: MutedEvent) {
        customEvent(event: event)
    }

    func onUnmuted(_ event: UnmutedEvent) {
        customEvent(event: event)
    }

    // MARK: - Playback state events
    func onPlay() {
        updateSession()
        onPlaybackStateChanged(playerState: .CONVIVA_PLAYING)
    }

    func onPaused() {
        onPlaybackStateChanged(playerState: .CONVIVA_PAUSED)
    }

    func onPlaybackFinished() {
        onPlaybackStateChanged(playerState: .CONVIVA_STOPPED)
        endSession()
    }

    func onStallStarted() {
        onPlaybackStateChanged(playerState: .CONVIVA_BUFFERING)
    }

    func onStallEnded() {
        if player.isPlaying {
            onPlaybackStateChanged(playerState: .CONVIVA_PLAYING)
        } else if player.isPaused {
            onPlaybackStateChanged(playerState: .CONVIVA_PAUSED)
        }
    }

    // MARK: - Seek / Timeshift events
    func onSeek(_ event: SeekEvent) {
        playerStateManager.setSeekStart!(Int64(event.position))
    }

    func onSeeked() {
        playerStateManager.setSeekEnd!(Int64(player.currentTime))
    }

    func onTimeShift(_ event: TimeShiftEvent) {
        playerStateManager.setSeekStart!(Int64(event.position))
    }

    func onTimeShifted() {
        playerStateManager.setSeekEnd!(Int64(player.currentTime))
    }

    // MARK: - Ad events
    func onAdStarted(_ event: AdStartedEvent) {
        let adPosition: AdPosition = AdEventUtil.parseAdPosition(event: event, contentDuration: player.duration)
        client.adStart(sessionKey, adStream: .ADSTREAM_SEPARATE, adPlayer: .ADPLAYER_CONTENT, adPosition: adPosition)
    }

    func onAdFinished() {
        client.adEnd(sessionKey)
    }

    func onAdSkipped(_ event: AdSkippedEvent) {
        customEvent(event: event)
        client.adEnd(sessionKey)
    }
    #if !os(tvOS)
    func onAdError(_ event: AdErrorEvent) {
        customEvent(event: event)
        client.adEnd(sessionKey)
    }
    #endif
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
