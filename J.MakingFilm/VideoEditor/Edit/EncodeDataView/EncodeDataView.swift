//
//  EncodeDataView.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/05/29.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit

class EncodeDataView: UIView {
    @IBOutlet weak var deleteButton: UIButton?
    @IBOutlet weak var dataTitle: UILabel?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        let view = Bundle.main.loadNibNamed("EncodeDataView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        addSubview(view)
    }

    override func awakeFromNib() {
        dataTitle?.text = nil
        deleteButton?.isHidden = true
    }

    var Title: String? {
        willSet {
            dataTitle?.text = newValue
            deleteButton?.isHidden = !(newValue != nil && !newValue!.isEmpty)
        }
    }

    var delegate: dataViewDelegate?
    var dataType: VideoEditorViewController.VideoCompositionType?

    @IBAction func clickDelete() {
        Title = nil
        delegate?.deleteCurrentEncodeData(type: dataType)
    }
}

protocol dataViewDelegate {
    func deleteCurrentEncodeData(type: VideoEditorViewController.VideoCompositionType?)
}
