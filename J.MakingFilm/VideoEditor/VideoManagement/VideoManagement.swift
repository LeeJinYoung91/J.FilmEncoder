//
//  VideoManageentStorage.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/04/07.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation

class VideoManagement {
    static private var sharedInstance = VideoManagement()
    static var Instance: VideoManagement {
        get {
            return sharedInstance
        }
    }

    var currentPickedStoryboard: String?
}
