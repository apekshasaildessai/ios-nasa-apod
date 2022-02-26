//
//  Utilities.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
public enum APODErrors: Error {
  case invalidDate(String)
  case missingURL
  case emptyResponse
  case failureResponse(statusCode: Int)
  case invalidYouTubeVideo(String)
  case invalidVimeoVideo(String)
  case invalidImage
  case unsupportedAsset
  case fileCoordinationFailed
}
