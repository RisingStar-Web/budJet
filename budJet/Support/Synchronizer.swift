//
//  Synchronizer.swift
//  budJet
//
//  Created by neko on 27.09.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import SwiftyJSON

class Synchronizer: NSObject {
/*
    class func syncGetNewItems(completion: @escaping (Bool) -> Void) {
        if AppData.isLoggedIn() {
            ApiService.sharedInstance.getItems(type: ItemsType.all, completion: { (itemsResponse) in
                print(itemsResponse)
                for newItem in itemsResponse["data"].arrayValue {
                    if newItem["should_delete"] != JSON.null {
                        CoreDataHelper.removeItemWithId(newItem["itemid"].int32!, completion: { (success) in
                            if success { print("deleted successfull") }
                            else { print("delete failed") }
                        })
                    } else {
                        CoreDataHelper.newItemFromJSON(itemJSON: newItem, completion: { (success) in
                            if success { print("added successfull") }
                            else { print("added failed") }
                        })
                    }
                }
                AppData.storeSyncTime()
                completion(true)
            }) { (error) in
                completion(false)
            }
        }
    }
    
    class func startSync() {
        if AppData.isLoggedIn() {
            let pendingItems = CoreDataHelper.getSyncPendingItems(syncState: .pending)
            let pendingRemoveItems = CoreDataHelper.getSyncPendingItems(syncState: .pendingRemove)
            let pendingUpdateItems = CoreDataHelper.getSyncPendingItems(syncState: .pendingEdit)

            for pendingItem in pendingItems {
                let queue = DispatchQueue.global(qos: .utility)
                queue.sync{
                    pendingItem.sync = Int16(SyncState.synchronizing.rawValue)
                    do {
                        try pendingItem.managedObjectContext?.save()
                    }
                    catch {
                        
                    }
                    ApiService.sharedInstance.addItem(item: pendingItem, completion: { (addItemResponse) in
                        if addItemResponse["success"].bool! {
                            pendingItem.sync = Int16(SyncState.synchronized.rawValue)
                            if addItemResponse["newid"] != JSON.null {
                                pendingItem.id = addItemResponse["newid"].int32!
                            }
                        } else {
                            pendingItem.sync = Int16(SyncState.pending.rawValue)
                        }
                        do {
                            try pendingItem.managedObjectContext?.save()
                        }
                        catch {
                            
                        }
                    }) { (error) in
                        pendingItem.sync = Int16(SyncState.pending.rawValue)
                        do {
                            try pendingItem.managedObjectContext?.save()
                        }
                        catch {
                            
                        }
                    }
                }
            }
            
            for pendingItem in pendingRemoveItems {
                let queue = DispatchQueue.global(qos: .utility)
                queue.sync{
                    pendingItem.sync = Int16(SyncState.synchronizing.rawValue)
                    do {
                        try pendingItem.managedObjectContext?.save()
                    }
                    catch {
                        
                    }
                    ApiService.sharedInstance.removeItem(item: pendingItem, completion: { (removeItemResponse) in
                        if removeItemResponse["success"].bool! || removeItemResponse["error_type"].int! == 1 {
                            CoreDataHelper.removeItemWithId(pendingItem.id, completion: { (success) in
                                if !success {
                                    pendingItem.sync = Int16(SyncState.pendingRemove.rawValue)
                                }
                            })
                        } else {
                            pendingItem.sync = Int16(SyncState.pendingRemove.rawValue)
                        }
                        do {
                            try pendingItem.managedObjectContext?.save()
                        }
                        catch {
                            
                        }
                    }) { (error) in
                        pendingItem.sync = Int16(SyncState.pendingRemove.rawValue)
                        do {
                            try pendingItem.managedObjectContext?.save()
                        }
                        catch {
                            
                        }
                    }
                }
            }
            
            for pendingItem in pendingUpdateItems {
                let queue = DispatchQueue.global(qos: .utility)
                queue.sync{
                    pendingItem.sync = Int16(SyncState.synchronizing.rawValue)
                    do {
                        try pendingItem.managedObjectContext?.save()
                    }
                    catch {
                        
                    }
                    ApiService.sharedInstance.editItem(item: pendingItem, completion: { (editItemResponse) in
                        if editItemResponse["success"].bool! {
                            pendingItem.sync = Int16(SyncState.synchronized.rawValue)
                        } else {
                            if editItemResponse["error_type"].int! == 1 {
                                pendingItem.sync = Int16(SyncState.pending.rawValue)
                            } else {
                                pendingItem.sync = Int16(SyncState.pendingEdit.rawValue)
                            }
                        }
                        do {
                            try pendingItem.managedObjectContext?.save()
                        }
                        catch {
                            
                        }
                    }) { (error) in
                        pendingItem.sync = Int16(SyncState.pendingEdit.rawValue)
                        do {
                            try pendingItem.managedObjectContext?.save()
                        }
                        catch {
                            
                        }
                    }
                }
            }
        }
    }
 */
}
