//
//  MoviePlayerViewController.swift
//  AVFoundationDemo
//
//  Created by mobven-macbook on 6.08.2022.
//

import UIKit
import AVFoundation

class MoviePlayerViewController: UIViewController {

    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var backwardButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var videoContentView: UIView!
    
    private var asset: AVAsset!
    private var playerItem: AVPlayerItem!
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var timeObserverToken: Any?
    private let seekDuration: Float64 = 5 // seconds
    private let kTimescale: CMTimeScale = 12800
    var thumbnailImage: UIImage?
    
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                          queue: .main) { [weak self] time in
            print("Player time: \(time.seconds)")
            let videoTotalSeconds = self?.asset.duration.seconds
            if time.seconds >= videoTotalSeconds! {
                self?.stopVideo()
            }
            self?.updateSlider(to: Float(time.seconds / videoTotalSeconds!))
        }
    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadVideo()
        addPeriodicTimeObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override var shouldAutorotate: Bool {
        true
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func updateSlider(to newVal: Float) {
        timeSlider.value = newVal
    }
    
    func loadVideo() {
        guard let path = Bundle.main.path(forResource: videoName, ofType:"mp4") else {
            debugPrint("video  not found")
            return
        }
        asset = AVAsset(url: URL(fileURLWithPath: path))
        configurePlayer(asset: asset)
        updateSlider(to: 0)
    }
    
    func configurePlayer(asset: AVAsset) {

        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoContentView.bounds
        videoContentView.layer.addSublayer(playerLayer)
    }
    
    func playPauseVideo() {
        switch player.timeControlStatus {
        case .paused:
            play()
        case .playing:
           pause()
        default:
            break
        }
    }
    
    private func play() {
        player.play()
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    private func pause() {
        player.pause()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    private func stopVideo() {
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        player.seek(to: CMTime(value: 0, timescale: kTimescale))
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        playPauseVideo()
    }
    
    @IBAction func forwardButtonTapped(_ sender: UIButton) {
        guard let duration  = player.currentItem?.duration else{
            return
        }
        
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = playerCurrentTime + seekDuration
        
        if newTime < CMTimeGetSeconds(duration) {
            let time2: CMTime = CMTimeMake(value: Int64(newTime * Double(kTimescale)), timescale: kTimescale)
            player.seek(to: time2)
        }
    }
    
    @IBAction func backwardButtonTapped(_ sender: UIButton) {
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = playerCurrentTime - seekDuration

        if newTime < 0 {
            newTime = 0
        }
        
        let time2: CMTime = CMTimeMake(value: Int64(newTime * Double(kTimescale)), timescale: kTimescale)
        player.seek(to: time2)
    }
    
    
    func generateThumbnailImage() {
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        print(assetGenerator)
        do {
            let time = CMTimeMake(value: Int64(10 * Double(kTimescale)), timescale: kTimescale)
            let cgImage = try assetGenerator.copyCGImage(at: time, actualTime: nil)
            thumbnailImage = UIImage(cgImage: cgImage)
        } catch (let err) {
            print(err.localizedDescription)
        }
    }
    
    @IBAction func sliderChange(_ sender: UISlider) {
        let videoTotalSeconds = self.asset.duration.seconds
        let timeToSeek = videoTotalSeconds * Double(sender.value)
        player.seek(to: CMTimeMake(value: Int64(timeToSeek * Double(kTimescale)), timescale: kTimescale))
    }
}
