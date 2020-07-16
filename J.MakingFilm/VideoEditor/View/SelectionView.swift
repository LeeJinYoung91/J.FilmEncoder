//
//  SelectionView.swift
//  J.MakingFilm
//
//  Created by JinYoung Lee on 2020/05/07.
//  Copyright © 2020 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var backgroundViewTag: Int {
        return 500
    }

    var sliderViewTag: Int {
        return 100
    }

    var cutViewTag: Int {
        return 200
    }

    func createSlider(lowerValue: Double = 0, maxValue: Double = 0) -> RangeSlider {
        func setSlider() -> RangeSlider {
            let slider = RangeSlider(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
            slider.tag = sliderViewTag
            slider.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
            slider.thumbTintColor = UIColor.white
            slider.minimumValue = lowerValue
            slider.lowerValue = lowerValue
            slider.maximumValue = maxValue
            slider.upperValue = maxValue
            addSubview(slider)
            return slider
        }

        return setSlider()
    }

    func setHighligtedView() {
        let highlightView = UIImageView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        highlightView.image = selImage
        highlightView.tag = backgroundViewTag
        addSubview(highlightView)
    }

    func UnSelect() {
        for sView in subviews {
            if sView.tag == backgroundViewTag || sView.tag == sliderViewTag || sView.tag == cutViewTag {
                sView.removeFromSuperview()
            }
        }
    }

    func removeSlider() {
        for bView in subviews {
            if bView.tag == sliderViewTag || bView.tag == cutViewTag {
                bView.removeFromSuperview()
                return
            }
        }
    }

    private func removeBackgroundView(_ viewTag: Int = 500) {
        for bView in subviews {
            if bView.tag == viewTag {
                bView.removeFromSuperview()
                return
            }
        }
    }

    @objc func sliderValueChange() {
        var slider: RangeSlider?
        for sV in subviews {
            if sV.tag == sliderViewTag {
                slider = sV as? RangeSlider
            }
        }

        guard let rangeSlider = slider else {
            return
        }

        removeBackgroundView(cutViewTag)

        let width = rangeSlider.upperFrame.origin.x - rangeSlider.lowerFrame.origin.x - rangeSlider.upperFrame.width
        let cutBackView = UIImageView(frame: CGRect(x: rangeSlider.lowerFrame.origin.x + rangeSlider.upperFrame.width, y: 0, width: width, height: frame.height))
        cutBackView.image = cutImage
        cutBackView.tag = cutViewTag
        addSubview(cutBackView)
    }
}

protocol SliderDelegate {
    func sliderValueChange(slider: RangeSlider)
}
