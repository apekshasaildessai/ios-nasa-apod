//
//  ApodDataLoader.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
import CoreData

struct ApodDataLoader {
    var managedObjectContext: NSManagedObjectContext?
    init() {
        self.managedObjectContext = PersistenceController.shared.container.viewContext
    }
    func saveAPOD(apodItem: APODItem) -> APODEntity {
        guard let managedObjectContext = managedObjectContext else {
            fatalError("No Managed Object Context Available")
        }
        // Create APOD Entity
        let apodEntity = APODEntity(context: managedObjectContext)
        apodEntity.date = YearMonthDay(apodItem.date ?? "")?.asDate()
        apodEntity.thumbnail = apodItem.thumbnail_url
        apodEntity.explanation = apodItem.explanation
        apodEntity.url = apodItem.url
        apodEntity.hdUrl = apodItem.hdurl
        apodEntity.title = apodItem.title
        apodEntity.mediaType = apodItem.media_type
        
        PersistenceController.shared.save()
        return apodEntity
    }
    func fetchSavedAPODFor(day: Date) -> APODEntity? {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<APODEntity> = APODEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "date = %@", day as CVarArg
        )
        let context = PersistenceController.shared.container.viewContext
        
        do {
            // Execute Fetch Request
            let apodEntity = try context.fetch(fetchRequest).first
            return apodEntity

        } catch {
            print("Unable to Execute Fetch Request, \(error)")
        }
        return nil
    }
    func saveFavorite(apodItem: APODEntity) {
        PersistenceController.shared.save()
    }
    func fetchMyFavoriteAPOD() -> [APODEntity]? {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<APODEntity> = APODEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "isFavorite = YES"
        )
        let context = PersistenceController.shared.container.viewContext
        
        do {
            // Execute Fetch Request
            let results = try context.fetch(fetchRequest)
            return results

        } catch {
            print("Unable to Execute Fetch Request, \(error)")
        }
        return nil
    }
    func fetchLatestAPOD() -> APODEntity? {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<APODEntity> = APODEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        let context = PersistenceController.shared.container.viewContext
        do {
            // Execute Fetch Request
            let apodEntity = try context.fetch(fetchRequest).first
            return apodEntity

        } catch {
            print("Unable to Execute Fetch Request, \(error)")
        }
        return nil
    }
}
