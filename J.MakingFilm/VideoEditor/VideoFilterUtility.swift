//
//  VideoFilterUtility.swift
//  VideoEditor
//
//  Created by JinYoung Lee on 2018. 6. 27..
//  Copyright © 2018년 JinYoung Lee. All rights reserved.
//

import Foundation
import UIKit
import AVKit

extension AVAsset {
    func setFilter(filterType: VideoFilterUtility.FILTER_TYPE) -> AVVideoComposition {
        return AVVideoComposition(asset: self) { (request) in
            let source = request.sourceImage
            if let output = VideoFilterUtility.shared.getFilteredCIImage(ciImage: source, filterType: filterType) {
                request.finish(with: output, context: nil)
            } else {
                request.finish(with: NSError() as Error)
            }
        }
    }
}

class VideoFilterUtility: NSObject {
    enum FILTER_TYPE: String, Codable {
        case NONE
        case INVERT_COLOR
        case VIGNETTE
        case PHOTO_INSTANT
        case CRYSTALLIZE
        case COMIC
        case BLOOM
        case GLOOM
        case EDGE
        case EDGEWORK
        case HEXAGONAL_PIXELLATE
        case HIGHLIGHTED_SHADOW
        case PIXELLATE

        static let order = [NONE, INVERT_COLOR, VIGNETTE, PHOTO_INSTANT, CRYSTALLIZE, COMIC, BLOOM, GLOOM, EDGE, EDGEWORK, HEXAGONAL_PIXELLATE, HIGHLIGHTED_SHADOW, PIXELLATE]
    }

    static let shared: VideoFilterUtility = VideoFilterUtility()

    func getFilteredCIImage( ciImage: CIImage, filterType: FILTER_TYPE) -> CIImage? {
        switch filterType {
        case .NONE:
            return ciImage.noneEffect()
        case .PHOTO_INSTANT:
            return ciImage.photoInstantEffect()
        case .VIGNETTE:
            return ciImage.vignetteEffect()
        case .INVERT_COLOR:
            return ciImage.invertColorEffect()
        case .HIGHLIGHTED_SHADOW:
            return ciImage.highlightShadowAdjust()
        case .BLOOM:
            return ciImage.bloomEffect()
        case .GLOOM:
            return ciImage.gloomEffect()
        case .COMIC:
            return ciImage.comicEffect()
        case .CRYSTALLIZE:
            return ciImage.crystallizeEffect()
        case .EDGE:
            return ciImage.edgesEffect()
        case .EDGEWORK:
            return ciImage.edgeWorkEffect()
        case .HEXAGONAL_PIXELLATE:
            return ciImage.hexagonalPixellateEffect()
        case .PIXELLATE:
            return ciImage.pixellateEffect()
        }
    }
}
