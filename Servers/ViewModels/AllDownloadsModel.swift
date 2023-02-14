//
//  AllDownloadsModel.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-02-03.
//

import Foundation

class AllDownloadsModel: ObservableObject{
    @Published var Sessions = [DownloadSession]()
    @Published var serverOnline : Bool = false{
        willSet{
            if !self.serverOnline && !newValue{
                // consecutive false
                self.statusRefreshRetries += 1
                if self.statusRefreshRetries == 5{
                    self.cancelStatusRefresh()
                    self.scheduleServerStatusCheck(serverStatusRefreshIntervalShort)
                }
            }else if !self.serverOnline && !newValue{
                // from false to true
                self.cancelStatusRefresh()
                self.scheduleServerStatusCheck(serverStatusRefreshIntervalShort)
                self.statusRefreshRetries = 0
            }
        }
    }
    @Published var error : Error?
    private var persistenceController = PersistenceController.shared
    private var client = HTTPClient()
    private var timerFetch : Timer?
    private var timerStatus : Timer?
    private var statusRefreshRetries : Int = 0
    private var fetchRefreshInterval : Int64 = 5
    private let serverStatusRefreshIntervalShort = 5.0
    private let serverStatusRefreshIntervalLong = 60.0
    init(){
        persistenceController = PersistenceController.shared
        let request = ShareExtension.fetchRequest()
        let results = try? persistenceController.container.viewContext.fetch(request)
        if let service = results?.first{
            fetchRefreshInterval = service.refreshInterval
        }
        fetchData()
        scheduleFetchRefresh()
//        scheduleServerStatusCheck(serverStatusRefreshIntervalShort)
    }

    //MARK: recurrent task scheduling and timer management
    
    func scheduleFetchRefresh(){
        timerFetch = Timer.scheduledTimer(withTimeInterval: Double(fetchRefreshInterval), repeats: true, block: { _ in
            self.fetchData()
        })
    }
    
    func fetchData(){
        Task{
            do{
                guard let sessions = try await self.client.fetchActiveDownloads() else { return}
                DispatchQueue.main.sync {
                    self.Sessions = sessions
                    self.serverOnline = true
                }
            }catch{
                if let _ = error as? HTTPClientError{
                    cancelFetchRefresh()
                }
                DispatchQueue.main.sync {
                    self.error = error
                }
            }
        }
    }
    
    func cancelFetchRefresh(){
        timerFetch?.invalidate()
        timerFetch = nil
    }
    
    func scheduleServerStatusCheck(_ checkInterval : Double){
        timerStatus = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true, block: { _ in
            Task{
                let serverOnline = await self.client.checkConnectivity()
                DispatchQueue.main.async{
                    self.serverOnline = serverOnline
                }
            }
        })
    }
    
    func cancelStatusRefresh(){
        timerStatus?.invalidate()
        timerStatus = nil
    }

    
    func manualRefresh() {
        fetchData()
        scheduleFetchRefresh()
    }
}
