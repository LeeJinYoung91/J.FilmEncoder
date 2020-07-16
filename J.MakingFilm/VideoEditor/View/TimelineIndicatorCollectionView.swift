//
//  TimelineIndicatorCollectionView.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/06/02.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit

class TimelineIndicatorCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout {
    private let cellWidth: CGFloat = 40
    private let provideValue: Int = 5

    override func awakeFromNib() {
        delegate = self
        dataSource = self
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension TimelineIndicatorCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 60
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.dequeueReusableCell(withReuseIdentifier: "id_indicator", for: indexPath) as! IndicatorCell
        let showIndicator = !(indexPath.row % provideValue == 0) && (indexPath.row != 0)
        cell.time = String(indexPath.row)
        cell.showIndicator = showIndicator
        return cell
    }
}
