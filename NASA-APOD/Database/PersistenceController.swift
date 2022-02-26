//
//  PersistenceController.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
import CoreData
struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentContainer


    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    private init() {
        container = NSPersistentContainer(name: "APOD")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
}
