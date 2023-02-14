//
//  ShareExtensionConfigurationModel.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-02-08.
//

import Foundation

class ShareExtensionConfiguration: ObservableObject{
    @Published var serverResponse : String = ""
    
    
    func checkServer(url: String){
        Task{
            let response = await HTTPClient.validateServer(url: url)
            DispatchQueue.main.async {
                self.serverResponse = response
            }
        }
    }
    
    
}
