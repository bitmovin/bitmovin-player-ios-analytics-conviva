//
//  ConvivaAnalytics.swift
//  BitmovinConvivaAnalytics
//
//  Created by David Steinacher on 02.10.18.
//

import Foundation
import BitmovinPlayer
import ConvivaSDK

public class ConvivaAnalytics: NSObject {
    let player: BitmovinPlayer
    let customerKey: String
    let config: ConvivaConfiguration

    // Conviva related attributes
    var client: CISClientProtocol
    var playerStateManager: CISPlayerStateManagerProtocol

    var sessionKey: Int32 = NO_SESSION_KEY
    var contentMetadata: CISContentMetadata = CISContentMetadata()

    var isValidSession: Bool {
        return sessionKey != NO_SESSION_KEY
    }

    // MARK: - initializer
    public init?(player: BitmovinPlayer, customerKey: String, config: ConvivaConfiguration) throws {
        self.player = player
        self.customerKey = customerKey
        self.config = config

        // TODO: check if we can check if the player is already setup !!!!

        let systemInterFactory: CISSystemInterfaceProtocol = IOSSystemInterfaceFactory.initializeWithSystemInterface()
        let setting: CISSystemSettings = CISSystemSettings()

        if config.debugLoggingEnabled {
            setting.logLevel = LogLevel.LOGLEVEL_DEBUG
        }

        let systemFactory: CISSystemFactoryProtocol = CISSystemFactoryCreator.create(withCISSystemInterface: systemInterFactory, setting: setting)

        // TODO: improve failing mechanism

        let clientSetting : CISClientSettingProtocol = try CISClientSettingCreator.create(withCustomerKey: customerKey)
        if let gatewayUrl = config.gatewayUrl {
            clientSetting.setGatewayUrl(gatewayUrl.absoluteString)
        }

        self.client = try CISClientCreator.create(withClientSettings: clientSetting, factory: systemFactory)

        self.playerStateManager = self.client.getPlayerStateManager()
        self.playerStateManager.setPlayerType!("Bitmovin Player iOS")

        // TODO: extract version
        if let bitmovinPlayerVersion = Bundle(for: BitmovinPlayer.self).infoDictionary?["CFBundleShortVersionString"] as? String {
            self.playerStateManager.setPlayerVersion!(bitmovinPlayerVersion)
        }

        super.init()

        self.registerPlayerEvents()
    }

    // MARK: - session handling
    private func initSession() {
        buildContentMetadata()
        sessionKey = client.createSession(with: contentMetadata)

        playerStateManager.setPlayerState!(PlayerState.CONVIVA_STOPPED)
        client.attachPlayer(sessionKey, playerStateManager: playerStateManager)
    }

    private func updateSession() {
        // Update metadata
        if !isValidSession {
            return
        }
        contentMetadata.duration = Int(player.duration)
        contentMetadata.streamType = player.isLive ? .CONVIVA_STREAM_LIVE : .CONVIVA_STREAM_VOD
        contentMetadata.streamUrl = player.config.sourceItem?.url(forType: player.streamType)?.absoluteString

        client.updateContentMetadata(sessionKey, metadata: contentMetadata)
    }

    private func endSession() {
        client.detachPlayer(sessionKey)
        client.cleanupSession(sessionKey)
        sessionKey = NO_SESSION_KEY
    }

    // MARK: - meta data handling
    private func buildContentMetadata() {
        let sourceItem = player.config.sourceItem

        contentMetadata.applicationName = config.applicationName ?? "Unknown (no config.applicationName set)"
        contentMetadata.assetName = sourceItem?.itemTitle
        contentMetadata.viewerId = config.viewerId

        var customInternTags: [String: Any] = [
            "streamType": streamType
        ]
        if let customTags = config.customTags {
            customInternTags.merge(customTags) { (_, new) in new }
        }
        contentMetadata.custom = NSMutableDictionary(dictionary: customInternTags)
    }

    // MARK: - event handling
    // TODO: Docu / Example
    public func sendCustomApplicationEvent(name: String, attributes: [AnyHashable: Any] = [:]) {
        client.sendCustomEvent(NO_SESSION_KEY, eventname: name, withAttributes: attributes)
    }

    // TODO: Docu / Example
    public func sendCustomPlaybackEvent(name: String, attributes: [AnyHashable: Any] = [:]) {
        client.sendCustomEvent(sessionKey, eventname: name, withAttributes: attributes)
    }

    private func customEvent(event: PlayerEvent, args: [AnyHashable: Any] = [:]) {
        if !isValidSession {
            return
        }

        sendCustomPlaybackEvent(name: event.name, attributes: args)
    }

    private func registerPlayerEvents() {
        self.player.add(listener: self)
    }

    private func unregisterPlayerEvents() {
        player.remove(listener: self)
    }

    private func onPlaybackStateChanged(playerState: PlayerState) {
        if !isValidSession {
            self.initSession()
        }

        playerStateManager.setPlayerState!(playerState)
    }

    private var streamType: String {
        switch player.streamType {
        case .DASH:
            return "DASH"
        case .HLS:
            return "HLS"
        case .progressive:
            return "progressive"
        default:
            return "none"
        }
    }
}

extension ConvivaAnalytics: PlayerListener {
    public func onReady(_ event: ReadyEvent) {
        if !isValidSession {
            self.initSession()
        }
    }

    public func onSourceLoaded(_ event: SourceLoadedEvent) {
        if player.isAd {
            return
        }

        if !isValidSession {
            initSession()
        }
    }

    public func onTimeChanged(_ event: TimeChangedEvent) {
        updateSession()
    }

    public func onPlay(_ event: PlayEvent) {
        updateSession()
        onPlaybackStateChanged(playerState: .CONVIVA_PLAYING)
    }

    public func onPaused(_ event: PausedEvent) {
        onPlaybackStateChanged(playerState: .CONVIVA_PAUSED)
    }

    public func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        onPlaybackStateChanged(playerState: .CONVIVA_STOPPED)
        endSession()
    }

    public func onSeek(_ event: SeekEvent) {
        playerStateManager.setSeekStart!(Int64(event.seekTarget))
    }

    public func onSeeked(_ event: SeekedEvent) {
        playerStateManager.setSeekEnd!(Int64(player.currentTime))
    }

    public func onTimeShift(_ event: TimeShiftEvent) {
        playerStateManager.setSeekStart!(Int64(event.target))
    }

    public func onTimeShifted(_ event: TimeShiftedEvent) {
        playerStateManager.setSeekEnd!(Int64(player.currentTime)) // TODO: Test in live-stream
    }

    public func onStallStarted(_ event: StallStartedEvent) {
        onPlaybackStateChanged(playerState: .CONVIVA_BUFFERING)
    }

    public func onStallEnded(_ event: StallEndedEvent) {
        if player.isPlaying {
            onPlaybackStateChanged(playerState: .CONVIVA_PLAYING)
        } else if player.isPaused {
            onPlaybackStateChanged(playerState: .CONVIVA_PAUSED)
        }
    }

    public func onError(_ event: ErrorEvent) {
        let message = "\(event.code) \(event.message)"
        client.reportError(sessionKey, errorMessage: message, errorSeverity: .ERROR_FATAL)
        endSession()
    }

    // TODO: video quality changed
    public func onMuted(_ event: MutedEvent) {
        customEvent(event: event)
    }

    public func onUnmuted(_ event: UnmutedEvent) {
        customEvent(event: event)
    }
}

// TODO: extract
public class ConvivaConfiguration {
    public var debugLoggingEnabled: Bool = false
    public var gatewayUrl: URL?
    public var applicationName: String?
    public var viewerId: String?
    public var customTags: [String: Any]?

    public init() {
    }
}