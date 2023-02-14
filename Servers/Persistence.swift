//
//  Persistence.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-01-28.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Servers")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        let storeURL = URL.storeURL(for: "group.server.core.data", databaseName: "ShareExtension")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
            
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            guard error == nil else{
                let error = error! as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
//            print("DEBUG: the loaded storeDescription was \(String(describing: storeDescription))")
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
