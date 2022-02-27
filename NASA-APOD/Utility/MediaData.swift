//
//  MediaData.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
struct MediaAsset {
    var mediaType: APODMediaType?
    var thumbnailUrl: String?
    var hdUrl: String?
    var videoUrl: String?
    init(mediaType: APODMediaType, thumbnailUrl: String, hdUrl: String, videoUrl: String) {
        self.mediaType = mediaType
        self.thumbnailUrl = thumbnailUrl
        self.hdUrl = hdUrl
        self.videoUrl = videoUrl
    }
}
