//
//  CoreDataStack.swift
//  CalorieTracker-v1
//
//  Created by Austin Potts on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

    // Let us access the CoreDataStack from anywhere in the app.
    //Create Code Snippet
    static let shared = CoreDataStack()

    

    lazy var container: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "CaloriesIntake")

        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return container
    }()

    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }

    func save(context: NSManagedObjectContext) throws {
        var error: Error?

        do {
            try context.save()
        } catch let saveError {
            error = saveError
        }

        if let error = error { throw error }
    }
}
