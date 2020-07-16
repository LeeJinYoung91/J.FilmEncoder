//
//  VideoEditorViewController.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/04/08.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
import AVKit

class VideoEditorViewController: UIViewController {
    enum TabBar_Item_Type {
        case Filter
        case BGM
    }

    enum VideoCompositionType {
        case Filter
        case BGM
        case Text
    }

    struct AssetInfomation: Codable {
        var originPath: String
        var startTime: Double?
        var endTime: Double?

        init(_ path: String) {
            originPath = path
        }

        mutating func setTime(startTime: CMTime, endTime: CMTime) {
            self.startTime = startTime.seconds
            self.endTime = endTime.seconds
        }
        var Asset: AVURLAsset {
            return AVURLAsset(url: URL(fileURLWithPath: originPath))
        }
    }

    struct LocalVideo {
        var videoPath: String
        var thumbnail: UIImage?

        init(path: String, thumbnail: UIImage?) {
            self.videoPath = path
            self.thumbnail = thumbnail
        }
    }

    struct CurrentVideoEncodeInfomation {
        var filter: VideoFilterUtility.FILTER_TYPE?
        var bgmPath: String?
    }

    struct CurrentSelectionView {
        var target: UIView
        var rangeSlider: RangeSlider?

        init(_ targetView: UIView) {
            target = targetView
        }
    }

    @IBOutlet weak var videoView: VideoView?
    @IBOutlet weak var frameContainer: UIView!
    @IBOutlet weak var videoTitleInputField: TitleInputTextField!
    @IBOutlet weak var timelineScrollView: UIScrollView!
    @IBOutlet weak var timeStamp: UILabel!

    @IBOutlet weak var filterEncodeDataView: EncodeDataView?
    @IBOutlet weak var bgmEncodeDataView: EncodeDataView?

    @IBOutlet weak var editContainerView: UIView!
    @IBOutlet weak var timeContainerView: UIView!
    @IBOutlet weak var indicatorCollectionView: TimelineIndicatorCollectionView!
    @IBOutlet var timelineScrollViewWidthConstraints: NSLayoutConstraint!

    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var bgmButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var movieButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var encodeButton: UIButton!

    private final let eachThumbnailWidth: CGFloat = 40
    private final let spaceBetweenCells: CGFloat = 3
    private final let numCellsPerRow: CGFloat = 3

    private var durationList: [CGFloat] = [CGFloat]()
    private var currentAssetIndex: Int = 0
    private var playingLength: CGFloat = 0

    private var saveAssetsInfo: [AssetInfomation] = [AssetInfomation]()
    private let filterGroup = DispatchGroup()
    private let cropGroup = DispatchGroup()
    private var totalFrameWidth: CGFloat = 0
    private var totalDuration: CGFloat = 60
    private var needUpdateSlider: Bool = false
    private var lastSavedTimelinePosition: CGFloat = 0

    private var encodeInformation: CurrentVideoEncodeInfomation?
    private var selectionViewList: [UIView] = [UIView]()

    private var mainFolderPath = ""
    private var currentSelectView: CurrentSelectionView?

    private var startDragging: Bool = false
    private var editView: EditModeView?

    private var isInit: Bool = false
    private var startInsetX: CGFloat = 0

    deinit {
        videoView?.clearData()
    }

    private func setUpData(_ data: LocalVideo) {
        let splitPath = data.videoPath.split(separator: "/")
        mainFolderPath = splitPath[splitPath.count-3].description

        saveAssetsInfo.append(AssetInfomation(data.videoPath))
    }

    override func viewDidLoad() {
        filterEncodeDataView?.dataType = .Filter
        bgmEncodeDataView?.dataType = .BGM

        filterEncodeDataView?.delegate = self
        bgmEncodeDataView?.delegate = self

        navigationController?.isNavigationBarHidden = true
        loadPreviousSavedData()
        timelineScrollView.delegate = self
        timelineScrollView.isUserInteractionEnabled = true
        lastSavedTimelinePosition = timelineScrollView.bounds.width / 2
        enableAllButtons(false)
    }

    private func enableAllButtons(_ enable: Bool) {
        filterButton.isEnabled = enable
        bgmButton.isEnabled = enable
        playButton.isEnabled = enable
        textButton.isEnabled = enable
        encodeButton.isEnabled = enable
    }

    override func viewWillAppear(_ animated: Bool) {
        if !isInit {
            isInit = true
            startInsetX = timeContainerView.frame.width/2 - eachThumbnailWidth/2
            indicatorCollectionView.contentInset = UIEdgeInsets(top: 0, left: startInsetX, bottom: 0, right: timeContainerView.frame.width/2)
        }
    }

    private func loadPreviousSavedData() {
        let savedOption = VideoEncodingSettingOptions(key: "TempSaveOption")
        if let saveInfo = savedOption.getSetting() {
            var videoList = [LocalVideo]()
            if let infoList = saveInfo.ImportAssetInfomation {
                for info in infoList {
                    let splitArr = info.originPath.split(separator: "/")
                    let newPathForDocument = DocumentPath.appending(String(format: "/TempVideo/%@", String(format: "%@/%@/%@", String(splitArr[splitArr.count-3]), String(splitArr[splitArr.count-2]), String(splitArr[splitArr.count-1]))))

                    let asset = AVURLAsset(url: URL(fileURLWithPath: newPathForDocument))
                    var assetInfo = AssetInfomation(asset.url.path)

                    if let start = info.startTime, let end = info.endTime {
                        assetInfo.setTime(startTime: CMTime(seconds: start, preferredTimescale: asset.duration.timescale), endTime: CMTime(seconds: end, preferredTimescale: asset.duration.timescale))
                    }
                    saveAssetsInfo.append(assetInfo)
                    videoList.append(LocalVideo(path: info.Asset.url.path, thumbnail: VideoUtility.shared.getThumbnailImageFromVideoUrl(url: URL(fileURLWithPath: newPathForDocument))))
                }
            }

            encodeInformation = CurrentVideoEncodeInfomation()
            if let bgm = saveInfo.AudioPath {
                selectBGM(bgm)
            }

            if let filter = saveInfo.Filter {
                encodeInformation?.filter = filter
                selectFilter(filter)
            }

            setTimeline()
            videoView?.image = videoList.first?.thumbnail
            if saveAssetsInfo.count > 0 {
                videoView?.setVideoInfo(saveAssetsInfo.first)
                if let startTime = saveAssetsInfo.first?.startTime {
                    videoView?.seekVideo(toPos: CGFloat(startTime))
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        let optionSet = VideoEncodingSettingOptions(key: "TempSaveOption")
        if let information = encodeInformation {
            optionSet.setFilter(information.filter)
            optionSet.setAudioPath(information.bgmPath)
        }

        optionSet.setVideos(saveAssetsInfo)
        optionSet.saveCurrentSetting()
        editContainerView.isUserInteractionEnabled = false
    }

    private func moveValue(_ value: CGFloat) {
        func setIndex(_ index: Int) {
            videoView?.setVideoInfo(saveAssetsInfo[index])
            currentAssetIndex = index
        }

        if saveAssetsInfo.count == 0 || durationList.count == 0 {
            return
        }

        var totalD: CGFloat = 0
        for i in 0..<currentAssetIndex {
            totalD += durationList[i]
        }

        var startTime: CGFloat = 0
        if let startValue = saveAssetsInfo[currentAssetIndex].startTime {
            startTime = CGFloat(startValue)
        }

        if value - totalD < durationList[currentAssetIndex], value - totalD > 0 {
            videoView?.seekVideo(toPos: value - totalD + startTime)
            return
        }

        var startIndex = 0

        if value == durationList.last || value == 0 {
            return
        }

        var duration = durationList[startIndex]

        while value > duration {
            startIndex += 1
            duration += durationList[startIndex]
        }

        setIndex(startIndex)
    }

    func setTimeline() {
        func removeExistingData() {
            for thumbnail in frameContainer.subviews {
                if thumbnail.isKind(of: UIButton.self) {
                    thumbnail.removeFromSuperview()
                }
            }
        }

        durationList.removeAll()
        needUpdateSlider = false
        removeExistingData()
        totalFrameWidth = 0
        totalDuration = 0
        enableAllButtons(false)
        currentAssetIndex = 0

        lastSavedTimelinePosition = timelineScrollView.bounds.width / 2
        timeStamp.text = "00:00"

        var count = 0

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            for info in strongSelf.saveAssetsInfo {
                strongSelf.setTimeline(info.Asset, index: count, startPosition: strongSelf.lastSavedTimelinePosition)
                count += 1
            }

            strongSelf.timelineScrollViewWidthConstraints.constant = strongSelf.totalFrameWidth + strongSelf.timelineScrollView.bounds.width
        }
    }

    private func setTimeline(_ asset: AVAsset, index: Int, startPosition: CGFloat) {
        var timeDuration = CGFloat(asset.duration.seconds)

        var startTime: Double = 0
        if saveAssetsInfo.count > index, let start = saveAssetsInfo[index].startTime, let end = saveAssetsInfo[index].endTime {
            timeDuration = CGFloat(end - start)
            startTime = start
        }

        if index < durationList.count {
            durationList[index] = timeDuration
        } else {
            durationList.append(timeDuration)
        }

        totalDuration += timeDuration

        lastSavedTimelinePosition = createAssetThumbnail(asset, startPos: startPosition, startTime: startTime, duration: timeDuration, index: index)

        timelineScrollViewWidthConstraints.constant = totalFrameWidth + timelineScrollView.bounds.width
        enableAllButtons(true)
    }

    private func createAssetThumbnail(_ asset: AVAsset, startPos: CGFloat = 0, startTime: Double, duration: CGFloat, index: Int) -> CGFloat {
        let assetImgGenerate: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = CMTime.zero
        assetImgGenerate.requestedTimeToleranceBefore = CMTime.zero

        var startTime = startTime
        var startXPosition: CGFloat = startPos
        var anchorXPos: CGFloat = 0
        let maxLength = "\(asset.duration)" as NSString

        var num = round(duration)
        if num == 0 {
            num = 1
        }

        var totalWidth: CGFloat = 0
        let selectableImageContainer = UIButton()
        for _ in 0...Int(num)-1 {
            let thumbImage = UIImageView()
            do {
                let time: CMTime = CMTimeMakeWithSeconds(Float64(startTime), preferredTimescale: Int32(maxLength.length))
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: img)
                thumbImage.image = image
            } catch
                let error as NSError {
                    print("Image generation failed with error \(error.localizedDescription)")
            }
            totalWidth += eachThumbnailWidth

            startTime = startTime + 1
            thumbImage.isUserInteractionEnabled = false
            selectableImageContainer.addSubview(thumbImage)
            selectableImageContainer.backgroundColor = UIColor.black
            thumbImage.snp.makeConstraints { (maker) in
                maker.leading.equalTo(anchorXPos)
                maker.width.equalTo(eachThumbnailWidth)
                maker.height.equalTo(frameContainer.frame.height)
            }

            selectableImageContainer.layoutIfNeeded()
            anchorXPos += eachThumbnailWidth
            startXPosition = startXPosition + eachThumbnailWidth
        }

        selectableImageContainer.addTarget(self, action: #selector(selectVideoTimeline(_:)), for: .touchUpInside)
        selectableImageContainer.tag = index
        if let selView = currentSelectView {
            if index == selView.target.tag {
                selectableImageContainer.setHighligtedView()
            }
        }

        frameContainer.addSubview(selectableImageContainer)
        selectableImageContainer.frame = CGRect(x: anchorXPos, y: 0, width: totalWidth, height: selectableImageContainer.bounds.height)
        selectionViewList.append(selectableImageContainer)
        selectableImageContainer.snp.makeConstraints { (maker) in
            maker.leading.equalTo(startPos)
            maker.width.equalTo(totalWidth)
            maker.height.equalTo(frameContainer.frame.height)
        }

        totalFrameWidth += totalWidth
        return startXPosition
    }

    @objc private func selectVideoTimeline(_ selectView: UIView) {
        for v in selectionViewList {
            v.UnSelect()
        }

        editView?.closeEdit()

        selectView.setHighligtedView()
        editView = Bundle.main.loadNibNamed("EditModeView", owner: self, options: nil)?.first as? EditModeView
        editView?.frame = CGRect(x: 0, y: 0, width: editContainerView.frame.width, height: editContainerView.frame.height)

        editContainerView.addSubview(editView!)
        editContainerView.isUserInteractionEnabled = true
        editView?.delegate = self
        currentSelectView = CurrentSelectionView(selectView)
    }

    private func setFilter(_ filterType: VideoFilterUtility.FILTER_TYPE) {
        if encodeInformation == nil {
            encodeInformation = CurrentVideoEncodeInfomation()
        }

        encodeInformation?.filter = filterType
        videoView?.setFilter(filterType)
    }

    func setNextVideo() {
        if currentAssetIndex == saveAssetsInfo.count-1 {
            videoView?.pauseVideo()
            return
        }

        currentAssetIndex = (saveAssetsInfo.count-1 == currentAssetIndex) ? 0 : currentAssetIndex+1
        videoView?.setVideoInfo(saveAssetsInfo[currentAssetIndex])
    }

    func onPeriod(_ second: Double) {
        var previousDuration: CGFloat = 0
        for i in 0..<currentAssetIndex {
            previousDuration += durationList[i]
        }

        UIView.animate(withDuration: 0.05, delay: 0, options: .curveLinear, animations: {
            self.timelineScrollView.contentOffset = CGPoint(x: self.totalFrameWidth * (CGFloat(second) + previousDuration) / self.totalDuration, y: 0)
        }, completion: nil)
    }

    @IBAction func startPlay() {
        guard videoView != nil else {
            return
        }

        if videoView!.isAutoPlay {
            videoView?.isAutoPlay = false
            videoView?.pauseVideo()
        } else {
            videoView?.isAutoPlay = true
            videoView?.playVideo()
        }
    }

    @IBAction func startEncoding() {
        var mergeVideoList = [Int: AVAsset]()
        var count = 0
        var cropEncodeIndex = 0
        var filterEncodeIndex = 0

        func getIndexFromFilePath(_ filePath: URL) -> Int {
            let split = filePath.absoluteString.split(separator: "/")
            let fileName = split.last
            let prev = fileName?.split(separator: ".").first
            let indexString = prev?.split(separator: "-").last!
            let fileIndex = Int(indexString ?? "0")!
            return fileIndex
        }

        cropGroup.enter()
        filterGroup.enter()

        // MARK: Crop Video
        var cropList = [Int: AVAsset]()
        for data in saveAssetsInfo {
            if let startTime = data.startTime, let endTime = data.endTime {
                data.Asset.exportVideoInTimeSection(fileName: "Crop-\(cropEncodeIndex).mov", timeRange: CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: data.Asset.duration.timescale), end: CMTime(seconds: endTime, preferredTimescale: data.Asset.duration.timescale))) { (_, fileURL) in
                    if let url = fileURL {
                        cropList[getIndexFromFilePath(url)] = AVURLAsset(url: url)
                    }

                    if cropList.count == self.saveAssetsInfo.count {
                        self.cropGroup.leave()
                    }
                }
            } else {
                cropList[cropEncodeIndex] = data.Asset
                if cropList.count == saveAssetsInfo.count {
                    self.cropGroup.leave()
                }
            }
            cropEncodeIndex += 1
        }

        // MARK: Filtering Video
        cropGroup.notify(queue: .main) {
            let cropSortedList = cropList.sorted {
                return $0.key < $1.key
            }

            var croppedAssetList = [AVAsset]()
            for video in cropSortedList {
                croppedAssetList.append(video.value)
            }

            for croppedAsset in croppedAssetList {
                if self.encodeInformation?.filter != nil {
                    croppedAsset.saveCurrentItemWithComposition(croppedAsset.setFilter(filterType: self.encodeInformation!.filter!), name: "Filtertemp-\(count)") { (_, filterTempPath, _) in
                        if let result = filterTempPath {
                            mergeVideoList[getIndexFromFilePath(result)] = AVURLAsset(url: result)
                        }

                        if filterEncodeIndex == self.saveAssetsInfo.count-1 {
                            self.filterGroup.leave()
                        }

                        filterEncodeIndex += 1
                    }
                } else {
                    mergeVideoList[count] = croppedAsset
                    if filterEncodeIndex == self.saveAssetsInfo.count-1 {
                        self.filterGroup.leave()
                    }
                    filterEncodeIndex += 1
                }

                count += 1
            }
        }

        // MARK: Merge Audio & Video
        filterGroup.notify(queue: .main) {
            let sortList = mergeVideoList.sorted {
                return $0.key < $1.key
            }

            var assetList = [AVAsset]()
            for video in sortList {
                assetList.append(video.value)
            }

            VideoUtility.shared.mergedVideo(videos: assetList, saveFolder: "SaveVideo", videoTitle: self.videoTitleInputField.text, successListener: { (pathURL) in
                if let audioFilePath = self.encodeInformation?.bgmPath {
                    VideoUtility.shared.mergeAudioWithURL(videoUrl: pathURL, audioPath: audioFilePath, savePath: pathURL) { (success, resultURL) in
                        print("success? : \(success), resultPath: \(resultURL)")
                    }
                } else {
                    print("resultPath: \(pathURL)")
                }
            }) { (err) in
                print(err?.localizedDescription ?? "error")
            }
        }
    }

    @IBAction func moveToItemPicker(_ button: UIButton) {
        if let type = PickerViewController.ItemListType.init(rawValue: button.tag) {
            if let videoSelector = storyboard?.instantiateViewController(identifier: "pickerViewController") as? PickerViewController {
                videoSelector.delegate = self
                videoSelector.itemType = type
                videoView?.pauseVideo()
                navigationController?.pushViewController(videoSelector, animated: true)
            }
        }
    }

    @IBAction private func closePage() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func InputText() {

    }
}

extension VideoEditorViewController: SelectorDelegate {
    private func getTotalVideoDuration() -> CGFloat {
        var totalDuration: CGFloat = 0

        for video in saveAssetsInfo {
            totalDuration += CGFloat(video.Asset.duration.seconds)
        }
        return totalDuration
    }

    private func canAddNewVideos(addAssets: [AVURLAsset]) -> Bool {
        var totalDuration = getTotalVideoDuration()
        for video in addAssets {
            totalDuration += CGFloat(video.duration.seconds)
        }

        return totalDuration < 60
    }

    func selectVideos(_ videoInfos: [VideoEditorViewController.LocalVideo]) {
        var addVideos = [AVURLAsset]()
        for video in videoInfos {
            addVideos.append(AVURLAsset(url: URL(fileURLWithPath: video.videoPath)))
        }

        if !canAddNewVideos(addAssets: addVideos) {
            return
        }

        for info in videoInfos {
            setUpData(info)
            setTimeline(AVURLAsset(url: URL(fileURLWithPath: info.videoPath)), index: saveAssetsInfo.count-1, startPosition: lastSavedTimelinePosition)
        }

        videoView?.setVideoInfo(saveAssetsInfo.first)
        needUpdateSlider = true
    }

    func selectFilter(_ filter: VideoFilterUtility.FILTER_TYPE) {
        filterEncodeDataView?.Title = filter.rawValue
        setFilter(filter)
        if encodeInformation == nil {
            encodeInformation = CurrentVideoEncodeInfomation()
        }

        encodeInformation?.filter = filter
    }

    func selectBGM(_ bgmPath: String) {
        let pathList = bgmPath.split(separator: "/")
        if let fileName = pathList.last?.split(separator: ".").first {
            bgmEncodeDataView?.Title = String(fileName)
        }
        if encodeInformation == nil {
            encodeInformation = CurrentVideoEncodeInfomation()
        }

        encodeInformation?.bgmPath = bgmPath
    }
}

extension VideoEditorViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startDragging = true
        videoView?.pauseVideo()
        videoView?.isUserInteractionEnabled = false
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        startDragging = true
        onScroll()
        videoView?.isUserInteractionEnabled = !startDragging
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startDragging = false
        onScroll()
        videoView?.isUserInteractionEnabled = !startDragging
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startDragging = false
        onScroll()
        videoView?.isUserInteractionEnabled = !startDragging
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScroll()
    }

    private func onScroll() {
        indicatorCollectionView.contentOffset = CGPoint(x: timelineScrollView.contentOffset.x - startInsetX, y: 0)
        let percentage = (timelineScrollView.contentOffset.x) / totalFrameWidth
        var second: CGFloat = 0
        if percentage > 0, percentage < 1 {
            second = totalDuration * percentage
        } else if percentage >= 1 {
            second = totalDuration
        }

        displayTimeStamp(second)

        guard startDragging else {
            return
        }

        moveValue(second)
    }

    private func displayTimeStamp(_ second: CGFloat) {
        let strSecond = String(format: "%f", second)

        var sec = "00"
        if let last = strSecond.split(separator: ".").first?.description {
            sec = last
            if Int(sec)! < 10 {
                sec = String(format: "0%@", sec)
            }
        }

        var miliSecond = "00"
        if let last = strSecond.split(separator: ".").last?.description {
            miliSecond = last
            miliSecond.removeSubrange(Range(NSRange(location: 1, length: last.count-2), in: last.description)!)
        }

        let returnValue = String(format: "%@:%@", sec, miliSecond)

        timeStamp.text = returnValue
    }
}

extension VideoEditorViewController: EditDelegate {
    func close() {
        currentSelectView?.target.UnSelect()
        editContainerView.isUserInteractionEnabled = false
        currentSelectView = nil
    }

    func tryCutOff() {
        if let currentView = currentSelectView?.target {
            var startSec: Double = 0
            var currentVideoDuration: Double = saveAssetsInfo[currentView.tag].Asset.duration.seconds

            if let startTime: Double = saveAssetsInfo[currentView.tag].startTime {
                startSec = startTime
            }

            if let endTime: Double = saveAssetsInfo[currentView.tag].endTime {
                let endDiff = currentVideoDuration - endTime
                currentVideoDuration -= endDiff
            }

            currentSelectView?.rangeSlider = currentView.createSlider(lowerValue: startSec, maxValue: currentVideoDuration)
        }
    }

    func delete() {
        timeStamp.text = "00:00"
        timelineScrollViewWidthConstraints.constant = 0
        timelineScrollView.contentOffset = CGPoint.zero
        videoView?.clearData()

        if let targetView = currentSelectView {
            saveAssetsInfo.remove(at: targetView.target.tag)
            targetView.target.UnSelect()
            selectionViewList.remove(at: targetView.target.tag)
            durationList.remove(at: targetView.target.tag)
            targetView.target.removeFromSuperview()
            editView?.closeEdit()
            setTimeline()
        }

        videoView?.setVideoInfo(saveAssetsInfo.first)
    }

    func cutOff() {
        let startSec: Double = currentSelectView!.rangeSlider!.lowerValue
        let endSec: Double = currentSelectView!.rangeSlider!.upperValue

        saveAssetsInfo[currentSelectView!.target.tag].setTime(startTime: CMTime(seconds: startSec, preferredTimescale: saveAssetsInfo[currentSelectView!.target.tag].Asset.duration.timescale), endTime: CMTime(seconds: endSec, preferredTimescale: saveAssetsInfo[currentSelectView!.target.tag].Asset.duration.timescale))

        timelineScrollView.contentOffset = CGPoint.zero
        videoView?.setVideoInfo(saveAssetsInfo[currentSelectView!.target.tag])
        setTimeline()
        editView?.closeEdit()
    }

    func locateToMainEditPage() {
        if let targetView = currentSelectView?.target {
            targetView.removeSlider()
        }
    }
}

extension VideoEditorViewController: dataViewDelegate {
    func deleteCurrentEncodeData(type: VideoCompositionType?) {
        guard let t = type else {
            return
        }

        switch t {
        case .Filter:
            removeFilter()
            return
        case .BGM:
            removeBGM()
            return
        default:
            return
        }
    }

    private func removeFilter() {
        videoView?.setFilter(.NONE)
        encodeInformation?.filter = nil
    }

    private func removeBGM() {
        encodeInformation?.bgmPath = nil
    }
}
