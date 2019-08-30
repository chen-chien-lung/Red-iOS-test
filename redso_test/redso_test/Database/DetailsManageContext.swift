//
//  DetailsManageContext.swift
//  redso_test
//
//  Created by Joe Chen on 2019/8/30.
//  Copyright © 2019 Joe Chen. All rights reserved.
//

import Foundation
import Foundation
import CoreData
import UIKit



class DetailsManageContext {
    private static let sharedContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    class func shared() -> NSManagedObjectContext {
        return sharedContext
    }
    
}
