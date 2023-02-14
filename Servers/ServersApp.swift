//
//  ServersApp.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-01-28.
//

import SwiftUI

@main
struct ServersApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
