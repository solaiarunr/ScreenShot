

import UIKit
import AVFoundation

class CustomVideoPlayerViewController: UIViewController {

    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
//    var playbackSlider = UISlider()
    var playbackSlider = ThickSlider()

    var playPauseButton = UIButton(type: .system)
    var backButton = UIButton(type: .system)
    var currentTimeLabel = UILabel()
    var durationLabel = UILabel()
    var timeObserverToken: Any?
    var isSeeking = false

    let videoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPlayer()
        setupUI()

        // Auto-play video
        player?.play()
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playbackSlider.setThumbImage(UIImage(named: "circle"), for: .normal)
        playbackSlider.tintColor = .white // or any other color for the thumb icon if using SF Symbols
        playbackSlider.maximumTrackTintColor = UIColor(white: 1.0, alpha: 0.3)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds // Fullscreen video
    }

    override var prefersStatusBarHidden: Bool {
        return true // Hide status bar for immersive fullscreen
    }

    deinit {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
        NotificationCenter.default.removeObserver(self)
    }

    func setupPlayer() {
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill // Fullscreen fill
        if let layer = playerLayer {
            view.layer.insertSublayer(layer, at: 0)
        }

        // Observe when video ends to loop
        NotificationCenter.default.addObserver(self,
            selector: #selector(videoDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem)

        // Time observer for slider and labels
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            self?.updateSliderAndLabels()
        }
    }

    @objc func videoDidFinishPlaying() {
        player?.seek(to: .zero)
        player?.play()
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    @objc func appDidEnterBackground() {
        playPauseButton.setImage(UIImage(named: "play_btn"), for: .normal)
    }

    func setupUI() {
        // Play/Pause Button
        playPauseButton.setImage(UIImage(named: "play_btn"), for: .normal)
        playPauseButton.tintColor = .white
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playPauseButton)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)

        
      
        backButton.setImage(UIImage(named: "backbtn"), for: .normal)
        backButton.tintColor = .white
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)

        // Slider
        playbackSlider.translatesAutoresizingMaskIntoConstraints = false
        playbackSlider.addTarget(self, action: #selector(sliderTouchBegan), for: .touchDown)
        playbackSlider.addTarget(self, action: #selector(sliderTouchEnded), for: [.touchUpInside, .touchUpOutside])
        view.addSubview(playbackSlider)

        // Current Time Label
        currentTimeLabel.text = "0:00"
        currentTimeLabel.textColor = .white
        currentTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentTimeLabel)

        // Duration Label
        durationLabel.text = "0:00"
        durationLabel.textColor = .white
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(durationLabel)

        // Layout
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -50),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 50),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            
            
            
                playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                playPauseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor), // Centers vertically
                playPauseButton.widthAnchor.constraint(equalToConstant: 50),
                playPauseButton.heightAnchor.constraint(equalToConstant: 50),
           


            playbackSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            playbackSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            playbackSlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            
            
            

            currentTimeLabel.trailingAnchor.constraint(equalTo: playbackSlider.leadingAnchor, constant: -8),
            currentTimeLabel.centerYAnchor.constraint(equalTo: playbackSlider.centerYAnchor),

            durationLabel.leadingAnchor.constraint(equalTo: playbackSlider.trailingAnchor, constant: 8),
            durationLabel.centerYAnchor.constraint(equalTo: playbackSlider.centerYAnchor)
        ])
    }

    @objc func togglePlayPause() {
        guard let player = player else { return }
        if player.timeControlStatus == .playing {
            player.pause()
            playPauseButton.setImage(UIImage(named: "play_btn"), for: .normal)
        } else {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }

    @objc func sliderTouchBegan() {
        isSeeking = true
    }

    @objc func sliderTouchEnded() {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(playbackSlider.value) * totalSeconds
        let seekTime = CMTime(seconds: value, preferredTimescale: 600)
        player?.seek(to: seekTime) { [weak self] _ in
            self?.isSeeking = false
        }
    }

    func updateSliderAndLabels() {
        guard let player = player,
              let duration = player.currentItem?.duration,
              !isSeeking else { return }

        let totalSeconds = CMTimeGetSeconds(duration)
        let currentSeconds = CMTimeGetSeconds(player.currentTime())

        guard totalSeconds.isFinite, currentSeconds.isFinite else { return }

        playbackSlider.value = Float(currentSeconds / totalSeconds)
        currentTimeLabel.text = formatTime(seconds: Int(currentSeconds))
        durationLabel.text = formatTime(seconds: Int(totalSeconds))
    }

    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
class ThickSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        // Set custom height (e.g., 8 points)
        let customHeight: CGFloat = 8
        let yPosition = bounds.midY - customHeight / 2
        return CGRect(x: bounds.origin.x, y: yPosition, width: bounds.width, height: customHeight)
    }
}
