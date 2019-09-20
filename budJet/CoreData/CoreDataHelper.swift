//
//  CoreDataHelper.swift
//  read
//
//  Created by neko on 09.09.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

enum SyncState: Int {
    case pending = 0, pendingRemove, synchronized, synchronizing, pendingEdit
}

class CoreDataHelper: NSObject {
    
    static let coreDataManager = CoreDataManager(modelName: "BudJet")

    class func clearData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coreDataManager.managedObjectContext.persistentStoreCoordinator?.execute(deleteRequest, with: coreDataManager.managedObjectContext)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    class func getUniqueRecordID() -> Int32 {
        var newId = Int32().random()
        
        while isRecordsContainsID(id: newId) {
            newId = Int32().random()
        }
        return newId
    }
    
    private class func isRecordsContainsID(id: Int32) -> Bool {
        let context = coreDataManager.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        fetchRequest.predicate = NSPredicate(format: "id == %li", id)
        
        let fetchResults = try! context.fetch(fetchRequest)
        
        return fetchResults.count != 0

    }
    
    class func getSyncPendingItems(syncState: SyncState) -> [Record] {
        let context = coreDataManager.managedObjectContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        fetchRequest.predicate = NSPredicate(format: "sync == %i", syncState.rawValue)
        
        let fetchResults = try! context.fetch(fetchRequest) as! [Record]
        return fetchResults
    }
    
    class func getEarlyestDate() -> Date {
        let context = coreDataManager.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        fetchRequest.predicate = NSPredicate(format: "sync != %i", SyncState.pendingRemove.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchResults = try! context.fetch(fetchRequest) as! [Record]
        if fetchResults.count == 0 { return Date() }
        return (fetchResults.first?.date!)!
    }
    
    class func getItemsForType(_ type: Types, startDate: Date, endDate: Date) -> [Record]? {
        let context = coreDataManager.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        fetchRequest.predicate = NSPredicate(format: "typers == %@ AND date >= %@ AND date < %@", type, startDate as NSDate, endDate as NSDate)

        let fetchResults = try! context.fetch(fetchRequest) as! [Record]
        if fetchResults.count == 0 { return nil }
        return fetchResults
    }
    
    class func getTotalAmount(_ income: Bool, startDate: Date, endDate: Date) -> Float {
        let context = coreDataManager.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        fetchRequest.predicate = NSPredicate(format: "income == %@ AND date >= %@ AND date <= %@", NSNumber(booleanLiteral: income), startDate as NSDate, endDate as NSDate)
        var totalAmount: Float = 0.0
        let fetchResults = try! context.fetch(fetchRequest) as! [Record]
        print(fetchResults)
        if fetchResults.count == 0 { return 0.0 }
        else {
            for record in fetchResults {
                totalAmount += record.ammount
            }
        }
        return totalAmount
    }

    class func getTypesList(income: Bool?) -> [Types] {
        let context = coreDataManager.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Types")
        let fetchResults = try! context.fetch(fetchRequest) as! [Types]
        if income != nil {
            fetchRequest.predicate = NSPredicate(format: "income == %@", NSNumber(booleanLiteral: income!))
        }
        return fetchResults
    }
    
    class func updateTypesList(types: JSON, completion: @escaping (Bool) -> Void) {
        let context = coreDataManager.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Types",in:context)

        for type in types.arrayValue {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Types")
            fetchRequest.predicate = NSPredicate(format: "id == %li", type["id"].int16!)
            
            let fetchResults = try! context.fetch(fetchRequest)
            
            var newType: Types!
            
            if fetchResults.count == 0 {
                newType = Types(entity: entity!,insertInto: context)
            } else {
                newType = fetchResults.first as? Types
            }
            newType.id = type["id"].int16!
            newType.income = type["income"].bool!
            newType.key = type["key"].string!
            do {
                try newType.managedObjectContext?.save()
            } catch {
                
            }

        }
        completion(true)
    }
    
    class func setItemToRemove(_ itemId : Int32, completion: @escaping (Bool) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        fetchRequest.predicate = NSPredicate(format: "id == %li", itemId)
        let fetchResults = try! coreDataManager.managedObjectContext.fetch(fetchRequest)
        
        if fetchResults.count != 0 {
            let item = fetchResults.first as! Record
            item.sync = Int16(SyncState.pendingRemove.rawValue)
            do {
                try coreDataManager.managedObjectContext.save()
                completion(true)
            } catch {
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
    class func removeItemWithId(_ itemId : Int32, completion: @escaping (Bool) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        fetchRequest.predicate = NSPredicate(format: "id == %li", itemId)
        let fetchResults = try! coreDataManager.managedObjectContext.fetch(fetchRequest)
        
        if fetchResults.count != 0 {
            coreDataManager.managedObjectContext.delete(fetchResults.first as! Record)
            do {
                try coreDataManager.managedObjectContext.save()
                completion(true)
            } catch {
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
    class func newItemFromJSON(itemJSON : JSON, completion: @escaping (Bool) -> Void) {
        //print("dsafsdf" + itemJSON.string!)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        fetchRequest.predicate = NSPredicate(format: "id == %li", itemJSON["itemid"].int32!)
        
        let fetchResults = try! coreDataManager.managedObjectContext.fetch(fetchRequest)
        
        var item: Record!
        
        if fetchResults.count == 0 {
            let entity =  NSEntityDescription.entity(forEntityName: "Record",in:coreDataManager.managedObjectContext)
            item = Record(entity: entity!,insertInto: coreDataManager.managedObjectContext)
        } else {
            item = fetchResults[0] as? Record
        }
        item.id = itemJSON["itemid"].int32!
        item.comment = itemJSON["info"].string!
        item.income = itemJSON["income"].bool!
        item.ammount = itemJSON["value"].float!
        item.sync = Int16(SyncState.synchronized.rawValue)
        let date = Date(timeIntervalSince1970: TimeInterval(itemJSON["time"].int32!))
        
        item.date = date
        item.daySectionIdentifier = date.daySectionIdentifier()
        
        let typeFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Types")
        typeFetchRequest.predicate = NSPredicate(format: "id == %li", itemJSON["type"].int32!)
        
        let typeFetchResults = try! coreDataManager.managedObjectContext.fetch(typeFetchRequest)
        
        if typeFetchResults.count != 0 {
            item.typers = (typeFetchResults[0] as! Types)
            
            do {
                try coreDataManager.managedObjectContext.save()
                completion(true)
            } catch {
                let saveError = error as NSError
                print("Unable to Save Note")
                print("\(saveError), \(saveError.localizedDescription)")
                completion(false)
            }
        }
    }
    

    
}
