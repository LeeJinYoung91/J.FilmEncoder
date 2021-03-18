//
//  itemPickerCell.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/05/08.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit

class PickerItemCell: UICollectionViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var selectImage: UIImageView!

    var longTapPressed: UITapGestureRecognizer?
    var filter: VideoFilterUtility.FILTER_TYPE? {
        didSet {
            //TODO: - Set Filter Icon
            thumbnail.image = UIImage(named: "btnRecordOkDn")
        }
    }
    var bgmPath: String? {
        didSet {
            //TODO: - Set BGM Icon
            thumbnail.image = UIImage(named: "btnRecordOkDn")
        }
    }
    var delegate: ItemPickDelegate?

    override func awakeFromNib() {
        selectImage.isHidden = true
    }

    var videoPath: String? {
        didSet {
            func getImage() {
                guard videoPath != nil else {
                    return
                }
                thumbnail.image = VideoUtility.shared.getThumbnailImageFromVideoUrl(url: URL(fileURLWithPath: videoPath!))
                longTapPressed = UITapGestureRecognizer(target: self, action: #selector(tapImage(gesture:)))
                addGestureRecognizer(longTapPressed!)
            }

            getImage()
        }
    }

    @objc func tapImage(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            delegate?.longPressAt(self)
        }
    }

    func select(_ didSelect: Bool) {
        selectImage.isHidden = !didSelect
    }
}
