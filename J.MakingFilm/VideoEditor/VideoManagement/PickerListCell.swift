//
//  PickerListView.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/05/08.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit

class PickerListCell: UITableViewCell {
    @IBOutlet weak var itemPickerListView: UICollectionView!

    weak var containerViewController: PickerViewController?

    var cellHeight: CGFloat = 0
    var videoList: [String]?
    var sceneTitle: String?
    
    var itemType: PickerViewController.ItemListType = .Video
    private var selectedVideoPathList = [String]()
    private var selectIndexPath: [IndexPath] = [IndexPath]()
    private var filterList = [VideoFilterUtility.FILTER_TYPE]()
    private var bgmList = [String]()

    func setUp() {
        for filter in VideoFilterUtility.FILTER_TYPE.order {
            filterList.append(filter)
        }

        bgmList = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: "BGM")

        itemPickerListView.delegate = self
        itemPickerListView.dataSource = self
        itemPickerListView.contentSize = CGSize(width: cellHeight, height: cellHeight)
    }

    func reloadItem() {
        itemPickerListView.reloadData()
    }
}

extension PickerListCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if itemType == .Video {
            count = (videoList?.count == 0 || videoList == nil) ? 0 : videoList!.count
        } else if itemType == .Filter {
            count = filterList.count
        } else {
            count = bgmList.count
        }
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! PickerItemCell
        if itemType == .Video {
            cell.videoPath = videoList?[indexPath.row]
        } else if itemType == .Filter {
            cell.filter = filterList[indexPath.row]
        } else {
            cell.bgmPath = bgmList[indexPath.row]
        }

        cell.select(false)

        let view = superview as! UITableView
        if let tableViewSection = view.indexPath(for: self)?.section {
            let newIndexPath = IndexPath(item: indexPath.row, section: tableViewSection)
            cell.select(containerViewController!.selectIndexPath.contains(newIndexPath))
        }

        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if itemType == .Video {
            guard containerViewController!.mode == .SELECT else {
                return
            }
        }

        pickItem(indexPath)
    }

    private func pickItem(_ indexPath: IndexPath) {
        if containerViewController == nil {
            return
        }

        if let cell = itemPickerListView.cellForItem(at: indexPath) as? PickerItemCell {
            if itemType == .Video {
                let selfIndexPath = (superview as! UITableView).indexPath(for: self)!
                let newIndexPath = IndexPath(item: indexPath.row, section: selfIndexPath.section)

                if containerViewController!.selectIndexPath.contains(newIndexPath) {
                    containerViewController?.selectIndexPath.remove(at: containerViewController!.selectIndexPath.firstIndex(of: newIndexPath)!)
                    cell.select(false)
                } else {
                    containerViewController!.selectIndexPath.append(newIndexPath)
                    cell.select(true)
                }
            } else if itemType == .BGM {
                containerViewController?.selectBGM(cell.bgmPath)
            } else {
                containerViewController?.selectFilter(cell.filter)
            }
        }
    }
}

extension PickerListCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellHeight-18, height: cellHeight-18)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 44, bottom: 0, right: 0)
    }
}

extension PickerListCell: ItemPickDelegate {
    func longPressAt(_ cell: UICollectionViewCell) {
        var newIndexPath = IndexPath(item: 0, section: 0)
        if let index = itemPickerListView.indexPath(for: cell) {
            newIndexPath = index
            if let tbIndex = (superview as? UITableView)?.indexPath(for: self) {
                newIndexPath = IndexPath(item: newIndexPath.row, section: tbIndex.section)
            }
        }

        containerViewController?.startEdit(newIndexPath)
    }
}
