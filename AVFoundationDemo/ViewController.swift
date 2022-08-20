//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by Hasan on 30.07.2022.
//

import UIKit
import AVFoundation
import AVKit

let videoName = "istanbul_commercial"

class ViewController: UIViewController {

    @IBOutlet var videoContentView: UIView!
    @IBOutlet var playPauseButton: UIButton!
    var myPlayer: AVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureVideoPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    func configureVideoPlayer() {
        guard let path = Bundle.main.path(forResource: videoName, ofType:"mp4") else {
            debugPrint("video  not found")
            return
        }
        myPlayer = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: myPlayer)
        playerLayer.frame = videoContentView.bounds
        videoContentView.layer.addSublayer(playerLayer)
    }
    
    @IBAction func playPauseCommercialVideo() {
        playPause()
    }
    
    @IBAction func seekTime() {
        myPlayer.seek(to: CMTimeMake(value: 100, timescale: 1))
//        myPlayer.currentItem?.forwardPlaybackEndTime = CMTimeMake(value: 100, timescale: 1)
    }
    
    func playPause() {
        switch myPlayer.timeControlStatus {
        case .playing:
            pause()
        case .paused:
           play()
        default:
            break
        }
    }
    
    private func play() {
        myPlayer.play()
        playPauseButton.setTitle("Pause", for: .normal)
    }
    
    private func pause() {
        myPlayer.pause()
        playPauseButton.setTitle("Play", for: .normal)
    }
    
    @IBAction func presentCommercialVideoOnPlayerController() {
        
        guard let path = Bundle.main.path(forResource: videoName, ofType:"mp4") else {
            debugPrint("video  not found")
            return
        }
        
        pause()
        
        let playerController = AVPlayerViewController()
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    @IBAction func openMoviePlayerVC(_ sender: UIButton) {
        guard let moviePlayerVC = UIStoryboard(name: "MoviePlayer", bundle: .main).instantiateInitialViewController() as? MoviePlayerViewController else { return }
        moviePlayerVC.modalPresentationStyle = .fullScreen
        moviePlayerVC.isModalInPresentation = false
        present(moviePlayerVC, animated: true)
    }
}

extension ViewController {
    override var shouldAutorotate: Bool {
        true
    }
}
