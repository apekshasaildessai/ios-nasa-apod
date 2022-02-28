//
//  Network.swift
//  NASA-APOD
//
//  Created by Apeksha on 25/02/22.
//

import Foundation
class Network {
    let baseUrl = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&thumbs=true"
    func loadAPODData(dateString: String, completion:@escaping (APODItem?) -> ()) {
         guard let url = URL(string: baseUrl + "&date=" + dateString) else {
             print("Invalid url...")
             return
         }
         URLSession.shared.dataTask(with: url) { data, response, error in
            guard let responseData = data else {
                completion(nil)
                return
            }
            if let apodData = try? JSONDecoder().decode(APODItem.self, from: responseData) {
                completion(apodData)
                return
            }
            completion(nil)
         }.resume()
         
     }
    func loadImageData(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        // Compute a path to the URL in the cache
        let fileCachePath = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                url.lastPathComponent,
                isDirectory: false
            )
        let cacheUrl = URL(fileURLWithPath: fileCachePath.path)
        // If the image exists in the cache,
        // load the image from the cache and exit
        if let data = try?Data(contentsOf: cacheUrl) {
            completion(data, nil)
            return
        }
        // If the image does not exist in the cache,
        // download the image to the cache
        download(url: url, toFile: cacheUrl) { (error) in
            if let data = try?Data(contentsOf: cacheUrl) {
                completion(data, nil)
                return
            }
            completion(nil, error)
        }
    }
    func download(url: URL, toFile file: URL, completion: @escaping (Error?) -> Void) {
        // Download the remote URL to a file
        let task = URLSession.shared.downloadTask(with: url) {
            (tempURL, response, error) in
            // Early exit on error
            guard let tempURL = tempURL else {
                completion(error)
                return
            }

            do {
                // Remove any existing document at file
                if FileManager.default.fileExists(atPath: file.path) {
                    try FileManager.default.removeItem(at: file)
                }

                // Copy the tempURL to file
                try FileManager.default.copyItem(
                    at: tempURL,
                    to: file
                )

                completion(nil)
            }

            // Handle potential file system errors
            catch let fileError {
                completion(error)
            }
        }

        // Start the download
        task.resume()
    }
}
