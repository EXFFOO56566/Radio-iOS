

import AVFoundation

@objc public enum RsPlaybackState: Int {
    
    case playing
    case paused
    case stopped
    public var description: String {
        switch self {
        case .playing: return "Player is playing"
        case .paused: return "Player is paused"
        case .stopped: return "Player is stopped"
        }
    }
}


@objc public enum RsPlayerState: Int {
    
    case urlNotSet
    case readyToPlay
    case loading
    case loadingFinished
    case error
    public var description: String {
        switch self {
        case .urlNotSet: return "URL is not set"
        case .readyToPlay: return "Ready to play"
        case .loading: return "Loading"
        case .loadingFinished: return "Loading finished"
        case .error: return "Error"
        }
    }
}

@objc public protocol RsDelegate: class {
    
    func radioPlayer(_ player: RsPlayer, playerStateDidChange state: RsPlayerState)
    
    func radioPlayer(_ player: RsPlayer, playbackStateDidChange state: RsPlaybackState)
    
    @objc optional func radioPlayer(_ player: RsPlayer, itemDidChange url: URL?)
   
    @objc optional func radioPlayer(_ player: RsPlayer, metadataDidChange artistName: String?, trackName: String?)
    
    @objc optional func radioPlayer(_ player: RsPlayer, metadataDidChange rawValue: String?)
   
    @objc optional func radioPlayer(_ player: RsPlayer, artworkDidChange artworkURL: URL?)
}


open class RsPlayer: NSObject {
    
    public static let shared = RsPlayer()
    open weak var delegate: RsDelegate?
    
    open var radioURL: URL? {
        didSet {
            radioURLDidChange(with: radioURL)
        }
    }
    
    open var isAutoPlay = true
    open var enableArtwork = true
    open var artworkSize = 100
    open var rate: Float? {
        return player?.rate
    }
    
    open var isPlaying: Bool {
        switch playbackState {
        case .playing:
            return true
        case .stopped, .paused:
            return false
        }
    }
    
    open private(set) var state = RsPlayerState.urlNotSet {
        didSet {
            guard oldValue != state else { return }
            delegate?.radioPlayer(self, playerStateDidChange: state)
        }
    }
    
    open private(set) var playbackState = RsPlaybackState.stopped {
        didSet {
            guard oldValue != playbackState else { return }
            delegate?.radioPlayer(self, playbackStateDidChange: playbackState)
        }
    }
    
    private var player: AVPlayer?
    private var lastPlayerItem: AVPlayerItem?
    private var headphonesConnected: Bool = false
    
    private var playerItem: AVPlayerItem? {
        didSet {
            playerItemDidChange()
        }
    }
    private let reachability = Reachability()!
    
    private var isConnected = false
    
    private override init() {
        super.init()
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay])
        
        setupNotifications()
        
        checkHeadphonesConnection(outputs: AVAudioSession.sharedInstance().currentRoute.outputs)
        
        try? reachability.startNotifier()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        isConnected = reachability.connection != .none
    }
    
    open func play() {
        guard let player = player else { return }
        if player.currentItem == nil, playerItem != nil {
            player.replaceCurrentItem(with: playerItem)
        }
        
        player.play()
        playbackState = .playing
    }
    
    open func pause() {
        guard let player = player else { return }
        player.pause()
        playbackState = .paused
    }
    
    open func stop() {
        guard let player = player else { return }
        player.replaceCurrentItem(with: nil)
        timedMetadataDidChange(rawValue: nil)
        playbackState = .stopped
    }
    
    open func togglePlaying() {
        isPlaying ? pause() : play()
    }
    
    private func radioURLDidChange(with url: URL?) {
        resetPlayer()
        guard let url = url else { state = .urlNotSet; return }
        
        state = .loading
        
        preparePlayer(with: AVAsset(url: url)) { (success, asset) in
            guard success, let asset = asset else {
                self.resetPlayer()
                self.state = .error
                return
            }
            self.setupPlayer(with: asset)
        }
    }
    
    private func setupPlayer(with asset: AVAsset) {
        if player == nil {
            player = AVPlayer()
            player?.allowsExternalPlayback = false
        }
        
        playerItem = AVPlayerItem(asset: asset)
    }
    
     
    private func playerItemDidChange() {
        
        guard lastPlayerItem != playerItem else { return }
        
        if let item = lastPlayerItem {
            pause()
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
            item.removeObserver(self, forKeyPath: "status")
            item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            item.removeObserver(self, forKeyPath: "timedMetadata")
        }
        
        lastPlayerItem = playerItem
        timedMetadataDidChange(rawValue: nil)
        
        if let item = playerItem {
            
            item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "timedMetadata", options: NSKeyValueObservingOptions.new, context: nil)
            
            player?.replaceCurrentItem(with: item)
            if isAutoPlay { play() }
        }
        
        delegate?.radioPlayer?(self, itemDidChange: radioURL)
    }
    
    private func preparePlayer(with asset: AVAsset?, completionHandler: @escaping (_ isPlayable: Bool, _ asset: AVAsset?)->()) {
        guard let asset = asset else {
            completionHandler(false, nil)
            return
        }
        
        let requestedKey = ["playable"]
        
        asset.loadValuesAsynchronously(forKeys: requestedKey) {
            
            DispatchQueue.main.async {
                var error: NSError?
                
                let keyStatus = asset.statusOfValue(forKey: "playable", error: &error)
                if keyStatus == AVKeyValueStatus.failed || !asset.isPlayable {
                    completionHandler(false, nil)
                    return
                }
                
                completionHandler(true, asset)
            }
        }
    }
    
    private func timedMetadataDidChange(rawValue: String?) {
        
        
        
        if (rawValue == nil){
            
            let rawValue = "ups, stream - not have title artist"
            let parts = rawValue.components(separatedBy: " - ")
            delegate?.radioPlayer?(self, metadataDidChange: parts.first, trackName: parts.last)
            delegate?.radioPlayer?(self, metadataDidChange: rawValue)
            shouldGetArtwork(for: rawValue, enableArtwork)
        } else {
            
            let parts = rawValue?.components(separatedBy: " - ")
            delegate?.radioPlayer?(self, metadataDidChange: parts?.first, trackName: parts?.last)
            delegate?.radioPlayer?(self, metadataDidChange: rawValue)
            shouldGetArtwork(for: rawValue, enableArtwork)
        }
        
        
    }
    
    private func shouldGetArtwork(for rawValue: String?, _ enabled: Bool) {
        guard enabled else { return }
        guard let rawValue = rawValue else {
            self.delegate?.radioPlayer?(self, artworkDidChange: nil)
            return
        }
        
        RsAPI.getArtwork(for: rawValue, size: artworkSize, completionHandler: { [unowned self] artworlURL in
            DispatchQueue.main.async {
                self.delegate?.radioPlayer?(self, artworkDidChange: artworlURL)
            }
        })
    }

    private func reloadItem() {
        player?.replaceCurrentItem(with: nil)
        player?.replaceCurrentItem(with: playerItem)
    }
    
    private func resetPlayer() {
        stop()
        playerItem = nil
        lastPlayerItem = nil
        player = nil
    }
    
    deinit {
        resetPlayer()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        switch type {
        case .began:
            DispatchQueue.main.async { self.pause() }
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { break }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            DispatchQueue.main.async { options.contains(.shouldResume) ? self.play() : self.pause() }
        @unknown default:
            break
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        guard let reachability = note.object as? Reachability else { return }
        
        if reachability.connection != .none, !isConnected {
            checkNetworkInterruption()
        }
        
        isConnected = reachability.connection != .none
    }
    
    private func checkNetworkInterruption() {
        guard
            let item = playerItem,
            !item.isPlaybackLikelyToKeepUp,
            reachability.connection != .none else { return }
        
        player?.pause()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if !item.isPlaybackLikelyToKeepUp { self.reloadItem() }
            self.isPlaying ? self.player?.play() : self.player?.pause()
        }
    }
    
    private func checkHeadphonesConnection(outputs: [AVAudioSessionPortDescription]) {
        for output in outputs where output.portType == .headphones {
            headphonesConnected = true
            break
        }
        headphonesConnected = false
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else { return }
        
        switch reason {
        case .newDeviceAvailable:
            checkHeadphonesConnection(outputs: AVAudioSession.sharedInstance().currentRoute.outputs)
        case .oldDeviceUnavailable:
            guard let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription else { return }
            checkHeadphonesConnection(outputs: previousRoute.outputs);
            DispatchQueue.main.async { self.headphonesConnected ? () : self.pause() }
        default: break
        }
    }
    
  
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let item = object as? AVPlayerItem, let keyPath = keyPath, item == self.playerItem {
            
            switch keyPath {
                
            case "status":
                
                if player?.status == AVPlayer.Status.readyToPlay {
                    self.state = .readyToPlay
                } else if player?.status == AVPlayer.Status.failed {
                    self.state = .error
                }
                
            case "playbackBufferEmpty":
                
                if item.isPlaybackBufferEmpty {
                    self.state = .loading
                    self.checkNetworkInterruption()
                }
                
            case "playbackLikelyToKeepUp":
                
                self.state = item.isPlaybackLikelyToKeepUp ? .loadingFinished : .loading
            
            case "timedMetadata":
                let rawValue = item.timedMetadata?.first?.value as? String
                timedMetadataDidChange(rawValue: rawValue)
                
            default:
                break
            }
        }
    }
}
