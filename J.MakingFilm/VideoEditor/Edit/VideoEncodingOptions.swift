//
//  VideoEncodingOptions.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/04/28.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation

struct VideoEncodingSet: Codable {
    var Filter: VideoFilterUtility.FILTER_TYPE?
    var AudioPath: String?
    var Title: String?
    var ImportAssetInfomation: [VideoEditorViewController.AssetInfomation]?

    init() {
        ImportAssetInfomation = [VideoEditorViewController.AssetInfomation]()
    }
}

struct TimeValue: Codable {
    var timeSecond: Double
    var timeScale: Double

    init(sec: Double, scale: Double) {
        timeSecond = sec
        timeScale = scale
    }
}

class VideoEncodingSettingOptions {
    enum SETTING_TYPE: String, Codable {
        case FILTER
        case AUDIO
        case TEXT
        case ASSET_LIST
        case TITLE
    }

    private var KEY_SETTING: String
    private var settings: VideoEncodingSet?

    init(key: String) {
        KEY_SETTING = key
        settings = VideoEncodingSet()
    }

    func setFilter(_ filter: VideoFilterUtility.FILTER_TYPE?) {
        settings?.Filter = filter
    }

    func setAudioPath(_ path: String?) {
        settings?.AudioPath = path
    }

    func setTitle(_ title: String?) {
        settings?.Title = title
    }

    func setVideos(_ list: [VideoEditorViewController.AssetInfomation]?) {
        if list == nil {
            return
        }

        for assetInfo in list! {
            settings?.ImportAssetInfomation?.append(assetInfo)
        }
    }

    func saveCurrentSetting() {
        if settings == nil {
            return
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let jsonData = try? encoder.encode(settings!)
        if let data = jsonData, let jsonString = String(data: data, encoding: .utf8) {
            UserDefaults.standard.setValue(jsonString, forKey: KEY_SETTING)
        }
    }

    func getSetting() -> VideoEncodingSet? {
        if let jsonString = UserDefaults.standard.value(forKey: KEY_SETTING) as? String {
            if let data = jsonString.data(using: .utf8) {
                do {
                    let result = try JSONDecoder().decode(VideoEncodingSet.self, from: data)
                    return result
                } catch _ {
                    return nil
                }
            }
        }

        return nil
    }
}
