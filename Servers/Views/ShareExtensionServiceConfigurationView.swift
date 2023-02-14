//
//  ShareExtensionServiceConfigurationView.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-02-08.
//

import SwiftUI
import UIKit
struct ShareExtensionServiceConfiguration: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var baseURL: String = ""
    @State var postURL: String = ""
    @State var fetchDownloadURL : String = ""
    @State var pauseResumeURL: String = ""
    @State var deleteURL : String = ""
    @State var testOutput : String = ""
    @State var toggleSendNotifications : Bool = false
    @State var refreshInterval : Int = 5
    @State var showServerResponse : Bool = false
    @State var serverResponse : String = ""
    @State var savedService : ShareExtension?
    @State var saved : Bool = false
    var body: some View {
        VStack {
            Button{
                Task{
                    let response = await HTTPClient.validateServer(url: baseURL)
                    DispatchQueue.main.async {
                        print("DEBUG: server responded with \(response)")
                        self.serverResponse = response
                        self.showServerResponse = true
                    }
                }
            }label:{
                withAnimation {
                    Text(saved ? "Saved" : "Save")
                }
            }.onAppear(perform: {
                loadSetting()
            })
            
            Form{
                Section {
                    TextField("Base URL", text: $baseURL)
                    TextField("Post URL", text: $postURL)
                    TextField("Fetch Download URL", text: $fetchDownloadURL)
                    TextField("Pause Resume URL",text: $pauseResumeURL)
                    TextField("Delete URL",text: $deleteURL)
                } header: {
                    Text("Service URLs")
                }
                
                Section {
                    Toggle("Send notifications", isOn: $toggleSendNotifications)
                    Stepper("Refesh every \(refreshInterval) seconds", value: $refreshInterval, in:1...60)
                } header: {
                    Text("Settings")
                }
            }
            
            .alert(serverResponse, isPresented: $showServerResponse, actions: {
                Button {
                    saveSetting()
                    saved = true
                } label: {
                    Text("Save")
                }
                Button {
                    
                } label: {
                    Text("Cancel")
                }

            })
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .border(.black)
            
        }
    }
    
    func loadSetting(){
        let request = ShareExtension.fetchRequest()
        let results = try? viewContext.fetch(request)
        savedService = results?.first
        if savedService != nil{
            baseURL = savedService!.baseURL ?? ""
            postURL = savedService!.postURL ?? ""
            fetchDownloadURL = savedService!.fetchDownloadsURL ?? ""
            pauseResumeURL = savedService!.pauseResumeURL ?? ""
            deleteURL = savedService!.deleteURL ?? ""
            toggleSendNotifications = savedService!.sendNotification
            refreshInterval = Int(savedService!.refreshInterval)
        }
    }
    
    func saveSetting(){
        if savedService == nil{
            let newService = ShareExtension(context: viewContext)
            newService.baseURL = baseURL
            newService.postURL = postURL
            newService.fetchDownloadsURL = fetchDownloadURL
            newService.pauseResumeURL = pauseResumeURL
            newService.deleteURL = deleteURL
            newService.sendNotification = toggleSendNotifications
            newService.refreshInterval = Int64(refreshInterval)
        }else{
            savedService!.baseURL = baseURL
            savedService!.postURL = postURL
            savedService!.fetchDownloadsURL = fetchDownloadURL
            savedService!.pauseResumeURL = pauseResumeURL
            savedService!.deleteURL = deleteURL
            savedService!.sendNotification = toggleSendNotifications
            savedService!.refreshInterval = Int64(refreshInterval)
            do{
                try viewContext.save()
            }catch let error{
                print("DEBUG: error while trying save changes. \(error.localizedDescription)")
            }
        }
    }
}

struct ShareExtensionServiceConfiguration_Preview: PreviewProvider {
    static var previews: some View {
        ShareExtensionServiceConfiguration().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

