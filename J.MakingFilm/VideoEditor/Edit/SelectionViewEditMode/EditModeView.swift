//
//  EditModeView.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/05/14.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit

class EditModeView: UIView {
    var delegate: EditDelegate?

    @IBOutlet weak var mainEditPage: UIView!
    @IBOutlet weak var cutOffPage: UIView!

    override func awakeFromNib() {
        cutOffPage.isHidden = true
    }

    @IBAction func closeEdit() {
        delegate?.close()
        removeFromSuperview()
    }

    @IBAction func tryCutOff() {
        cutOffPage.isHidden = false
        mainEditPage.isHidden = true
        delegate?.tryCutOff()
    }

    @IBAction func tryDelete() {
        delegate?.delete()
    }

    @IBAction func startCutOff() {
        delegate?.cutOff()
    }

    @IBAction func locateToMain() {
        cutOffPage.isHidden = true
        mainEditPage.isHidden = false
        delegate?.locateToMainEditPage()
    }
}

protocol EditDelegate {
    func close()
    func tryCutOff()
    func delete()
    func cutOff()
    func locateToMainEditPage()
}
