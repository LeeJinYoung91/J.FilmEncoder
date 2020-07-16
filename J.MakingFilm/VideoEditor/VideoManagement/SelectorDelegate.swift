//
//  VideoSelectorDelegate.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/04/23.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation

protocol SelectorDelegate {
    func selectVideos(_ videoInfos: [VideoEditorViewController.LocalVideo])
    func selectFilter(_ filter: VideoFilterUtility.FILTER_TYPE)
    func selectBGM(_ bgmPath: String)
}
