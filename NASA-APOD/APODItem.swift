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

