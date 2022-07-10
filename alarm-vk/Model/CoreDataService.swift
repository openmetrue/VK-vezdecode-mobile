//
//  CoreDataService.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 09.07.2022.
//

import CoreData
import Combine

struct CoreDataService {
    var container: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return self.container.viewContext
    }
    static let shared = CoreDataService(name: "Model")
    private init(name: String) {
        self.container = NSPersistentContainer(name: name)
        self.container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
