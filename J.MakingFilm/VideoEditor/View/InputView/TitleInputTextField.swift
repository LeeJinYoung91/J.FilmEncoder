//
//  TitleInputTextField.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/05/14.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import SnapKit

class TitleInputTextField: UITextField, UITextFieldDelegate {
    private var onEdit: Bool = false

    override func awakeFromNib() {
        delegate = self
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: frame.height, height: frame.height))
        rightViewMode = .always
        button.setImage(UIImage(named: "editerBtnRename"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.frame = CGRect(x: frame.width - (button.frame.width) - 5, y: (frame.height - button.frame.height) / 2, width: button.frame.width, height: button.frame.height)
        button.addTarget(self, action: #selector(editButton), for: .touchUpInside)
        addSubview(button)
    }

    @objc private func editButton() {
        onEdit = !onEdit
        if onEdit {
            becomeFirstResponder()
        } else {
            resignFirstResponder()
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return onEdit
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onEdit = false
        return true
    }
}
