//
//  AvassetExtension.swift
//  VideoEditor
//
//  Created by JinYoung Lee on 2018. 7. 11..
//  Copyright © 2018년 JinYoung Lee. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAsset {
    func normalizingMediaDuration() -> AVAsset? {
        let mixComposition: AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()

        guard let video = tracks(withMediaType: AVMediaType.video).first else {
            return nil
        }

        guard let audio = tracks(withMediaType: AVMediaType.audio).first else {
            return nil
        }

        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionAudioTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)

        let duration = video.timeRange.duration.seconds > audio.timeRange.duration.seconds ? audio.timeRange.duration : video.timeRange.duration

        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: duration), of: video, at: CMTime.zero)
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: duration), of: audio, at: CMTime.zero)
        } catch {
            return nil
        }

        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: duration)

        return mixComposition
    }

    func exportVideoInTimeSection(fileName: String, timeRange: CMTimeRange, finish: ((Bool, URL?) -> Void)?) {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: self)
        if compatiblePresets.contains(AVAssetExportPresetHighestQuality) {
            let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetHighestQuality)
            let tempPath = NSTemporaryDirectory()
            let filePath: String = tempPath.appending(fileName)

            if FileManager.default.fileExists(atPath: filePath) {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: filePath))
            }

            exportSession?.outputFileType = AVFileType.mp4

            exportSession?.timeRange = timeRange
            exportSession?.outputURL = URL(fileURLWithPath: filePath)

            exportSession?.exportAsynchronously(completionHandler: {
                finish?((exportSession?.status)! == .completed, exportSession?.outputURL)
            })
        }
    }
}
