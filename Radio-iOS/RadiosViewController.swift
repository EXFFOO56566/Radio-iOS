//
//  RadiosViewController.swift
//  RADIOBOX
//
//  Created by DEVS on 17.08.2020.
//  Copyright © 2020 Simpleapp. All rights reserved.
//

import UIKit
import UIKit
import MediaPlayer
import AVFoundation
import Alamofire
import AlamofireImage
import KBImageView
import CRNotifications
import HCSStarRatingView
import SCLAlertView
import AARatingBar

class RadiosViewController: UIViewController, RadioPlayerDelegate {
    
    
    var radio: Radio!
    @IBOutlet weak var playingButton: UIButton!
    @IBOutlet weak var nameRadio: UILabel!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var rateBar: AARatingBar!
    @IBOutlet weak var rateBtn: UIButton!
    @IBOutlet weak var appleFind: UIButton!
    @IBOutlet weak var complBtn: UIButton!
    
    
    var currentTrack: Track!
    var newStation = true
    var nowPlayingImageView: UIImageView!
    let radioPlayer = RsPlayer.shared
    let player = RadioPlayer()
    var radioUrl: String!
    var color: ColorUi!
    var applePreview: String!
    var artImage: UIImage!
    var radioId: String!
    var appleHelp: AppleHelpers!
    var defImage: UIImage?
    var isLogin: Bool!
    var isLike: Bool!
    var like: Like!
    var ratingz: NSNumber!
    
    var user: User!
    var urlMusic: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User.current()
        if user != nil {
            
            isLogin = true
        } else {
            
            isLogin = false
        }
        
     
        let alr = radio.allrating
        
        rateBar.value = CGFloat(truncating: alr)
        rateBtn.layer.cornerRadius = 10
        rateBar.ratingDidChange = { ratingValue in
            
            self.ratingz = ratingValue as NSNumber
        }
        
        let url = NSURL(string: DEF_IMG)! as URL
        if let imageData: NSData = NSData(contentsOf: url) {
            defImage = UIImage(data: imageData as Data)
        }
        
        setupRemoteCommandCenter()
        appleHelp = AppleHelpers()
        
        player.delegate = self
        
        self.radioUrl  = radio.stream as String
        
        self.newStation ? self.stationDidChange() : self.playerStateDidChange(self.radioPlayer.state, animate: false)
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            if kDebugLog { print("audioSession could not be activated") }
        }
        
        artistLabel.minimumScaleFactor = 0.1
        artistLabel.adjustsFontSizeToFitWidth = true
        artistLabel.lineBreakMode = .byClipping
        artistLabel.numberOfLines = 0
        artistLabel.text = artistLabel.text?.uppercased()
        
        songLabel.minimumScaleFactor = 0.1
        songLabel.adjustsFontSizeToFitWidth = true
        songLabel.lineBreakMode = .byClipping
        songLabel.numberOfLines = 0
        songLabel.text = songLabel.text?.uppercased()
        
        nameRadio.minimumScaleFactor = 0.1
        nameRadio.adjustsFontSizeToFitWidth = true
        nameRadio.lineBreakMode = .byClipping
        nameRadio.numberOfLines = 0
        
        
        
        self.nameRadio.text = self.radio.name.uppercased()
        
        self.newStation ? self.stationDidChange() : self.playerStateDidChange(self.radioPlayer.state, animate: false)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        if(isLogin){
            checkLike()
        }
        
        
        
        
    }
    
    @IBAction func complBtn(_ sender: Any) {
        
        
        let alertView = SCLAlertView()
        
        alertView.addButton("This radio not work") {
            
            let radioUser = self.radio.user
            
            let compl = Complaint()
            compl.radio = self.radio
            compl.type = "not work"
            compl.user = radioUser
            compl.saveInBackground { (ok, error) in
                
                let alrt = Alertz()
                alrt.doneAlet()
                
            }
        }
        alertView.addButton("This is my station!") {
            
            let radioUser = self.radio.user
            
            let compl = Complaint()
            compl.radio = self.radio
            compl.type = "my radio"
            compl.user = radioUser
            compl.saveInBackground { (ok, error) in
                
                let alrt = Alertz()
                alrt.doneAlet()
                
            }
            
            
        }
        alertView.showSuccess("Info", subTitle: "Station complaint")
        
    }
    
    @IBAction func appleFinder(_ sender: Any) {
        
        let urlAppmusic = self.urlMusic
        UIApplication.shared.openURL(NSURL(string: urlAppmusic!)! as URL)
        
        
    }
    
    
    
    @IBAction func rateRadio(_ sender: Any) {
        
        if ( isLogin){
            
            let query = Rating.query()
            query?.whereKey("radio", equalTo: radio!)
            query?.whereKey("user", equalTo: user!)
            query?.findObjectsInBackground(block: { (object, error) in
                
                if (error == nil){
                    
                    if(self.ratingz.intValue > 1){
                        
                        if(object?.count == 0){
                            
                            let rt = Rating()
                            rt.user = self.user
                            rt.radio = self.radio
                            rt.saveInBackground { (ok, error) in
                                
                                let rating1 = self.radio.rating.intValue
                                let voit = self.radio.voiting.intValue
                                
                                let allRat = rating1 + self.ratingz.intValue
                                let voitss = voit + 1
                                let finalrt = allRat / voitss
                                
                                self.radio.voiting = NSNumber(value: voitss)
                                self.radio.rating = NSNumber(value: allRat)
                                self.radio.allrating = NSNumber(value: finalrt)
                                self.radio.saveInBackground { (ok, error) in
                                    
                                }
                                
                            }
                            
                        } else{
                            
                            CRNotifications.showNotification(type: CRNotifications.error, title:"Opsss..", message:"You have already voted for this station", dismissDelay: 7)
                            
                            
                        }
                    } else {
                        
                        CRNotifications.showNotification(type: CRNotifications.error, title:"Opsss..", message:"Put your rating for this radio station", dismissDelay: 7)
                    }
                    
                }
                
            })
            
            
        } else{
            
            CRNotifications.showNotification(type: CRNotifications.error, title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("first", comment: ""), dismissDelay: 3)
            
        }
        
        
    }
    
    func checkLike(){
        
        let query = Like.query()
        query?.whereKey("user", equalTo: user!)
        query?.whereKey("radio", equalTo: radio!)
        query?.findObjectsInBackground(block: { (object, error) in
            
            if (error == nil){
                
                
                if(object?.count == 0){
                    
                    self.isLike = false
                    
                    self.likeButton.tintColor = UIColor.white
                    
                } else{
                    
                    self.likeButton.tintColor = UIColor.red
                    self.isLike = true
                }
            }
            
        })
        
    }
    
    @IBAction func shared(_ sender: Any) {
        
        if(currentTrack != nil){
            
            let radioShoutout = "I'm listening to Best radio place via RADIOBOX"
            let shareImage = ShareImageGenerator(radioShoutout: radioShoutout, track: currentTrack).generate()
            
            let activityViewController = UIActivityViewController(activityItems: [radioShoutout, shareImage], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
            activityViewController.popoverPresentationController?.sourceView = view
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            
            activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed {
                }
            }
            present(activityViewController, animated: true, completion: nil)
        }
        
        
    }
    
    @IBAction func likeRadio(_ sender: Any) {
        
        if(isLogin){
            
            if(isLike){
                
                CRNotifications.showNotification(type: CRNotifications.error, title:"Oops...", message:"You have already saved this station", dismissDelay: 7)
                
            } else {
                
                let like = Like()
                like.radio = radio
                like.user = user
                like.saveInBackground { (ok, error) in
                    
                    self.likeButton.tintColor = UIColor.red
                }
                
            }
            
            
        } else {
            
            CRNotifications.showNotification(type: CRNotifications.error, title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("first", comment: ""), dismissDelay: 3)
            
        }
        
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == .right {
            print("Swipe Right")
        }
        else if gesture.direction == .left {
            print("Swipe Left")
        }
        else if gesture.direction == .up {
            print("Swipe Up")
        }
        else if gesture.direction == .down {
            print("Swipe Down")
            dismiss(animated: true, completion: nil)
        }
    }
    
    func stationDidChange() {
        radioPlayer.radioURL = URL(string: radioUrl)
        
    }
    
    @IBAction func playingPressed(_ sender: Any) {
        
        if(player.player.isPlaying){
            
            player.player.pause()
            playingButton.setImage(UIImage(named: "play"), for: .normal)
            
            
        } else {
            
            player.player.play()
            playingButton.setImage(UIImage(named: "pause"), for: .normal)
            
            
        }
    }
    
    func playerStateDidChange(_ state: RsPlayerState, animate: Bool) {
        
        let message: String?
        
        switch state {
        case .loading:
            message = "Loading Station ..."
        case .urlNotSet:
            message = "Station URL not valide"
        case .readyToPlay, .loadingFinished:
            return
        case .error:
            message = "Error Playing"
        }
        
        updateLabels(with: message, animate: animate)
    }
    
    func updateLabels(with statusMessage: String? = nil, animate: Bool = true) {
        
        guard let statusMessage = statusMessage else {
            songLabel.text = currentTrack.title.uppercased()
            artistLabel.text = currentTrack.artist.uppercased()
            return
        }
        
        
        guard songLabel.text != statusMessage else { return }
        
        songLabel.text = statusMessage
        // artistLabel.text = currentStation.name
        updateLockScreen(with: currentTrack)
        
        if animate {
            
        }
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        
        commandCenter.playCommand.addTarget { event in
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { event in
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { event in
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { event in
            return .success
        }
    }
    
    func updateLockScreen(with track: Track?) {
        
        var nowPlayingInfo = [String : Any]()
        
        if let image = track?.artworkImage {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { size -> UIImage in
                return image
            })
            
        }
        
        if let artist = track?.artist {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }
        
        if let title = track?.title {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func playerStateDidChange(_ playerState: RsPlayerState) {
        
    }
    
    func playbackStateDidChange(_ playbackState: RsPlaybackState) {
        
    }
    
    
    func trackDidUpdate(_ track: Track?) {
        
        
        let artist = track!.artist
        let title = track!.title
        
        artistLabel.text = artist.uppercased()
        songLabel.text = title.uppercased()
        
        let art = String(format: "%@ - %@", track!.artist,track!.title)
        findAppleMusic(name: art)
        
        
    }
    
    func trackArtworkDidUpdate(_ track: Track?) {
        
        if APPLE_IMAGE {
            
            cover.image = track?.artworkImage?.af_imageRounded(withCornerRadius: 0)
            self.artImage = track?.artworkImage
            
        } else {
            
            cover.image = defImage
            self.artImage = defImage
        }
        
        updateLockScreen(with: track)
        currentTrack = track
        self.artImage = track?.artworkImage
        
        
    }
    
    func findAppleMusic(name: String){
        
        appleHelp.getPreviewUrl(din: name) { (url, found, bigArtwork) in
            
            print("FF - - - -  ", found)
            
            if found{
                
                self.applePreview = url
                self.urlMusic = url
                self.appleFind.tintColor = UIColor.red
                self.appleFind.isEnabled = true
                
            } else{
                
                // self.appleBtn.isEnabled = false
                self.appleFind.tintColor = UIColor.white
                self.appleFind.isEnabled = false
            }
        }
        
        
    }
    
    
    
}
