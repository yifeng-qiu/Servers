//
//  ServiceViewModel.swift
//  Servers
//
//  Created by Yifeng Qiu on 2023-01-30.
//

import Foundation
import CoreData

extension Services{
    func removeService(from viewContext: NSManagedObjectContext){
        viewContext.delete(self)
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
