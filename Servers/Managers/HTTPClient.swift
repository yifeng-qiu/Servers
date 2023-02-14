//
//  HTTPClient.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-02-06.
//

import Foundation
import SwiftUI

enum HTTPClientError : Error, LocalizedError{
    case ServiceUndefined
    case invalidURL
    case ServerError
    case invalidHTTPResponse
    case HTTPResponseStatusCodeError(receivedCode : Int)
    case JSONDecodingError
    case UIImageDataError
    case DataCorrupted
    case unknown(Error)
    
    var errorDescription: String?{
        switch self{
        case .ServiceUndefined: return "Configure share service URLs first!"
        case .invalidURL: return "The provided URL is invalid"
        case .ServerError: return "Unable to connect to the server"
        case .invalidHTTPResponse: return "Received invalid HTTP response."
        case .HTTPResponseStatusCodeError(let code): return "Received unexpected HTTP response code \(code)"
        case .JSONDecodingError: return "Unable to decode the returned JSON data"
        case .UIImageDataError: return "Unable to decode received data into UIImage"
        case .DataCorrupted: return "The received data was corrupted"
        case .unknown(let error): return error.localizedDescription
        }
    }
}

class HTTPClient{
    private var persistenceController : PersistenceController
    private var service : ShareExtension?
    
    init(){
        persistenceController = PersistenceController.shared
        let request = ShareExtension.fetchRequest()
        let results = try? persistenceController.container.viewContext.fetch(request)
        service = results?.first
    }
    
    static func validateServer(url: String) async -> String {
        do{
            guard let baseURL  = URL(string: url) else {throw HTTPClientError.invalidURL}
            let (data, response) = try await URLSession.shared.data(from: baseURL)
            guard let response = response as? HTTPURLResponse else {throw HTTPClientError.invalidHTTPResponse}
            guard (200...299).contains(response.statusCode) else {throw HTTPClientError.HTTPResponseStatusCodeError(receivedCode: response.statusCode)}
            guard let ret = NSString(data: data, encoding: NSUTF8StringEncoding) else {throw HTTPClientError.DataCorrupted}
            return "Server responded with: \n\(ret)"
        }catch let error{
            return "Error while trying to validate the entered URL:\(url)\n The error was: \n \(error.localizedDescription)"
        }
    }
    
    func checkConnectivity() async ->Bool {
        do{
            guard let baseURL  = service?.baseURL else {throw HTTPClientError.ServiceUndefined}
            guard let baseURL = URL(string: baseURL) else {throw HTTPClientError.invalidURL}
            let (_, response) = try await URLSession.shared.data(from: baseURL)
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print("DEBUG: server response is outside 200 to 299.")
                return false}
            
            return true
        }catch let error{
            print("DEBUG: error while trying to connect to the server: \(error.localizedDescription)")
            return false
        }
    }
    
    @MainActor
    func fetchActiveDownloads() async throws -> [DownloadSession]?{
        
        do{
            guard let fetchDownloadsURL  = service?.fetchDownloadsURL else {throw HTTPClientError.ServiceUndefined}
            guard let fetchDownloadsURL = URL(string: fetchDownloadsURL) else {throw HTTPClientError.invalidURL}
            let (data, response) = try await URLSession.shared.data(from: fetchDownloadsURL)
            guard let response = response as? HTTPURLResponse else {throw HTTPClientError.invalidHTTPResponse}
            guard response.statusCode == 200 else { throw HTTPClientError.HTTPResponseStatusCodeError(receivedCode: response.statusCode)}
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let Sessions = try? decoder.decode([DownloadSession].self, from: data) else {throw HTTPClientError.JSONDecodingError}
            return Sessions
        }catch let error{
            throw error
        }
    }
    
    func pauseResumeDownload(_ shaKey: String){
        Task{
            do{
                guard let pauseResumeURL  = service?.pauseResumeURL else {throw HTTPClientError.ServiceUndefined}
                guard let pauseResumeURL = URL(string: pauseResumeURL) else {throw HTTPClientError.invalidURL}
                let queryURL = pauseResumeURL.appendingPathComponent(shaKey)
                var request = URLRequest(url: queryURL)
                request.httpMethod = "UPDATE"
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{return}
                if let ret = String(data: data, encoding: .utf8){
                    print("DEBUG: the server responded with \(ret)\n")
                }
            }catch let error{
                print("DEBUG: error while trying to connect to the server : \(error.localizedDescription)")
            }
        }
    }
    
    func cancelDownload(_ shaKey: String) {
        Task{
            guard let deleteURL  = service?.deleteURL else {throw HTTPClientError.ServiceUndefined}
            guard let deleteURL = URL(string: deleteURL) else {throw HTTPClientError.invalidURL}
            let queryURL = deleteURL.appendingPathComponent(shaKey)
            var request = URLRequest(url: queryURL)
            request.httpMethod = "DELETE"
            do{
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{return}
                if let ret = String(data: data, encoding: .utf8){
                    print("DEBUG: the server responded with \(ret)\n")
                }
            }catch let error{
                print("DEBUG: error while trying to connect to the server : \(error.localizedDescription)")
            }
        }
        
    }
    
    func postToMyServer(_ formData : [String:String])async -> Bool{
        do{
            guard let postURL  = service?.postURL else {throw HTTPClientError.ServiceUndefined}
            guard let postURL = URL(string: postURL) else {throw HTTPClientError.invalidURL}
            var request = URLRequest(url: postURL)
            request.httpMethod = "POST"
            var bodyData = ""
            for (key, value) in formData{
                guard value != "" else {continue}
                let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                bodyData += "\(escapedKey)=\(escapedValue)&"
            }
            request.httpBody = bodyData.data(using: .utf8, allowLossyConversion: false)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {throw HTTPClientError.invalidHTTPResponse}
            guard response.statusCode == 200 else {throw HTTPClientError.HTTPResponseStatusCodeError(receivedCode: response.statusCode)}
            guard let ret = NSString(data: data, encoding: NSUTF8StringEncoding) else {throw HTTPClientError.DataCorrupted}
            print("DEBUG: server responded with \(ret)")
            return true
        }catch let error{
            print("DEBUG: error is \(error.localizedDescription)")
            return false
        }
    }
}
