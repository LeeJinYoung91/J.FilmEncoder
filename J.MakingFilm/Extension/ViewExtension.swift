//
//  ViewExtension.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/04/08.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
