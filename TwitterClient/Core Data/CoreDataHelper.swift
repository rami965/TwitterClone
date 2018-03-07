//
//  CoreDataHelper.swift
//  TwitterClient
//
//  Created by MACC on 3/7/18.
//  Copyright © 2018 Rami. All rights reserved.
//

import Foundation

class CoreDataHelper: NSObject {
    /**
     Creates a new record in for specific entity.
     
     - returns:
     An optional managed object.
     
     - parameters:
        - entity: The entity name.
        - managedObjectContext: The context in which data will be persisted.
     */
    func createRecordForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSManagedObject? {
        var result: NSManagedObject?
        let entityDescription = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext)
        if let entityDescription = entityDescription {
            result = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
        }
        
        return result
    }
    
    /**
     Fetch a list of all records for specific entity.
     
     - returns:
     An array of managed objects.
     
     - parameters:
        - entity: The entity name.
        - managedObjectContext: The context in which data will be persisted.
     */
    func fetchRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        var result = [NSManagedObject]()
        
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject] {
                result = records
            }
            
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
        
        return result
    }
    
    /**
     Fetch a list of all records for specific entity with specific condition.
     
     - returns:
     An array of managed objects.
     
     - parameters:
        - predicate: The condition used to fetch data.
        - entity: The entity name.
        - managedObjectContext: The context in which data will be persisted.
     */
    func fetchRecordsWithPredicate(_ predicate: NSPredicate, _ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = predicate
        var result = [NSManagedObject]()
        
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject] {
                result = records
            }
            
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
        
        return result
    }
    
    
    /**
     Clears all records of an entity.
     
     - parameters:
        - entity: The entity name.
        - managedObjectContext: The context in which data will be persisted.
     */
    func clearRecords(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedObjectContext.execute(deleteRequest)
            print("All records deleted successfully.")
        } catch {
            print("Unable to delete all records for entity \(entity).")
        }
        
    }
}
