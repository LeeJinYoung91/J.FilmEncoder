//
//  IndicatorCell.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/06/02.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit

class IndicatorCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var indicatorImage: UIImageView!

    override func awakeFromNib() {
        indicatorImage.isHidden = false
        timeLabel.isHidden = false
        isUserInteractionEnabled = false
    }

    var showIndicator: Bool = true {
        didSet {
            indicatorImage.isHidden = !showIndicator
            timeLabel.isHidden = showIndicator
        }
    }

    var time: String = "" {
        didSet {
            timeLabel.text = time
        }
    }
}
