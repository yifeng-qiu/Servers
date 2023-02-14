//
//  ServerView.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-01-30.
//

import SwiftUI
import UIKit

struct ServiceListView: View {
    @State var newServiceView: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: sample code generated by Xcode
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Services.serviceName, ascending: true)],
        animation: .default)
    
    private var services: FetchedResults<Services>
    
    @State var serviceName:String = ""
    @State var serviceDescription : String = ""
    @State var serviceRequiresVPN : Bool = false
    @State var serviceURI : String = ""
    @State var testOutput : String = ""
    
    // MARK: learning point: the declaration below will not work. viewContext cannot be used
    // within the property initializer as it is not available before init
    
    //    let services : [Services] = {
    //        let request = Services.fetchRequest()
    //        request.predicate = NSPredicate(format: "serviceName contains[cd] %@", "Google")
    //        return try! viewContext.fetch(request)
    //    }()
    
    // MARK: END of non-working code
    
    var body: some View {
        
        // How ever this causes the services to not get updated after a deletion.
        //        let services : [Services] = {
        //            let request = Services.fetchRequest()
        ////            request.predicate = NSPredicate(format: "serviceName contains[cd] %@", "Google")
        //            let sort = NSSortDescriptor(key: "serviceName", ascending: false)
        //            request.sortDescriptors = [sort]
        //            return try! viewContext.fetch(request)
        //        }()
        //
        
        VStack(spacing: 5){
            HStack{
                Text(newServiceView ? "New Service" : "Services")
                Spacer()
                Button{
                    if newServiceView{
                        // validate and save
                        if validateSave() {
                            newServiceView.toggle()
                        }
                        
                    }else{
                        newServiceView.toggle()
                        
                    }
                    
                }label: {
                    if newServiceView{
                        Text("Save")
                    }else{
                        Image(systemName: "plus.square")
                    }
                }
            }.padding(.horizontal)
                .font(.title)
            
            Divider().padding(.bottom, 5)
            Spacer()
            if newServiceView{
                NewServiceView(serviceName: $serviceName, serviceURI: $serviceURI, serviceDescription: $serviceDescription, requireVPN: $serviceRequiresVPN, testOutput: $testOutput)
            }else{
                if services.count == 0{
                    
                    Button{
                        newServiceView.toggle()
                        
                    }label: {
                        Text("Tap \(Image(systemName: "plus.square")) button to add a new service").foregroundColor(.black)
                    }
                    
                }else{
                    ScrollView{
                        ForEach(services) { service in
                            ServiceView(service: service)
                        }
                    }
                }
            }
            Spacer()
        }
        
    }
    
    private func validateSave() -> Bool {
        var ret : Bool = true
        var errorMsg: String = ""
        
        if serviceName == "" {
            ret = false
            errorMsg += "The name of the service cannot be blank. \n"
        }
        if let url = URL(string: serviceURI){
            errorMsg += "Absolute URL: \(url.absoluteURL)\n"
            errorMsg += "Relative Path: \(url.relativePath) \n"
            errorMsg += "Scheme: \(url.scheme ?? "") \n"
            errorMsg += "Host: \(url.host ?? "") \n"
            errorMsg += "Port: \(url.port ?? -1) \n"
        }else{
            ret = false
            errorMsg += "The URL is invalid. \n"
        }
        self.testOutput = errorMsg
        print("DEBUG: testOutput is now \(self.testOutput)")
        guard ret else {return false}
        let newService = Services(context: viewContext)
        newService.serviceName = serviceName
        newService.serviceURI = URL(string: serviceURI)
        newService.serviceDescription = serviceDescription
        newService.serviceRequiresVPN = serviceRequiresVPN
        newService.serviceID = UUID()
        do {
            try viewContext.save()
        } catch {
            return false
        }
        return true
    }
    
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceListView()
    }
}