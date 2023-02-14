//
//  DownloadSession.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-02-03.
//

import Foundation
import UIKit

struct DownloadSession: Codable, Identifiable {
    let id: String
    let startTime, finishTime: Date
    let urlraw: String
    let status, title, playlistTitle: String
    let playlistCount, playlistIndex: Int
    let speed: String
    let isPlaylist: Bool
    let progressPercentage: Double
    let progress: [Progress]
    
    init(){
        id = "1"
        startTime = Date.now
        finishTime = Date.now
        urlraw = "http://www.google.com"
        status = "downloading"
        title = "Title"
        playlistTitle = "PlaylistTitle"
        playlistCount = 1
        playlistIndex = 1
        speed = "1.5MiB/s"
        isPlaylist = true
        progressPercentage = 0.3
        progress = [Progress]()
        
    }
}

// MARK: - Progress
struct Progress: Codable, Identifiable {
    let id : Int
    let title: String
    let status: String
    let tracks : [Track]
    
    init(){
        id = 1
        title = "Title"
        status = "New Video"
        tracks = [Track]()
    }
}

struct Track: Codable, Identifiable {
    let id: Int
    let progress: Double
    let size, speed, eta: String
}

class DownloadSessionModel:ObservableObject{
    @Published var siteIcon : UIImage?
    let siteURL : URL?
    static var siteIcons : [String : UIImage] = [:]
    
    init(_ url: URL?){
        self.siteURL = url
        let host = siteURL!.host!
        if DownloadSessionModel.siteIcons.keys.contains(host){
            self.siteIcon =  DownloadSessionModel.siteIcons[host]
        }else{
            DownloadSessionModel.siteIcons[host] = nil
            Task{
                if let image = await getSiteIcon(host){
                    DispatchQueue.main.sync {
                        self.siteIcon = image
                        DownloadSessionModel.siteIcons[host] = image
                    }
                }
            }
        }
    }
}

private func getSiteIcon(_ site : String) async -> UIImage? {
    let googleAPI = "https://www.google.com/s2/favicons?sz=256&domain="
    do{
        guard let targetURL = URL(string: googleAPI + site) else {throw HTTPClientError.invalidURL}
        let (data, response) = try await URLSession.shared.data(from: targetURL)
        guard let response = response as? HTTPURLResponse else {throw HTTPClientError.invalidHTTPResponse}
        guard (200...299).contains(response.statusCode) else {throw HTTPClientError.HTTPResponseStatusCodeError(receivedCode: response.statusCode)}
        guard let image = UIImage(data: data) else {throw HTTPClientError.UIImageDataError}
        return image
    }catch let error{
        print("DEBUG: error: \(error.localizedDescription)")
        return nil
    }
}

