//
//  DataController.swift
//  Watch Me
//
//  Created by bhuvan on 23/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
        
    /// Singleton instance.
    static let shared = DataController(modelName: "Watch-Me")
    
    /// Persistant container.
    let persistantContainer: NSPersistentContainer!
    
    /// View context.
    var viewContext: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    /// Initialization
    init(modelName: String) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistantContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
    
    func save() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
}


extension DataController {
    func autoSaveViewContext(interval: TimeInterval = 30.0) {

        guard interval > 0 else {
            return
        }        
        save()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}

// Clear core data
extension DataController {
    func clear() {
        delete(entity: "Movie")
        delete(entity: "Cast")
        delete(entity: "Person")
    }
    
    func delete(entity: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try viewContext.execute(deleteRequest)
        } catch let error as NSError {
            fatalError("Unable to delete data \(error.localizedDescription)")
        }
    }
}
