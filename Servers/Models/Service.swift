//
//  Service.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-01-30.
//

import Foundation
import CoreData

class ServiceModel : ObservableObject{
    var serviceName : String?
    var serviceURI : String?
    var requireVPN : Bool = false
    var serviceDescription : String = ""
    var uuid : UUID
    
    init() {
        self.uuid = UUID()
    }
}

