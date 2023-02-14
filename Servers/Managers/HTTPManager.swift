//
//  HTTPManager.swift
//  HomeApp
//
//  Created by Yifeng Qiu on 2023-01-28.
//

import Foundation

class HTTPManager : ObservableObject{
    
    @Published var serverOnline : Bool = false
    let serverAddress: URL?
    static let session = URLSession.shared
    
    init(_ addr: URL?){
        self.serverAddress = addr
        print("DEBUG: HTTPManager initialized")
        print("DEBUG: Checking server status")
        checkConnectivity()
    }
    
    func checkConnectivity(){
        guard let url = self.serverAddress else{
            print("DEBUG: invalid URL")
            return
        }
        Task(priority: .high) {
            let (_, response) = try await HTTPManager.session.data(from: url)
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                print("DEBUG: server response is outside 200 to 299.")
                return}
            DispatchQueue.main.sync {
                self.serverOnline = true
            }
            print("DEBUG: server is online")
        }
        
    }
    
    func postToMyServer(_ formData : [String:String]){
        guard self.serverOnline else {
            print("DEBUG: the server does not appear to be reachable before posting.")
            return
        }
        var request = URLRequest(url: self.serverAddress!)
        request.httpMethod = "POST"
        var bodyData = ""
        for (key, value) in formData{
            guard value != "" else {continue}
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            bodyData += "\(escapedKey)=\(escapedValue)&"
            
        }
        request.httpBody = bodyData.data(using: .utf8, allowLossyConversion: false)
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request, completionHandler:{
            data, response, error in
            if error != nil {
                print("DEBUG: \(error!.localizedDescription)")
            }else{
                let ret = NSString(data: data!, encoding:NSUTF8StringEncoding)
                print("DEBUG: the server responded with \(ret!)")
            }
        })
        task.resume()
    }
    
    func pauseResumeDownload(_ shaKey: String){
        guard let url = self.serverAddress else{
            print("DEBUG: invalid URL")
            return
        }
        
        let newURL = url.appendingPathComponent("pause/" + shaKey)
        print("DEBUG: the URL to pause and resume download is \(newURL.absoluteString)")
        var request = URLRequest(url: newURL)
        request.httpMethod = "UPDATE"
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request, completionHandler:{
            data, response, error in
            if error != nil {
                print("DEBUG: \(error!.localizedDescription)")
            }else{
                let ret = NSString(data: data!, encoding:NSUTF8StringEncoding)
                print("DEBUG: the server responded with \(ret!)")
            }
        })
        task.resume()
    }
    
    func cancelDownload(_ shaKey: String){
        guard let url = self.serverAddress else{
            print("DEBUG: invalid URL")
            return
        }
        let newURL = url.appendingPathComponent("delete/" + shaKey)
        print("DEBUG: the URL to pause and resume download is \(newURL.absoluteString)")
        var request = URLRequest(url: newURL)
        request.httpMethod = "DELETE"
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request, completionHandler:{
            data, response, error in
            if error != nil {
                print("DEBUG: \(error!.localizedDescription)")
            }else{
                let ret = NSString(data: data!, encoding:NSUTF8StringEncoding)
                print("DEBUG: the server responded with \(ret!)")
            }
        })
        task.resume()
    }
}
