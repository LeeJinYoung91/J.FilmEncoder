//
//  Define.swift
//  MovieMaker
//
//  Created by JinYoung Lee on 2020/04/29.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit

let DocumentPath = ((NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray).object(at: 0) as! NSString)
let cutImage = UIImage(named: "editerMovieclipCutsection")
let selImage = UIImage(named: "editerMovieclipSel")
let sliderLeftHandlerImage = UIImage(named: "editerTimelineBtnClipHandleLeftNor")
let sliderLeftHandlerSelImage = UIImage(named: "editerTimelineBtnClipHandleLeftSel")
let sliderRightHandlerImage = UIImage(named: "editerTimelineBtnClipHandleRightNor")
let sliderRightHandlerSelImage = UIImage(named: "editerTimelineBtnClipHandleRightSel")
