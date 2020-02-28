//
//  Intake+Convenience.swift
//  CalorieTracker-v1
//
//  Created by Austin Potts on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData



extension Intake {
    
    
    convenience init(calories: Int, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.calories = Int32(calories)
        self.date = Date()
        
    }
    
    
}
