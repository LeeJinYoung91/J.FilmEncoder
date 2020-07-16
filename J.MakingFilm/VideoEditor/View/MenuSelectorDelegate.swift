//
//  MenuSelectorDelegate.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/05/11.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit

protocol MenuSelectorDelegate {
    func startEdit(_ indexPath: IndexPath)
    func cancelEdit()
    func deleteItemAt(_ indexPath: IndexPath)
}

protocol ItemPickDelegate {
    func longPressAt(_ cell: UICollectionViewCell)
}
