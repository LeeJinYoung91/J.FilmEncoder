//
//  PickerViewController.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/05/08.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PickerViewController: UIViewController {
    enum Mode {
        case DEFAULT
        case SELECT
    }

    enum ItemListType: Int {
        case Video = 0
        case Filter = 1
        case BGM = 2
    }

    @IBOutlet weak var listTableView: UITableView!

    private var recordingFileList = [String]()
    private var videoAssetList = [PHAsset]()
    private var albumTitleList = [String]()
    private var albumVideoList = [String: [PHAsset]]()
    
    var currentStoryboard: String?
    var delegate: SelectorDelegate?
    var mode: Mode = .DEFAULT

    var selectedVideoPathList = [String]()
    var selectIndexPath: [IndexPath] = [IndexPath]()
    var itemType: ItemListType = .Filter

    override func viewDidLoad() {
        loadVideoFileList()
    }

    @IBAction private func backClick() {
        navigationController?.popViewController(animated: true)
    }

    func clearSelectIndex() {
        selectedVideoPathList.removeAll()
        selectIndexPath.removeAll()
    }

    @IBAction private func confirmClick() {
        var videoInfoList = [VideoEditorViewController.LocalVideo]()
        
        for selectIndex in selectIndexPath {
            videoInfoList.append(VideoEditorViewController.LocalVideo(path: recordingFileList[selectIndex.row], thumbnail: VideoUtility.shared.getThumbnailImageFromVideoUrl(url: URL(fileURLWithPath: recordingFileList[selectIndex.row]))))
        }
        
        delegate?.selectVideos(videoInfoList)
        navigationController?.popViewController(animated: true)
    }

    func selectFilter(_ filter: VideoFilterUtility.FILTER_TYPE?) {
        guard let selFilter = filter else {
            return
        }

        delegate?.selectFilter(selFilter)
        navigationController?.popViewController(animated: true)
    }

    func selectBGM(_ bgmPath: String?) {
        guard let bgm = bgmPath else {
            return
        }

        delegate?.selectBGM(bgm)
        navigationController?.popViewController(animated: true)
    }

    private func loadVideoFileList() {
        let fetchOptions = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        
        let allVideos = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        for i in 0 ..< allVideos.count {
            videoAssetList.append(allVideos[i])
            
            PHImageManager.default().requestAVAsset(forVideo: allVideos[i], options: .none) { (asset, videoAudio, nil) in
                if let video = asset as? AVURLAsset {
                    self.recordingFileList.append(video.url.path)
                    if self.recordingFileList.count == self.videoAssetList.count {
                        DispatchQueue.main.async {
                            self.listTableView.delegate = self
                            self.listTableView.dataSource = self
                        }
                    }
                }
            }
            
        }
        
        albumTitleList.append("Album")
        
//        let albumsPhoto:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
//
//        albumsPhoto.enumerateObjects { [weak self] (collection, count, stop) in
//            if let title = collection.localizedTitle, let strongSelf = self {
//                strongSelf.albumTitleList.append(title)
//
//            }
//        }
    }

    private func getFullPath(scene: String, fileName: String) -> String {
        return ""
    }
}

extension PickerViewController: UITableViewDelegate, UITableViewDataSource {
    var headerViewHeight: CGFloat {
        return 30
    }

    var cellHeight: CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listCell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! PickerListCell
        
        listCell.itemType = itemType
        if itemType == .Video {
            listCell.videoList = recordingFileList
        } else if itemType == .BGM {
            listCell.sceneTitle = "BGM List"
            listCell.itemType = ItemListType.BGM
        } else {
            listCell.sceneTitle = "Filter List"
            listCell.itemType = ItemListType.Filter
        }

        listCell.cellHeight = listCell.frame.height
        listCell.containerViewController = self
        listCell.setUp()

        return listCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        var count = 1
        if itemType == .Video {
            count = albumTitleList.count
        }

        return count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerViewHeight))
        header.backgroundColor = UIColor(red: 34/255, green: 38/255, blue: 44/255, alpha: 1)
        let title = UILabel(frame: CGRect(x: 10, y: headerViewHeight/2, width: 100, height: 0))
        title.font = UIFont.systemFont(ofSize: 16)
        title.tintColor = UIColor.white
        if itemType == .Video {
            title.text = albumTitleList[section]
        } else if itemType == .BGM {
            title.text = "BGM"
        } else {
            title.text = "Filter"
        }

        title.sizeToFit()

        title.frame = CGRect(x: 10, y: (headerViewHeight-title.frame.height)/2, width: tableView.frame.width, height: title.frame.height)
        header.addSubview(title)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerViewHeight
    }
}

extension PickerViewController: MenuSelectorDelegate {
    func startEdit(_ indexPath: IndexPath) {
        mode = .SELECT
        for cell in listTableView.visibleCells {
            (cell as? PickerListCell)?.reloadItem()
        }

        if !selectIndexPath.contains(indexPath) {
            selectIndexPath.append(indexPath)
        } else {
            if let index = selectIndexPath.firstIndex(of: indexPath) {
                selectIndexPath.remove(at: index)
            }
        }
        editNavigationBar()
    }

    private func editNavigationBar() {
        let leftItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancel))
        let rightItem = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(confirmClick))

        leftItem.tintColor = UIColor.white

        navigationItem.leftBarButtonItem = leftItem
        navigationItem.rightBarButtonItem = rightItem
    }

    @objc private func cancel() {
        cancelEdit()
    }

    func cancelEdit() {
        clearSelectIndex()
        mode = .DEFAULT

        for cell in listTableView.visibleCells {
            (cell as? PickerListCell)?.reloadItem()
        }
    }

    func deleteItemAt(_ indexPath: IndexPath) {

    }
}
