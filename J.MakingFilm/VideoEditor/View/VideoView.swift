//
//  VideoView.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/04/08.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoView: UIImageView {
    private var avPlayer: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var avPlayerLayer: AVPlayerLayer = AVPlayerLayer()
    private var isPlaying: Bool = false
    private var onAutoPlay: Bool = false
    private var beenPresented = true
    private var observers: NSKeyValueObservation?
    private var playBackPosition: CGFloat = 0
    private var whileLoad: Bool = false
    private var appliedFilter: AVVideoComposition?
    private var timeObserver: Any?
    private var previousFilterType: VideoFilterUtility.FILTER_TYPE?
    private var currentVideoInfo: VideoEditorViewController.AssetInfomation?

    override func layoutSubviews() {
        updateLayerFrame()
    }

    override func layoutSublayers(of layer: CALayer) {
        updateLayerFrame()
    }

    private func updateLayerFrame() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.avPlayerLayer.frame = strongSelf.layer.frame
        }
    }

    var isAutoPlay: Bool {
        get {
            return onAutoPlay
        }
        set {
            onAutoPlay = newValue
        }
    }

    override func awakeFromNib() {
        avPlayerLayer.contentsGravity = .resizeAspect
        isUserInteractionEnabled = true
        backgroundColor = UIColor.black
    }

    func deinitialize() {
        removeData()
    }

    func clearData() {
        removeData()
    }

    private func removeData() {
        removePeriodTimeObserver()
        removeObserver()
        avPlayer?.replaceCurrentItem(with: nil)
    }

    func beenPresented(_ present: Bool) {
        beenPresented = present
    }

    func setVideoInfo(_ videoInfo: VideoEditorViewController.AssetInfomation?) {
        avPlayer?.replaceCurrentItem(with: nil)
        image = nil
        if let info = videoInfo {
            let playerItem = AVPlayerItem(asset: info.Asset)
            currentVideoInfo = info
            self.playerItem = playerItem
            if previousFilterType != nil {
                setFilter(previousFilterType!)
            }

            setPlayerWithPlayerItem(playerItem)
        }
    }

    func setFilter(_ filter: VideoFilterUtility.FILTER_TYPE) {
        previousFilterType = filter
        avPlayer?.currentItem?.videoComposition = avPlayer?.currentItem?.asset.setFilter(filterType: filter)
    }

    private func setPlayerWithPlayerItem(_ playerItem: AVPlayerItem) {
        self.playerItem = playerItem

        if avPlayer == nil {
            avPlayer = AVPlayer(playerItem: playerItem)
            if let info = currentVideoInfo, let startTime = info.startTime {
                avPlayer?.seek(to: CMTime(seconds: startTime, preferredTimescale: info.Asset.duration.timescale))
            }
            setPeriodObserver()
        } else {
            avPlayer?.replaceCurrentItem(with: playerItem)
        }

        avPlayerLayer.player = avPlayer
        avPlayerLayer.frame = frame
        observers = avPlayerLayer.observe(\.isReadyForDisplay, options: .new, changeHandler: { [weak self] (_, _) in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.avPlayer?.status == AVPlayer.Status.readyToPlay && strongSelf.avPlayerLayer.isReadyForDisplay {
                strongSelf.backgroundColor = UIColor.clear
                if let filter = strongSelf.previousFilterType {
                    strongSelf.setFilter(filter)
                }
                if strongSelf.onAutoPlay {
                    strongSelf.playVideo()
                }
            }
        })
        avPlayer?.isMuted = false
        NotificationCenter.default.removeObserver(self)
        setObservers()
        layer.addSublayer(avPlayerLayer)
    }

    private func setPeriodObserver() {
        timeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main, using: { [weak self](_) in
            guard let strongSelf = self else {
                return
            }

            var startTime: Double = 0
            if let startValue = strongSelf.currentVideoInfo?.startTime {
                startTime = startValue
            }
            let time = strongSelf.avPlayer?.currentTime().seconds == nil ? 0 : strongSelf.avPlayer!.currentTime().seconds - startTime
            (strongSelf.parentViewController as! VideoEditorViewController).onPeriod(time)

            var end = strongSelf.currentVideoInfo?.Asset.duration.seconds
            if let endTime = strongSelf.currentVideoInfo?.endTime {
                end = endTime
            }

            if end != nil, let currentTime = strongSelf.avPlayer?.currentTime().seconds {
                if currentTime >= end! {
                    (strongSelf.parentViewController as! VideoEditorViewController).setNextVideo()
                }
            }
        })
    }

    private func removePeriodTimeObserver() {
        if timeObserver != nil {
            avPlayer?.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
    }

    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didREachEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc func enterForeground() {
        if beenPresented {
            playVideo()
        } else {
            pauseVideo()
        }
    }

    @objc func enterBackground() {
        pauseVideo()
    }

    func playVideo() {
        setPeriodObserver()
        avPlayer?.play()
        avPlayer?.isMuted = false
        onAutoPlay = true
        isPlaying = true
    }

    func pauseVideo() {
        removePeriodTimeObserver()
        avPlayer?.pause()
        onAutoPlay = false
        isPlaying = false
    }

    func setAutoPlay(_ auto: Bool) {
        onAutoPlay = auto
    }

    func seekTimeZero() {
        avPlayer?.seek(to: CMTime.zero)
    }

    @objc private func didREachEnd() {
        if let editorViewController = parentViewController as? VideoEditorViewController {
            editorViewController.setNextVideo()
        }
    }

    func seekVideo(toPos pos: CGFloat) {
        pauseVideo()
        playBackPosition = pos
        let time: CMTime = CMTimeMakeWithSeconds(Float64(playBackPosition), preferredTimescale: avPlayer?.currentTime().timescale ?? 0)
        avPlayer?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }

    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
        if timeObserver != nil {
            avPlayer?.removeTimeObserver(timeObserver!)
        }
        observers?.invalidate()
    }

    func setMute(mute: Bool) {
        avPlayer?.isMuted = mute
    }
}
