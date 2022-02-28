//
//  APODItem.swift
//  NASA-APOD
//
//  Created by Apeksha on 25/02/22.
//

import Foundation
struct APODItem: Codable {
  var date: String?
  var hdurl: String?
  var url: String?
  var title: String?
  var explanation: String?
  var media_type: String?
  var thumbnail_url: String?
    
}
extension APODEntity {
    func getMediaType() -> APODMediaType {
          if let apodMediaType = APODMediaType.init(rawValue: mediaType ?? "") {
              return apodMediaType
          }
          return APODMediaType.unknown
    }
   
   func getThumbnailUrl() -> String? {
      let apodMediaType = getMediaType()
      switch apodMediaType {
      case .image:
          return url
      case .video:
          return thumbnail
      default:
          return nil
      }
   }
    func dateString() -> String? {
        guard let apodDate = date else {
            return nil
        }
        return YearMonthDay(localTime: apodDate).description
    }
}

